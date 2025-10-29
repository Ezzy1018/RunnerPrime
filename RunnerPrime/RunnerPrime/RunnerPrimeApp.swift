//
//  RunnerPrimeApp.swift
//  RunnerPrime
//
//  Created by Ankit Yadav on 10/29/25.
//

import SwiftUI
import FirebaseCore
import UIKit

@main
struct RunnerPrimeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    // Environment objects
    @StateObject private var locationManager = LocationManager()
    @StateObject private var runRecorder = RunRecorder()
    @StateObject private var firebaseService = FirebaseService.shared
    
    init() {
        // Configure appearance
        configureAppearance()
        
        // Set initial user properties
        setInitialUserProperties()
    }

    var body: some Scene {
        WindowGroup {
            // Show onboarding for new users, otherwise main app
            if hasCompletedOnboarding {
                ContentView()
                    .environmentObject(locationManager)
                    .environmentObject(runRecorder)
                    .environmentObject(firebaseService)
                    .onAppear {
                        // Bind location manager to run recorder
                        runRecorder.bind(locationManager: locationManager)
                        
                        // Log app open
                        AnalyticsService.shared.logAppOpen()
                    }
            } else {
                OnboardingView()
                    .environmentObject(locationManager)
                    .environmentObject(runRecorder)
                    .environmentObject(firebaseService)
                    .onAppear {
                        runRecorder.bind(locationManager: locationManager)
                    }
            }
        }
    }
    
    private var hasCompletedOnboarding: Bool {
        return UserDefaults.standard.bool(forKey: "HasCompletedOnboarding")
    }
    
    private func configureAppearance() {
        // Dark theme with RunnerPrime colors
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 29/255, green: 28/255, blue: 30/255, alpha: 1.0)
        appearance.titleTextAttributes = [.foregroundColor: UIColor(red: 253/255, green: 252/255, blue: 250/255, alpha: 1.0)]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(red: 253/255, green: 252/255, blue: 250/255, alpha: 1.0)]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        // Tab bar appearance
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = UIColor(red: 29/255, green: 28/255, blue: 30/255, alpha: 1.0)
        
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance
        
        // Tint color
        UIWindow.appearance().tintColor = UIColor(red: 217/255, green: 255/255, blue: 84/255, alpha: 1.0)
    }
    
    private func setInitialUserProperties() {
        // Set default user properties
        let units = UserDefaults.standard.string(forKey: "units") ?? "km"
        AnalyticsService.shared.setUserUnits(units)
        
        let language = UserDefaults.standard.string(forKey: "language") ?? "en"
        AnalyticsService.shared.setUserProperty(name: "language", value: language)
        
        // Set launch city based on locale (basic implementation)
        let locale = Locale.current
        if let regionCode = locale.regionCode {
            if regionCode == "IN" {
                AnalyticsService.shared.setUserHomeCity("India")
            }
        }
        
        AnalyticsService.shared.setSignupSource("organic")
    }
}

// MARK: - App Delegate

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        // Configure Firebase
        FirebaseService.shared.configure()
        
        // Request notification permissions (for future use)
        requestNotificationPermissions()
        
        return true
    }
    
    private func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                UserDefaults.standard.set(granted, forKey: "notificationsEnabled")
                if granted {
                    AnalyticsService.shared.logEvent("notification_permission_granted")
                }
            }
        }
    }
    
    // Handle background tasks
    func application(
        _ application: UIApplication,
        performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        // Upload pending runs when app becomes active in background
        uploadPendingRuns { result in
            switch result {
            case .success:
                completionHandler(.newData)
            case .failure:
                completionHandler(.failed)
            }
        }
    }
    
    private func uploadPendingRuns(completion: @escaping (Result<Void, Error>) -> Void) {
        let pendingRuns = LocalStore.shared.getPendingUploads()
        
        guard !pendingRuns.isEmpty else {
            completion(.success(()))
            return
        }
        
        let group = DispatchGroup()
        var hasErrors = false
        
        for run in pendingRuns.prefix(5) { // Limit to 5 runs per background session
            group.enter()
            
            FirebaseService.shared.uploadRun(run) { result in
                switch result {
                case .success:
                    // Mark as uploaded - for now just log it
                    print("✅ Marked run \(run.id) as uploaded")
                case .failure:
                    hasErrors = true
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            if hasErrors {
                completion(.failure(NSError(domain: "UploadError", code: -1)))
            } else {
                completion(.success(()))
            }
        }
    }
}

import UserNotifications
