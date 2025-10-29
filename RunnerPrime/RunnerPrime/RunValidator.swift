//
//  RunValidator.swift
//  RunnerPrime
//
//  Created by Ankit Yadav on 10/29/25.
//

import Foundation
import CoreLocation

/// RunValidator provides client-side validation and anti-cheat measures
/// Analyzes run data for anomalies before upload to maintain data integrity
struct RunValidator {
    
    // MARK: - Validation Thresholds
    
    private static let maxHumanSpeed: Double = 12.0 // m/s (~43 km/h)
    private static let minRunDistance: Double = 10.0 // 10 meters minimum
    private static let maxTimeGap: TimeInterval = 300 // 5 minutes max gap
    private static let maxInstantaneousJump: Double = 200.0 // 200 meters max jump
    private static let minAccuracy: Double = 50.0 // 50 meters max GPS accuracy accepted
    private static let maxElevationGain: Double = 50.0 // 50m elevation gain per km (mountainous)
    
    /// Comprehensive validation result
    struct ValidationResult {
        let isValid: Bool
        let confidence: Double // 0.0 to 1.0
        let anomalies: [ValidationAnomaly]
        let statistics: RunStatistics
        
        var shouldUpload: Bool {
            return isValid && confidence >= 0.7
        }
    }
    
    /// Types of validation anomalies
    enum ValidationAnomaly {
        case excessiveSpeed(maxSpeed: Double, location: CLLocationCoordinate2D)
        case unrealisticJump(distance: Double, timeGap: TimeInterval)
        case tooShortDistance(distance: Double)
        case suspiciousTimeGaps(gaps: [TimeInterval])
        case poorGPSAccuracy(averageAccuracy: Double)
        case impossibleElevationGain(gain: Double)
        case staticRun(movementVariance: Double)
        case duplicatePoints(count: Int)
        
        var description: String {
            switch self {
            case .excessiveSpeed(let speed, _):
                return "Excessive speed detected: \(String(format: "%.1f", speed * 3.6)) km/h"
            case .unrealisticJump(let distance, let time):
                return "Unrealistic jump: \(Int(distance))m in \(Int(time))s"
            case .tooShortDistance(let distance):
                return "Run too short: \(Int(distance))m"
            case .suspiciousTimeGaps(let gaps):
                return "Suspicious time gaps: \(gaps.count) gaps > 5min"
            case .poorGPSAccuracy(let accuracy):
                return "Poor GPS accuracy: \(Int(accuracy))m average"
            case .impossibleElevationGain(let gain):
                return "Impossible elevation gain: \(Int(gain))m/km"
            case .staticRun(let variance):
                return "Static run detected: variance \(String(format: "%.2f", variance))"
            case .duplicatePoints(let count):
                return "Duplicate GPS points: \(count) duplicates"
            }
        }
        
        var severity: AnomalySeverity {
            switch self {
            case .excessiveSpeed, .unrealisticJump:
                return .critical
            case .tooShortDistance, .impossibleElevationGain:
                return .high
            case .suspiciousTimeGaps, .poorGPSAccuracy, .staticRun:
                return .medium
            case .duplicatePoints:
                return .low
            }
        }
    }
    
    enum AnomalySeverity: Int, CaseIterable {
        case low = 1, medium = 2, high = 3, critical = 4
    }
    
    /// Run statistics computed during validation
    struct RunStatistics {
        let averageSpeed: Double // m/s
        let maxSpeed: Double // m/s
        let speedVariance: Double
        let averageAccuracy: Double // meters
        let totalTimeGaps: TimeInterval
        let movementVariance: Double
        let elevationGain: Double // meters
        let samplingRate: Double // points per minute
    }
    
    // MARK: - Main Validation Function
    
    /// Validates a completed run and returns detailed analysis
    static func validate(_ run: RunModel) -> ValidationResult {
        var anomalies: [ValidationAnomaly] = []
        
        // Basic validation checks
        guard run.points.count >= 2 else {
            anomalies.append(.tooShortDistance(distance: 0))
            return ValidationResult(
                isValid: false,
                confidence: 0.0,
                anomalies: anomalies,
                statistics: RunStatistics.empty
            )
        }
        
        // Compute run statistics
        let statistics = computeStatistics(for: run)
        
        // Perform validation checks
        checkDistance(run, statistics: statistics, anomalies: &anomalies)
        checkSpeed(run, statistics: statistics, anomalies: &anomalies)
        checkTimeGaps(run, anomalies: &anomalies)
        checkJumps(run, anomalies: &anomalies)
        checkGPSAccuracy(run, statistics: statistics, anomalies: &anomalies)
        checkMovement(run, statistics: statistics, anomalies: &anomalies)
        checkDuplicates(run, anomalies: &anomalies)
        
        // Calculate confidence score
        let confidence = calculateConfidence(anomalies: anomalies, statistics: statistics)
        let isValid = anomalies.filter { $0.severity == .critical }.isEmpty
        
        return ValidationResult(
            isValid: isValid,
            confidence: confidence,
            anomalies: anomalies,
            statistics: statistics
        )
    }
    
    // MARK: - Individual Validation Checks
    
    private static func checkDistance(_ run: RunModel, statistics: RunStatistics, anomalies: inout [ValidationAnomaly]) {
        if run.distance < minRunDistance {
            anomalies.append(.tooShortDistance(distance: run.distance))
        }
    }
    
    private static func checkSpeed(_ run: RunModel, statistics: RunStatistics, anomalies: inout [ValidationAnomaly]) {
        if statistics.maxSpeed > maxHumanSpeed {
            // Find the location where max speed occurred
            var maxSpeedLocation = run.points.first!
            var maxDetectedSpeed: Double = 0
            
            for i in 1..<run.points.count {
                let p1 = run.points[i-1]
                let p2 = run.points[i]
                let distance = CLLocation(latitude: p1.latitude, longitude: p1.longitude)
                    .distance(from: CLLocation(latitude: p2.latitude, longitude: p2.longitude))
                let time = p2.timestamp - p1.timestamp
                
                if time > 0 {
                    let speed = distance / time
                    if speed > maxDetectedSpeed {
                        maxDetectedSpeed = speed
                        maxSpeedLocation = p2
                    }
                }
            }
            
            anomalies.append(.excessiveSpeed(
                maxSpeed: maxDetectedSpeed,
                location: CLLocationCoordinate2D(latitude: maxSpeedLocation.latitude, longitude: maxSpeedLocation.longitude)
            ))
        }
    }
    
    private static func checkTimeGaps(_ run: RunModel, anomalies: inout [ValidationAnomaly]) {
        var suspiciousGaps: [TimeInterval] = []
        
        for i in 1..<run.points.count {
            let timeGap = run.points[i].timestamp - run.points[i-1].timestamp
            if timeGap > maxTimeGap {
                suspiciousGaps.append(timeGap)
            }
        }
        
        if !suspiciousGaps.isEmpty {
            anomalies.append(.suspiciousTimeGaps(gaps: suspiciousGaps))
        }
    }
    
    private static func checkJumps(_ run: RunModel, anomalies: inout [ValidationAnomaly]) {
        for i in 1..<run.points.count {
            let p1 = run.points[i-1]
            let p2 = run.points[i]
            let distance = CLLocation(latitude: p1.latitude, longitude: p1.longitude)
                .distance(from: CLLocation(latitude: p2.latitude, longitude: p2.longitude))
            let time = p2.timestamp - p1.timestamp
            
            // Check for impossible jumps
            if distance > maxInstantaneousJump && time < 60 {
                anomalies.append(.unrealisticJump(distance: distance, timeGap: time))
            }
        }
    }
    
    private static func checkGPSAccuracy(_ run: RunModel, statistics: RunStatistics, anomalies: inout [ValidationAnomaly]) {
        if statistics.averageAccuracy > minAccuracy {
            anomalies.append(.poorGPSAccuracy(averageAccuracy: statistics.averageAccuracy))
        }
    }
    
    private static func checkMovement(_ run: RunModel, statistics: RunStatistics, anomalies: inout [ValidationAnomaly]) {
        // Check if the runner actually moved (not just GPS drift)
        if statistics.movementVariance < 0.0001 && run.distance > 100 {
            anomalies.append(.staticRun(movementVariance: statistics.movementVariance))
        }
    }
    
    private static func checkDuplicates(_ run: RunModel, anomalies: inout [ValidationAnomaly]) {
        let uniquePoints = Set(run.points.map { "\($0.latitude),\($0.longitude),\($0.timestamp)" })
        let duplicateCount = run.points.count - uniquePoints.count
        
        if duplicateCount > run.points.count / 10 { // More than 10% duplicates
            anomalies.append(.duplicatePoints(count: duplicateCount))
        }
    }
    
    // MARK: - Statistics Computation
    
    private static func computeStatistics(for run: RunModel) -> RunStatistics {
        guard run.points.count >= 2 else {
            return RunStatistics.empty
        }
        
        var speeds: [Double] = []
        var accuracies: [Double] = []
        var timeGaps: [TimeInterval] = []
        
        var totalDistance: Double = 0
        var latitudes: [Double] = []
        var longitudes: [Double] = []
        
        for i in 1..<run.points.count {
            let p1 = run.points[i-1]
            let p2 = run.points[i]
            
            // Calculate distance and speed
            let distance = CLLocation(latitude: p1.latitude, longitude: p1.longitude)
                .distance(from: CLLocation(latitude: p2.latitude, longitude: p2.longitude))
            let time = p2.timestamp - p1.timestamp
            
            totalDistance += distance
            latitudes.append(p2.latitude)
            longitudes.append(p2.longitude)
            
            if time > 0 {
                let speed = distance / time
                speeds.append(speed)
                timeGaps.append(time)
            }
            
            // Simulate accuracy (in real implementation, would come from CLLocation)
            accuracies.append(Double.random(in: 3...15))
        }
        
        let averageSpeed = speeds.isEmpty ? 0 : speeds.reduce(0, +) / Double(speeds.count)
        let maxSpeed = speeds.max() ?? 0
        let speedVariance = calculateVariance(speeds)
        let averageAccuracy = accuracies.isEmpty ? 0 : accuracies.reduce(0, +) / Double(accuracies.count)
        let totalTimeGaps = timeGaps.filter { $0 > maxTimeGap }.reduce(0, +)
        let movementVariance = calculateVariance(latitudes) + calculateVariance(longitudes)
        let samplingRate = Double(run.points.count) / (run.duration / 60) // points per minute
        
        return RunStatistics(
            averageSpeed: averageSpeed,
            maxSpeed: maxSpeed,
            speedVariance: speedVariance,
            averageAccuracy: averageAccuracy,
            totalTimeGaps: totalTimeGaps,
            movementVariance: movementVariance,
            elevationGain: 0, // Would need elevation data
            samplingRate: samplingRate
        )
    }
    
    private static func calculateVariance(_ values: [Double]) -> Double {
        guard values.count > 1 else { return 0 }
        
        let mean = values.reduce(0, +) / Double(values.count)
        let sumSquaredDiffs = values.reduce(0) { sum, value in
            sum + pow(value - mean, 2)
        }
        
        return sumSquaredDiffs / Double(values.count - 1)
    }
    
    // MARK: - Confidence Calculation
    
    private static func calculateConfidence(anomalies: [ValidationAnomaly], statistics: RunStatistics) -> Double {
        var confidence: Double = 1.0
        
        // Reduce confidence based on anomaly severity
        for anomaly in anomalies {
            switch anomaly.severity {
            case .critical:
                confidence -= 0.5
            case .high:
                confidence -= 0.3
            case .medium:
                confidence -= 0.15
            case .low:
                confidence -= 0.05
            }
        }
        
        // Adjust confidence based on GPS accuracy
        if statistics.averageAccuracy > 20 {
            confidence -= 0.2
        }
        
        // Adjust confidence based on sampling rate
        if statistics.samplingRate < 1 { // Less than 1 point per minute
            confidence -= 0.1
        }
        
        // Ensure confidence stays in valid range
        return max(0.0, min(1.0, confidence))
    }
}

// MARK: - Extensions

extension RunValidator.RunStatistics {
    static let empty = RunValidator.RunStatistics(
        averageSpeed: 0,
        maxSpeed: 0,
        speedVariance: 0,
        averageAccuracy: 0,
        totalTimeGaps: 0,
        movementVariance: 0,
        elevationGain: 0,
        samplingRate: 0
    )
    
    /// Human-readable pace string (min/km)
    var paceString: String {
        guard averageSpeed > 0 else { return "--:--" }
        let paceSecondsPerMeter = 1.0 / averageSpeed
        let paceSecondsPerKm = paceSecondsPerMeter * 1000
        let minutes = Int(paceSecondsPerKm) / 60
        let seconds = Int(paceSecondsPerKm) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    /// Human-readable average speed (km/h)
    var speedKmh: Double {
        return averageSpeed * 3.6
    }
}