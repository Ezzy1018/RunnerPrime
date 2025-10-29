//
//  TileIndexUtils.swift
//  RunnerPrime
//
//  Created by Ankit Yadav on 10/29/25.
//

import Foundation
import CoreLocation

/// Utilities to support tile computations, conversions, and simple bounds math.
public enum TileIndexUtils {
    /// Returns a human-readable area string in km² with two decimals.
    public static func areaStringSquareKm(fromSquareMeters areaM2: Double) -> String {
        let km2 = areaM2 / 1_000_000.0
        return String(format: "%.2f km²", km2)
    }

    /// Builds a bounding box around a center coordinate in meters (approximate, using local meters/degree at latitude).
    public static func boundingBox(center: CLLocationCoordinate2D, halfSizeMeters: Double) -> (minLat: Double, minLon: Double, maxLat: Double, maxLon: Double) {
        let metersPerDegLat = 111_320.0
        let metersPerDegLon = 111_320.0 * cos(center.latitude * .pi / 180.0)
        let dLat = halfSizeMeters / metersPerDegLat
        let dLon = halfSizeMeters / metersPerDegLon
        return (center.latitude - dLat, center.longitude - dLon, center.latitude + dLat, center.longitude + dLon)
    }
}
