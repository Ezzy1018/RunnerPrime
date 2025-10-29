//
//  AnalyticsService.swift
//  RunnerPrime
//
//  Created by Ankit Yadav on 10/29/25.
//

import Foundation
import FirebaseAnalytics

/// AnalyticsService handles all Firebase Analytics event tracking for RunnerPrime
/// Implements comprehensive event tracking as specified in PRD for retention analysis
final class AnalyticsService {
    static let shared = AnalyticsService()
    
    private init() {}
    
    // MARK: - Core Events
    
    /// Log app open event
    func logAppOpen() {
        logEvent("app_open", params: [
            "timestamp": Date().timeIntervalSince1970
        ])
    }
    
    /// Log generic event with optional parameters
    func logEvent(_ name: String, params: [String: Any]? = nil) {
        #if DEBUG
        print("📊 Analytics: \(name) \(params ?? [:])")
        #endif
        
        Analytics.logEvent(name, parameters: params)
    }
    
    // MARK: - Onboarding Events
    
    /// Log onboarding step completion
    func logOnboardingStep(step: Int, stepName: String) {
        logEvent("onboarding_step", params: [
            "step_number": step,
            "step_name": stepName
        ])
    }
    
    /// Log location permission grant
    func logLocationPermissionGranted(authorization: String) {
        logEvent("location_permission_granted", params: [
            "authorization_type": authorization
        ])
    }
    
    /// Log user signup
    func logSignup(method: String) {
        logEvent("signup", params: [
            "method": method,
            "timestamp": Date().timeIntervalSince1970
        ])
    }
    
    // MARK: - Run Recording Events
    
    /// Log run start
    func logRunStart(sessionId: String, deviceModel: String) {
        logEvent("run_start", params: [
            "session_id": sessionId,
            "device_model": deviceModel,
            "timestamp": Date().timeIntervalSince1970
        ])
    }
    
    /// Log run pause
    func logRunPause(sessionId: String, elapsedSeconds: TimeInterval) {
        logEvent("run_pause", params: [
            "session_id": sessionId,
            "elapsed_seconds": Int(elapsedSeconds)
        ])
    }
    
    /// Log run resume
    func logRunResume(sessionId: String) {
        logEvent("run_resume", params: [
            "session_id": sessionId
        ])
    }
    
    /// Log run end with comprehensive stats
    func logRunEnd(
        sessionId: String,
        distanceMeters: Double,
        durationSeconds: TimeInterval,
        avgPaceSecondsPerKm: Double,
        tilesCount: Int
    ) {
        logEvent("run_end", params: [
            "session_id": sessionId,
            "distance_meters": Int(distanceMeters),
            "duration_seconds": Int(durationSeconds),
            "avg_pace_sec_per_km": Int(avgPaceSecondsPerKm),
            "tiles_claimed": tilesCount,
            "timestamp": Date().timeIntervalSince1970
        ])
    }
    
    // MARK: - Territory Events
    
    /// Log territory tile claim
    func logTileClaim(numTiles: Int, period: String, totalArea: Double? = nil) {
        var params: [String: Any] = [
            "num_tiles": numTiles,
            "period": period
        ]
        
        if let area = totalArea {
            params["total_area_sqm"] = Int(area)
        }
        
        logEvent("tile_claim", params: params)
    }
    
    // MARK: - Social & Sharing
    
    /// Log run share
    func logRunShare(channel: String, runId: String) {
        logEvent("run_share", params: [
            "channel": channel,
            "run_id": runId
        ])
    }
    
    // MARK: - HealthKit Events
    
    /// Log HealthKit connection
    func logHealthKitConnected() {
        logEvent("healthkit_connected", params: [
            "timestamp": Date().timeIntervalSince1970
        ])
    }
    
    // MARK: - Settings Events
    
    /// Log settings change
    func logSettingsChange(setting: String, newValue: String) {
        logEvent("settings_change", params: [
            "setting": setting,
            "new_value": newValue
        ])
    }
    
    // MARK: - Error Events
    
    /// Log error event
    func logError(context: String, error: Error) {
        logEvent("error", params: [
            "context": context,
            "error_description": error.localizedDescription,
            "error_domain": (error as NSError).domain,
            "error_code": (error as NSError).code
        ])
    }
    
    // MARK: - User Properties
    
    /// Set user property
    func setUserProperty(name: String, value: String?) {
        Analytics.setUserProperty(value, forName: name)
        #if DEBUG
        print("📊 User Property: \(name) = \(value ?? "nil")")
        #endif
    }
    
    /// Set user units preference
    func setUserUnits(_ units: String) {
        setUserProperty(name: "units", value: units)
    }
    
    /// Set user home city
    func setUserHomeCity(_ city: String) {
        setUserProperty(name: "home_city", value: city)
    }
    
    /// Set signup source
    func setSignupSource(_ source: String) {
        setUserProperty(name: "signup_source", value: source)
    }
    
    /// Set user ID for tracking
    func setUserId(_ userId: String?) {
        Analytics.setUserID(userId)
        #if DEBUG
        print("📊 User ID: \(userId ?? "nil")")
        #endif
    }
    
    // MARK: - Screen Tracking
    
    /// Log screen view
    func logScreenView(screenName: String, screenClass: String? = nil) {
        logEvent(AnalyticsEventScreenView, params: [
            AnalyticsParameterScreenName: screenName,
            AnalyticsParameterScreenClass: screenClass ?? screenName
        ])
    }
}
