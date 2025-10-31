//
//  TileEngine.swift
//  RunnerPrime
//
//  Created by Ankit Yadav on 10/29/25.
//

import Foundation
import CoreLocation
import CoreGraphics

/// TileEngine maps geographic coordinates to a fixed-size square grid (default 100m x 100m)
/// using a Web Mercator projection (EPSG:3857) for stable, global indexing.
///
/// Notes:
/// - This MVP approach is consistent and fast. It is sufficient for 100m tiles.
/// - We can swap the tiling scheme later (e.g., H3) without changing call sites.
public struct TileEngine {
    public let tileSizeMeters: Double

    /// Earth radius used for Web Mercator projection (meters)
    private let earthRadius: Double = 6_378_137.0

    public init(tileSizeMeters: Double = 100) {
        self.tileSizeMeters = tileSizeMeters
    }

    // MARK: - Public API

    /// Returns a stable string tile identifier for a given latitude/longitude.
    /// Format: "x_y" where x and y are tile grid coordinates in Mercator meters divided by tile size.
    public func latLngToTileId(latitude: Double, longitude: Double) -> String {
        let (mx, my) = mercatorMeters(lat: latitude, lon: longitude)
        let tx = Int(floor(mx / tileSizeMeters))
        let ty = Int(floor(my / tileSizeMeters))
        return "\(tx)_\(ty)"
    }

    /// Computes the unique set of tile IDs traversed by the given run points.
    /// Requires RunPoint type to be available in the module.
    public func tilesForRun(points: [RunPoint]) -> Set<String> {
        var tiles: Set<String> = []
        tiles.reserveCapacity(points.count)
        for p in points {
            tiles.insert(latLngToTileId(latitude: p.latitude, longitude: p.longitude))
        }
        return tiles
    }

    /// Computes the unique set of tile IDs traversed by an array of coordinates.
    public func tilesForCoordinates(_ coords: [CLLocationCoordinate2D]) -> Set<String> {
        var tiles: Set<String> = []
        tiles.reserveCapacity(coords.count)
        for c in coords {
            tiles.insert(latLngToTileId(latitude: c.latitude, longitude: c.longitude))
        }
        return tiles
    }

    /// Computes total area in square meters for a set of tiles.
    public func areaForTiles(_ tiles: Set<String>) -> Double {
        return Double(tiles.count) * tileSizeMeters * tileSizeMeters
    }

    // MARK: - Web Mercator helpers

    /// Converts latitude/longitude (degrees) to Web Mercator meters (EPSG:3857).
    private func mercatorMeters(lat: Double, lon: Double) -> (x: Double, y: Double) {
        let clampedLat = min(max(lat, -85.05112878), 85.05112878) // clamp to Mercator valid range
        let x = degreesToRadians(lon) * earthRadius
        let y = log(tan(.pi / 4 + degreesToRadians(clampedLat) / 2)) * earthRadius
        return (x, y)
    }

    private func degreesToRadians(_ deg: Double) -> Double { deg * .pi / 180.0 }
    
    // MARK: - High-level Run Processing
    
    /// Processes a complete run and returns territory information
    public func processRun(_ run: RunModel) -> TerritoryInfo {
        let tiles = tilesForRun(points: run.points)
        let area = areaForTiles(tiles)
        
        return TerritoryInfo(
            tileIds: tiles,
            tileCount: tiles.count,
            totalAreaSquareMeters: area
        )
    }

    /// Processes a run with an optional coverage polygon (concave hull) and returns territory information.
    /// Merges traversed tiles with interior tiles if the polygon meets sanity thresholds.
    public func processRun(_ run: RunModel, polygon: [CLLocationCoordinate2D]?) -> TerritoryInfo {
        var combined: Set<String> = tilesForRun(points: run.points)

        if let poly = polygon, poly.count >= 3 {
            // Sanity: require minimum area and vertices to avoid noise
            let areaKm2 = polygonAreaKm2(poly)
            if areaKm2 >= 0.005 { // ~5,000 m²
                let interior = tilesInsidePolygon(poly)
                combined.formUnion(interior)
            }
        }
        let area = areaForTiles(combined)
        return TerritoryInfo(
            tileIds: combined,
            tileCount: combined.count,
            totalAreaSquareMeters: area
        )
    }

    /// Computes all tiles whose squares intersect the given polygon.
    /// Polygon is given in lat/lon; we project to a Web-Mercator-like meter plane for efficient iteration.
    public func tilesInsidePolygon(_ polygon: [CLLocationCoordinate2D]) -> Set<String> {
        guard polygon.count >= 3 else { return [] }

        // Project polygon to meters (Web Mercator approximation)
        let projected: [CGPoint] = polygon.map { coord in
            let (mx, my) = mercatorMeters(lat: coord.latitude, lon: coord.longitude)
            return CGPoint(x: mx, y: my)
        }

        // Bounding box in tile coordinates
        let xs = projected.map { $0.x }
        let ys = projected.map { $0.y }
        guard let minX = xs.min(), let maxX = xs.max(), let minY = ys.min(), let maxY = ys.max() else {
            return []
        }

        let minTileX = Int(floor(minX / tileSizeMeters))
        let maxTileX = Int(floor(maxX / tileSizeMeters))
        let minTileY = Int(floor(minY / tileSizeMeters))
        let maxTileY = Int(floor(maxY / tileSizeMeters))

        var inside: Set<String> = []
        inside.reserveCapacity((maxTileX - minTileX + 1) * (maxTileY - minTileY + 1))

        for tx in minTileX...maxTileX {
            for ty in minTileY...maxTileY {
                let rect = CGRect(
                    x: Double(tx) * tileSizeMeters,
                    y: Double(ty) * tileSizeMeters,
                    width: tileSizeMeters,
                    height: tileSizeMeters
                )
                if polygonIntersectsRect(polygon: projected, rect: rect) {
                    inside.insert("\(tx)_\(ty)")
                }
            }
        }
        return inside
    }
}

// MARK: - Territory Info Model

/// Information about territory claimed during a run
public struct TerritoryInfo {
    public let tileIds: Set<String>
    public let tileCount: Int
    public let totalAreaSquareMeters: Double
    
    public var totalAreaSquareKilometers: Double {
        return totalAreaSquareMeters / 1_000_000.0
    }
    
    public var areaDisplayString: String {
        if totalAreaSquareMeters < 1000 {
            return String(format: "%.0f m²", totalAreaSquareMeters)
        } else if totalAreaSquareKilometers < 1.0 {
            return String(format: "%.0f m²", totalAreaSquareMeters)
        } else {
            return String(format: "%.2f km²", totalAreaSquareKilometers)
        }
    }
    
    public init(tileIds: Set<String>, tileCount: Int, totalAreaSquareMeters: Double) {
        self.tileIds = tileIds
        self.tileCount = tileCount
        self.totalAreaSquareMeters = totalAreaSquareMeters
    }
}
