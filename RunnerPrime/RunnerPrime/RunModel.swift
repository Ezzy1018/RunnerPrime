//
//  RunModel.swift
//  RunnerPrime
//
//  Created by Ankit Yadav on 10/29/25.
//

import Foundation
import CoreLocation

public struct RunPoint: Codable {
    public var latitude: Double
    public var longitude: Double
    public var timestamp: TimeInterval
    
    public init(latitude: Double, longitude: Double, timestamp: TimeInterval) {
        self.latitude = latitude
        self.longitude = longitude
        self.timestamp = timestamp
    }
}

public struct RunModel: Codable, Identifiable {
    public var id: String = UUID().uuidString
    public var startTime: Date
    public var endTime: Date?
    public var points: [RunPoint] = []
    public var distance: Double = 0 // meters
    public var duration: TimeInterval = 0
    
    public init(startTime: Date) {
        self.startTime = startTime
    }

    mutating func finalize() {
        if let end = endTime {
            duration = end.timeIntervalSince(startTime)
        }
        distance = computeDistance()
    }

    func computeDistance() -> Double {
        guard points.count >= 2 else { return 0 }
        var total: Double = 0
        for i in 1..<points.count {
            let a = CLLocation(latitude: points[i-1].latitude, longitude: points[i-1].longitude)
            let b = CLLocation(latitude: points[i].latitude, longitude: points[i].longitude)
            total += a.distance(from: b)
        }
        return total
    }

    var durationString: String {
        let total = Int(duration)
        let hrs = total / 3600
        let mins = (total % 3600) / 60
        let secs = total % 60
        return String(format: "%02d:%02d:%02d", hrs, mins, secs)
    }
}
