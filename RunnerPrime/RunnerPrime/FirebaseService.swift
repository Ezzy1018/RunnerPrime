//
//  FirebaseService.swift
//  RunnerPrime
//
//  Created by Ankit Yadav on 10/29/25.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import AuthenticationServices
import Combine

/// FirebaseService handles all cloud operations for RunnerPrime
/// Manages authentication, run uploads, territory data sync
final class FirebaseService: ObservableObject {
    static let shared = FirebaseService()
    
    private let db = Firestore.firestore()
    private let auth = Auth.auth()
    
    @Published var currentUser: UserRecord?
    @Published var isAuthenticated = false
    
    private init() {
        // Monitor auth state changes
        auth.addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.isAuthenticated = user != nil
                if let user = user {
                    self?.loadUserRecord(userId: user.uid)
                } else {
                    self?.currentUser = nil
                }
            }
        }
    }
    
    // MARK: - Configuration
    
    func configure() {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        
        // Configure Firestore settings
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        settings.cacheSizeBytes = FirestoreCacheSizeUnlimited
        db.settings = settings
    }
    
    // MARK: - Authentication
    
    /// Sign in with Apple ID credential
    func signInWithApple(credential: ASAuthorizationAppleIDCredential, completion: @escaping (Result<UserRecord, Error>) -> Void) {
        guard let nonce = currentNonce else {
            completion(.failure(FirebaseServiceError.missingNonce))
            return
        }
        
        guard let appleIDToken = credential.identityToken else {
            completion(.failure(FirebaseServiceError.missingAppleIDToken))
            return
        }
        
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            completion(.failure(FirebaseServiceError.invalidAppleIDToken))
            return
        }
        
        let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                idToken: idTokenString,
                                                rawNonce: nonce)
        
        auth.signIn(with: credential) { [weak self] authResult, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let user = authResult?.user else {
                completion(.failure(FirebaseServiceError.authenticationFailed))
                return
            }
            
            // Create or update user record
            self?.createOrUpdateUser(
                userId: user.uid,
                email: user.email,
                displayName: credential.fullName?.givenName,
                appleUserId: credential.user
            ) { result in
                completion(result)
            }
        }
    }
    
    /// Sign out current user
    func signOut() throws {
        try auth.signOut()
        DispatchQueue.main.async {
            self.currentUser = nil
            self.isAuthenticated = false
        }
    }
    
    // MARK: - User Management
    
    private func createOrUpdateUser(userId: String, email: String?, displayName: String?, appleUserId: String, completion: @escaping (Result<UserRecord, Error>) -> Void) {
        
        let userRef = db.collection("users").document(userId)
        
        // Check if user already exists
        userRef.getDocument { [weak self] document, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            let userData: [String: Any] = [
                "userId": userId,
                "email": email ?? "",
                "displayName": displayName ?? "Runner",
                "appleUserId": appleUserId,
                "createdAt": document?.exists == true ? document?.get("createdAt") ?? Timestamp() : Timestamp(),
                "lastLoginAt": Timestamp(),
                "units": "km", // default to metric for India
                "city": "", // will be updated based on location
                "totalRuns": 0,
                "totalDistance": 0.0,
                "totalTerritoryArea": 0.0
            ]
            
            userRef.setData(userData, merge: true) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    let userRecord = UserRecord(
                        userId: userId,
                        email: email ?? "",
                        displayName: displayName ?? "Runner",
                        createdAt: Date(),
                        units: "km",
                        city: "",
                        totalRuns: 0,
                        totalDistance: 0.0,
                        totalTerritoryArea: 0.0
                    )
                    
                    DispatchQueue.main.async {
                        self?.currentUser = userRecord
                    }
                    
                    completion(.success(userRecord))
                }
            }
        }
    }
    
    private func loadUserRecord(userId: String) {
        db.collection("users").document(userId).getDocument { [weak self] document, error in
            if let error = error {
                print("❌ Error loading user record: \(error)")
                return
            }
            
            guard let document = document, document.exists,
                  let data = document.data() else {
                print("⚠️ User record not found")
                return
            }
            
            let userRecord = UserRecord(
                userId: data["userId"] as? String ?? userId,
                email: data["email"] as? String ?? "",
                displayName: data["displayName"] as? String ?? "Runner",
                createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
                units: data["units"] as? String ?? "km",
                city: data["city"] as? String ?? "",
                totalRuns: data["totalRuns"] as? Int ?? 0,
                totalDistance: data["totalDistance"] as? Double ?? 0.0,
                totalTerritoryArea: data["totalTerritoryArea"] as? Double ?? 0.0
            )
            
            DispatchQueue.main.async {
                self?.currentUser = userRecord
            }
        }
    }
    
    // MARK: - Current User Access
    
    var currentUserId: String? {
        return auth.currentUser?.uid
    }
    
    // MARK: - Run Operations
    
    /// Upload a run to Firestore
    func uploadRun(_ run: RunModel, for userId: String? = nil, completion: @escaping (Result<String, Error>) -> Void) {
        let targetUserId = userId ?? auth.currentUser?.uid
        guard let targetUserId = targetUserId else {
            completion(.failure(FirebaseServiceError.userNotAuthenticated))
            return
        }
        
        let runRef = db.collection("runs").document(run.id)
        
        let runData: [String: Any] = [
            "userId": targetUserId,
            "runId": run.id,
            "startTime": Timestamp(date: run.startTime),
            "endTime": run.endTime != nil ? Timestamp(date: run.endTime!) : NSNull(),
            "distance": run.distance,
            "duration": run.duration,
            "points": run.points.map { point in
                return [
                    "latitude": point.latitude,
                    "longitude": point.longitude,
                    "timestamp": point.timestamp
                ]
            },
            "deviceModel": UIDevice.current.model,
            "uploadedAt": Timestamp(),
            "validated": false // Will be validated by Cloud Function
        ]
        
        runRef.setData(runData) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                // Update user statistics
                self.updateUserStats(after: run)
                completion(.success(run.id))
                
                // Log analytics event
                AnalyticsService.shared.logEvent("run_upload", parameters: [
                    "run_id": run.id,
                    "distance_m": run.distance,
                    "duration_s": run.duration
                ])
            }
        }
    }
    
    /// Fetch recent runs for a user
    func fetchRecentRuns(limit: Int = 20, completion: @escaping (Result<[RunModel], Error>) -> Void) {
        guard let userId = auth.currentUser?.uid else {
            completion(.failure(FirebaseServiceError.userNotAuthenticated))
            return
        }
        
        db.collection("runs")
            .whereField("userId", isEqualTo: userId)
            .order(by: "startTime", descending: true)
            .limit(to: limit)
            .getDocuments { snapshot, error in
                
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion(.success([]))
                    return
                }
                
                var runs: [RunModel] = []
                
                for document in documents {
                    if let run = self.parseRunDocument(document) {
                        runs.append(run)
                    }
                }
                
                completion(.success(runs))
            }
    }
    
    // MARK: - Territory Operations
    
    /// Upload territory tiles claimed by a run
    func uploadTiles(_ tileIds: [String], for runId: String, period: String = "current", completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = auth.currentUser?.uid else {
            completion(.failure(FirebaseServiceError.userNotAuthenticated))
            return
        }
        
        let batch = db.batch()
        
        // Add tiles to user's territory collection
        for tileId in tileIds {
            let tileRef = db.collection("users").document(userId).collection("tiles").document(tileId)
            let tileData: [String: Any] = [
                "tileId": tileId,
                "claimedAt": Timestamp(),
                "runId": runId,
                "period": period
            ]
            batch.setData(tileData, forDocument: tileRef, merge: true)
        }
        
        // Commit batch write
        batch.commit { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
                
                // Log analytics event
                AnalyticsService.shared.logEvent("tiles_claimed", parameters: [
                    "tile_count": tileIds.count,
                    "run_id": runId,
                    "period": period
                ])
            }
        }
    }
    
    /// Fetch user's claimed tiles for a period
    func fetchUserTiles(for period: String = "current", completion: @escaping (Result<[String], Error>) -> Void) {
        guard let userId = auth.currentUser?.uid else {
            completion(.failure(FirebaseServiceError.userNotAuthenticated))
            return
        }
        
        db.collection("users").document(userId).collection("tiles")
            .whereField("period", isEqualTo: period)
            .getDocuments { snapshot, error in
                
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                let tileIds = snapshot?.documents.compactMap { document in
                    document.get("tileId") as? String
                } ?? []
                
                completion(.success(tileIds))
            }
    }
    
    // MARK: - Helper Methods
    
    private func updateUserStats(after run: RunModel) {
        guard let userId = auth.currentUser?.uid else { return }
        
        let userRef = db.collection("users").document(userId)
        
        db.runTransaction({ [weak self] transaction, errorPointer in
            let userDocument: DocumentSnapshot
            do {
                try userDocument = transaction.getDocument(userRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            let currentRuns = userDocument.get("totalRuns") as? Int ?? 0
            let currentDistance = userDocument.get("totalDistance") as? Double ?? 0.0
            
            transaction.updateData([
                "totalRuns": currentRuns + 1,
                "totalDistance": currentDistance + run.distance,
                "lastRunAt": Timestamp(date: run.startTime)
            ], forDocument: userRef)
            
            return nil
        }) { object, error in
            if let error = error {
                print("❌ Error updating user stats: \(error)")
            } else {
                print("✅ User stats updated")
            }
        }
    }
    
    private func parseRunDocument(_ document: DocumentSnapshot) -> RunModel? {
        guard let data = document.data(),
              let runId = data["runId"] as? String,
              let startTime = (data["startTime"] as? Timestamp)?.dateValue(),
              let distance = data["distance"] as? Double,
              let duration = data["duration"] as? TimeInterval,
              let pointsData = data["points"] as? [[String: Any]] else {
            return nil
        }
        
        let endTime = (data["endTime"] as? Timestamp)?.dateValue()
        
        let points = pointsData.compactMap { pointData -> RunPoint? in
            guard let lat = pointData["latitude"] as? Double,
                  let lon = pointData["longitude"] as? Double,
                  let timestamp = pointData["timestamp"] as? TimeInterval else {
                return nil
            }
            return RunPoint(latitude: lat, longitude: lon, timestamp: timestamp)
        }
        
        var run = RunModel(id: runId, startTime: startTime, endTime: endTime, points: points, distance: distance, duration: duration)
        return run
    }
    
    // MARK: - Nonce for Apple Sign In
    
    private var currentNonce: String?
    
    func generateNonce() -> String {
        let charset: Array<Character> = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = 32
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0..<16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        currentNonce = result
        return result
    }
}

// MARK: - Data Models

struct UserRecord: Codable {
    let userId: String
    let email: String
    let displayName: String
    let createdAt: Date
    let units: String
    let city: String
    let totalRuns: Int
    let totalDistance: Double
    let totalTerritoryArea: Double
}

// MARK: - Error Types

enum FirebaseServiceError: LocalizedError {
    case missingNonce
    case missingAppleIDToken
    case invalidAppleIDToken
    case authenticationFailed
    case userNotAuthenticated
    case networkError
    case serverError(String)
    
    var errorDescription: String? {
        switch self {
        case .missingNonce:
            return "Invalid state: A login callback was received, but no login request was sent."
        case .missingAppleIDToken:
            return "Unable to fetch identity token"
        case .invalidAppleIDToken:
            return "Unable to serialize token string from data"
        case .authenticationFailed:
            return "Authentication failed"
        case .userNotAuthenticated:
            return "User not authenticated"
        case .networkError:
            return "Network connection error"
        case .serverError(let message):
            return "Server error: \(message)"
        }
    }
}