//
//  RunRecorder.swift
//  RunnerPrime
//
//  Created by Ankit Yadav on 10/29/25.
//

import Foundation
import CoreLocation
import Combine

/// RunRecorder manages the core run recording logic with territory mapping
/// Integrates GPS tracking, territory calculation, and persistence
class RunRecorder: ObservableObject {
    @Published private(set) var currentRun: RunModel?
    @Published private(set) var isRecording: Bool = false
    @Published private(set) var isPaused: Bool = false
    @Published private(set) var currentTerritoryInfo: TerritoryInfo?
    
    private var locationManager: LocationManager?
    private var cancellables = Set<AnyCancellable>()
    private let tileEngine = TileEngine()
    private var sessionId: String?
    
    // Real-time stats
    @Published private(set) var liveDistance: Double = 0
    @Published private(set) var liveDuration: TimeInterval = 0
    @Published private(set) var livePace: Double = 0 // seconds per km
    
    private var runTimer: Timer?
    
    init(locationManager: LocationManager?) {
        self.locationManager = locationManager
        setupSubscriptions()
    }
    
    convenience init() {
        self.init(locationManager: nil)
    }
    
    func bind(locationManager: LocationManager) {
        self.locationManager = locationManager
        setupSubscriptions()
    }
    
    private func setupSubscriptions() {
        locationManager?.$lastLocation
            .compactMap { $0 }
            .sink { [weak self] location in
                self?.processLocation(location)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Run Control
    
    func startRun() {
        guard !isRecording else { return }
        
        sessionId = UUID().uuidString
        currentRun = RunModel(startTime: Date())
        isRecording = true
        isPaused = false
        
        // Reset live stats
        liveDistance = 0
        liveDuration = 0
        livePace = 0
        currentTerritoryInfo = nil
        
        // Start location updates
        locationManager?.startUpdates()
        
        // Start live timer
        startLiveTimer()
        
        // Analytics
        AnalyticsService.shared.logRunStart(
            sessionId: sessionId ?? "unknown",
            deviceModel: UIDevice.current.model
        )
        
        AnalyticsService.shared.logEvent("run_started")
        
        print("🏃‍♂️ Run started: \(sessionId ?? "unknown")")
    }
    
    func pauseRun() {
        guard isRecording && !isPaused else { return }
        
        isPaused = true
        locationManager?.stopUpdates()
        stopLiveTimer()
        
        // Analytics
        AnalyticsService.shared.logRunPause(sessionId: sessionId ?? "unknown")
        AnalyticsService.shared.logEvent("run_paused")
        
        print("⏸️ Run paused")
    }
    
    func resumeRun() {
        guard isRecording && isPaused else { return }
        
        isPaused = false
        locationManager?.startUpdates()
        startLiveTimer()
        
        // Analytics
        AnalyticsService.shared.logRunResume(sessionId: sessionId ?? "unknown")
        AnalyticsService.shared.logEvent("run_resumed")
        
        print("▶️ Run resumed")
    }
    
    func stopRun() {
        guard isRecording else { return }
        guard var run = currentRun else { return }
        
        // Finalize run
        run.endTime = Date()
        run.finalize()
        currentRun = run
        
        // Stop recording
        isRecording = false
        isPaused = false
        locationManager?.stopUpdates()
        stopLiveTimer()
        
        // Calculate territory
        let territoryInfo = tileEngine.processRun(run)
        currentTerritoryInfo = territoryInfo
        
        // Analytics
        let avgPace = run.duration / (run.distance / 1000)
        AnalyticsService.shared.logRunEnd(
            sessionId: sessionId ?? "unknown",
            distanceMeters: run.distance,
            durationSeconds: run.duration,
            avgPaceSecondsPerKm: avgPace,
            tilesCount: territoryInfo.tileCount
        )
        
        AnalyticsService.shared.logTileClaim(
            numTiles: territoryInfo.tileCount,
            period: "week", // For MVP, we'll use weekly periods
            totalArea: territoryInfo.totalAreaSquareMeters
        )
        
        AnalyticsService.shared.logEvent("run_stopped")
        
        print("🏁 Run completed: \(run.durationString), \(String(format: "%.2f", run.distance/1000))km, \(territoryInfo.tileCount) tiles")
        
        // Persist run
        persistRun(run, territoryInfo: territoryInfo)
    }
    
    // MARK: - Location Processing
    
    private func processLocation(_ location: CLLocation) {
        guard var run = currentRun, isRecording && !isPaused else { return }
        
        // Add point to run
        let point = RunPoint(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            timestamp: location.timestamp.timeIntervalSince1970
        )
        
        run.points.append(point)
        run.distance = run.computeDistance()
        run.duration = Date().timeIntervalSince(run.startTime)
        
        currentRun = run
        
        // Update live stats
        updateLiveStats(run: run)
        
        // Update territory in real-time (every 10 points for performance)
        if run.points.count % 10 == 0 {
            updateLiveTerritory(run: run)
        }
    }
    
    private func updateLiveStats(run: RunModel) {
        liveDistance = run.distance
        liveDuration = run.duration
        
        // Calculate pace (seconds per km)
        if run.distance > 100 { // Only calculate after 100m to avoid crazy initial pace
            livePace = run.duration / (run.distance / 1000)
        }
    }
    
    private func updateLiveTerritory(run: RunModel) {
        let territoryInfo = tileEngine.processRun(run)
        currentTerritoryInfo = territoryInfo
    }
    
    // MARK: - Timer Management
    
    private func startLiveTimer() {
        runTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateLiveDuration()
        }
    }
    
    private func stopLiveTimer() {
        runTimer?.invalidate()
        runTimer = nil
    }
    
    private func updateLiveDuration() {
        guard let run = currentRun, isRecording && !isPaused else { return }
        liveDuration = Date().timeIntervalSince(run.startTime)
    }
    
    // MARK: - Persistence & Upload
    
    private func persistRun(_ run: RunModel, territoryInfo: TerritoryInfo) {
        // Save locally first
        do {
            try LocalStore.shared.saveRunLocally(run)
            AnalyticsService.shared.logEvent("run_saved")
            
            // Upload to Firebase if user is signed in
            if let userId = FirebaseService.shared.currentUserId {
                uploadRun(run, territoryInfo: territoryInfo, userId: userId)
            }
            
        } catch {
            print("❌ Failed to save run locally: \(error)")
            AnalyticsService.shared.logError(
                context: "local_save_failed",
                error: error
            )
        }
    }
    
    private func uploadRun(_ run: RunModel, territoryInfo: TerritoryInfo, userId: String) {
        // Upload run data
        FirebaseService.shared.uploadRun(run, for: userId) { [weak self] result in
            switch result {
            case .success(let runId):
                print("✅ Run uploaded successfully: \(runId)")
                AnalyticsService.shared.logEvent("run_uploaded")
                
                // Upload territory tiles
                self?.uploadTerritoryTiles(territoryInfo: territoryInfo, userId: userId)
                
            case .failure(let error):
                print("❌ Failed to upload run: \(error)")
                AnalyticsService.shared.logError(
                    context: "run_upload_failed",
                    error: error
                )
            }
        }
    }
    
    private func uploadTerritoryTiles(territoryInfo: TerritoryInfo, userId: String) {
        let tileIds = Array(territoryInfo.tileIds)
        let currentWeek = DateFormatter.weekPeriodFormatter.string(from: Date())
        
        FirebaseService.shared.uploadTiles(tileIds, for: userId, period: currentWeek) { result in
            switch result {
            case .success():
                print("✅ Territory tiles uploaded successfully")
                
            case .failure(let error):
                print("❌ Failed to upload territory tiles: \(error)")
                AnalyticsService.shared.logError(
                    context: "tiles_upload_failed",
                    error: error
                )
            }
        }
    }
    
    // MARK: - Computed Properties
    
    var currentRunState: RunState {
        if isRecording {
            return isPaused ? .paused : .recording
        }
        return .stopped
    }
    
    // MARK: - Public Getters for UI
    
    var formattedLiveDistance: String {
        return String(format: "%.2f km", liveDistance / 1000)
    }
    
    var formattedLiveDuration: String {
        return TimeInterval(liveDuration).formattedDuration
    }
    
    var formattedLivePace: String {
        guard livePace > 0 && livePace.isFinite else { return "--:--" }
        let minutes = Int(livePace / 60)
        let seconds = Int(livePace.truncatingRemainder(dividingBy: 60))
        return String(format: "%d:%02d /km", minutes, seconds)
    }
}

// MARK: - Run State Enum

enum RunState {
    case stopped
    case recording
    case paused
    
    var displayName: String {
        switch self {
        case .stopped: return "Stopped"
        case .recording: return "Recording"
        case .paused: return "Paused"
        }
    }
}

// MARK: - Helper Extensions

extension TimeInterval {
    var formattedDuration: String {
        let total = Int(self)
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let seconds = total % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
}

extension DateFormatter {
    static let weekPeriodFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-'W'ww" // e.g., "2025-W44"
        return formatter
    }()
}

