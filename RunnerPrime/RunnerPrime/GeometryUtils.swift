//
//  GeometryUtils.swift
//  RunnerPrime
//
//  Geometry helpers: concave hull (k-NN alpha-shape style), polygon area (km²),
//  point-in-polygon, and polygon-rect intersection utilities.
//

import Foundation
import CoreLocation
import CoreGraphics

// MARK: - Public API

/// Computes a concave hull (alpha-shape style using k-nearest neighbors) from an unordered set of coordinates.
/// - Parameters:
///   - points: GPS coordinates of the route (unordered or ordered). Duplicates will be removed.
///   - k: Initial neighborhood size. Will increase up to a cap if hull invalid.
/// - Returns: Clockwise polygon coordinates representing the hull, or nil if cannot be computed.
public func computeConcaveHull(points: [CLLocationCoordinate2D], k: Int = 3) -> [CLLocationCoordinate2D]? {
    let unique = uniqueCoordinates(points)
    guard unique.count >= 3 else { return nil }

    var kValue = max(3, min(k, max(3, unique.count - 1)))
    let maxK = min(20, max(3, unique.count - 1))

    while kValue <= maxK {
        if let hull = buildConcaveHull(points: unique, k: kValue),
           isHullValid(hull: hull, contains: unique) {
            return hull
        }
        kValue += 1
    }
    return nil
}

/// Computes polygon area in square kilometers using local meter projection.
public func polygonAreaKm2(_ polygon: [CLLocationCoordinate2D]) -> Double {
    guard polygon.count >= 3 else { return 0 }
    let center = averageCoordinate(of: polygon)
    let projected = polygon.map { projectToLocalMeters(coord: $0, origin: center) }
    var areaM2: Double = 0
    for i in 0..<projected.count {
        let j = (i + 1) % projected.count
        areaM2 += projected[i].x * projected[j].y
        areaM2 -= projected[j].x * projected[i].y
    }
    areaM2 = abs(areaM2) / 2.0
    return areaM2 / 1_000_000.0
}

/// Point-in-polygon test using ray casting on local meter projection.
public func pointInPolygon(_ point: CLLocationCoordinate2D, polygon: [CLLocationCoordinate2D]) -> Bool {
    guard polygon.count >= 3 else { return false }
    let origin = averageCoordinate(of: polygon)
    let p = projectToLocalMeters(coord: point, origin: origin)
    let verts = polygon.map { projectToLocalMeters(coord: $0, origin: origin) }

    var inside = false
    var j = verts.count - 1
    for i in 0..<verts.count {
        let a = verts[i], b = verts[j]
        let intersect = ((a.y > p.y) != (b.y > p.y)) &&
        (p.x < (b.x - a.x) * (p.y - a.y) / ((b.y - a.y) == 0 ? 1e-9 : (b.y - a.y)) + a.x)
        if intersect { inside.toggle() }
        j = i
    }
    return inside
}

/// Checks if a polygon intersects a rectangle (both projected to a local plane).
/// - Note: Use for coarse tile intersection after projecting to local meters.
public func polygonIntersectsRect(polygon: [CGPoint], rect: CGRect) -> Bool {
    guard polygon.count >= 3 else { return false }

    // 1) Any polygon vertex inside rect
    for v in polygon {
        if rect.contains(v) { return true }
    }

    // 2) Any rect corner inside polygon
    let rectCorners = [
        CGPoint(x: rect.minX, y: rect.minY),
        CGPoint(x: rect.maxX, y: rect.minY),
        CGPoint(x: rect.maxX, y: rect.maxY),
        CGPoint(x: rect.minX, y: rect.maxY)
    ]
    if rectCorners.contains(where: { pointInPolygonLocal($0, polygon: polygon) }) {
        return true
    }

    // 3) Any edge intersection
    let rectEdges = [
        (rectCorners[0], rectCorners[1]),
        (rectCorners[1], rectCorners[2]),
        (rectCorners[2], rectCorners[3]),
        (rectCorners[3], rectCorners[0])
    ]
    for i in 0..<polygon.count {
        let a = polygon[i]
        let b = polygon[(i + 1) % polygon.count]
        for (p, q) in rectEdges {
            if segmentsIntersect(a, b, p, q) {
                return true
            }
        }
    }
    return false
}

// MARK: - Concave Hull (k-NN) Implementation

private func buildConcaveHull(points: [CLLocationCoordinate2D], k: Int) -> [CLLocationCoordinate2D]? {
    guard points.count >= 3 else { return nil }

    // Start at the point with lowest latitude (then lowest longitude)
    let pts = points
    let startIdx = pts.enumerated().min { lhs, rhs in
        if lhs.element.latitude == rhs.element.latitude {
            return lhs.element.longitude < rhs.element.longitude
        }
        return lhs.element.latitude < rhs.element.latitude
    }?.offset ?? 0
    let start = pts[startIdx]

    var hull: [CLLocationCoordinate2D] = [start]
    var current = start
    var prevAngle: Double = 0 // relative to +X axis in local plane
    // Track used indices if we later want to bias neighbor selection (not needed currently)

    // Limit iterations to prevent infinite loops
    let maxIterations = pts.count * 10
    var iterations = 0

    while iterations < maxIterations {
        iterations += 1

        // Find k nearest neighbors excluding already used if possible
        let neighbors = kNearestNeighbors(current, in: pts, k: k)

        // Sort by smallest right-turn angle relative to previous direction
        let candidates = neighbors.sorted { p1, p2 in
            let a1 = turnAngle(from: current, previousAngle: prevAngle, to: p1)
            let a2 = turnAngle(from: current, previousAngle: prevAngle, to: p2)
            return a1 < a2
        }

        var selected: CLLocationCoordinate2D?
        for cand in candidates {
            // Closing condition
            if hull.count > 2 && approximatelyEqual(cand, start) {
                selected = start
                break
            }

            // Prevent self-intersection
            if !wouldIntersectHull(hull: hull, nextPoint: cand) {
                selected = cand
                break
            }
        }

        guard let next = selected else { return nil }

        if approximatelyEqual(next, start) {
            // Close the hull
            if hull.count >= 3 { return hull }
            return nil
        } else {
            prevAngle = bearingAngle(from: current, to: next)
            hull.append(next)
            current = next
        }
    }
    return nil
}

private func isHullValid(hull: [CLLocationCoordinate2D], contains points: [CLLocationCoordinate2D]) -> Bool {
    guard hull.count >= 3 else { return false }
    // Ensure most points lie inside the hull; allow a few outliers
    let origin = averageCoordinate(of: hull)
    let polyLocal = hull.map { projectToLocalMeters(coord: $0, origin: origin) }
    let total = points.count
    var insideCount = 0
    for p in points {
        if pointInPolygonLocal(projectToLocalMeters(coord: p, origin: origin), polygon: polyLocal) {
            insideCount += 1
        }
    }
    // At least 80% of points inside
    return insideCount >= Int(Double(total) * 0.8)
}

// MARK: - Helpers (Geometry)

private func uniqueCoordinates(_ points: [CLLocationCoordinate2D]) -> [CLLocationCoordinate2D] {
    var seen = Set<String>()
    var result: [CLLocationCoordinate2D] = []
    result.reserveCapacity(points.count)
    for p in points {
        let key = String(format: "%.6f,%.6f", p.latitude, p.longitude)
        if !seen.contains(key) {
            seen.insert(key)
            result.append(p)
        }
    }
    return result
}

private func kNearestNeighbors(_ point: CLLocationCoordinate2D, in points: [CLLocationCoordinate2D], k: Int) -> [CLLocationCoordinate2D] {
    let origin = point
    let sorted = points.filter { !approximatelyEqual($0, origin) }
        .sorted { distanceMeters(origin, $0) < distanceMeters(origin, $1) }
    return Array(sorted.prefix(k))
}

private func distanceMeters(_ a: CLLocationCoordinate2D, _ b: CLLocationCoordinate2D) -> Double {
    // Use haversine via CLLocation
    let la = CLLocation(latitude: a.latitude, longitude: a.longitude)
    let lb = CLLocation(latitude: b.latitude, longitude: b.longitude)
    return la.distance(from: lb)
}

private func bearingAngle(from a: CLLocationCoordinate2D, to b: CLLocationCoordinate2D) -> Double {
    // Project to local meters to compute planar angle
    let origin = a
    let p0 = projectToLocalMeters(coord: a, origin: origin)
    let p1 = projectToLocalMeters(coord: b, origin: origin)
    let dx = p1.x - p0.x
    let dy = p1.y - p0.y
    var theta = atan2(dy, dx) // [-pi, pi]
    if theta < 0 { theta += 2 * .pi }
    return theta
}

private func turnAngle(from current: CLLocationCoordinate2D, previousAngle: Double, to next: CLLocationCoordinate2D) -> Double {
    let angle = bearingAngle(from: current, to: next)
    var diff = angle - previousAngle
    while diff <= 0 { diff += 2 * .pi }
    return diff
}

private func wouldIntersectHull(hull: [CLLocationCoordinate2D], nextPoint: CLLocationCoordinate2D) -> Bool {
    guard hull.count >= 2 else { return false }
    let a1 = hull[hull.count - 1]
    let a2 = nextPoint

    // Check against all non-adjacent edges
    for i in 0..<(hull.count - 2) {
        let b1 = hull[i]
        let b2 = hull[i + 1]
        if segmentsIntersectLocal(a1, a2, b1, b2) {
            return true
        }
    }
    return false
}

private func segmentsIntersectLocal(_ a1: CLLocationCoordinate2D, _ a2: CLLocationCoordinate2D, _ b1: CLLocationCoordinate2D, _ b2: CLLocationCoordinate2D) -> Bool {
    let origin = a1
    let p1 = projectToLocalMeters(coord: a1, origin: origin)
    let q1 = projectToLocalMeters(coord: a2, origin: origin)
    let p2 = projectToLocalMeters(coord: b1, origin: origin)
    let q2 = projectToLocalMeters(coord: b2, origin: origin)
    return segmentsIntersect(p1, q1, p2, q2)
}

private func segmentsIntersect(_ p1: CGPoint, _ q1: CGPoint, _ p2: CGPoint, _ q2: CGPoint) -> Bool {
    func orientation(_ a: CGPoint, _ b: CGPoint, _ c: CGPoint) -> Int {
        let val = (b.y - a.y) * (c.x - b.x) - (b.x - a.x) * (c.y - b.y)
        if abs(val) < 1e-9 { return 0 }
        return val > 0 ? 1 : 2 // 1: clockwise, 2: counterclockwise
    }
    func onSegment(_ a: CGPoint, _ b: CGPoint, _ c: CGPoint) -> Bool {
        return min(a.x, c.x) - 1e-9 <= b.x && b.x <= max(a.x, c.x) + 1e-9 &&
               min(a.y, c.y) - 1e-9 <= b.y && b.y <= max(a.y, c.y) + 1e-9
    }

    let o1 = orientation(p1, q1, p2)
    let o2 = orientation(p1, q1, q2)
    let o3 = orientation(p2, q2, p1)
    let o4 = orientation(p2, q2, q1)

    if o1 != o2 && o3 != o4 { return true }
    if o1 == 0 && onSegment(p1, p2, q1) { return true }
    if o2 == 0 && onSegment(p1, q2, q1) { return true }
    if o3 == 0 && onSegment(p2, p1, q2) { return true }
    if o4 == 0 && onSegment(p2, q1, q2) { return true }
    return false
}

private func pointInPolygonLocal(_ p: CGPoint, polygon: [CGPoint]) -> Bool {
    var inside = false
    var j = polygon.count - 1
    for i in 0..<polygon.count {
        let a = polygon[i], b = polygon[j]
        let intersect = ((a.y > p.y) != (b.y > p.y)) &&
        (p.x < (b.x - a.x) * (p.y - a.y) / ((b.y - a.y) == 0 ? 1e-9 : (b.y - a.y)) + a.x)
        if intersect { inside.toggle() }
        j = i
    }
    return inside
}

private func approximatelyEqual(_ a: CLLocationCoordinate2D, _ b: CLLocationCoordinate2D, eps: Double = 1e-6) -> Bool {
    return abs(a.latitude - b.latitude) < eps && abs(a.longitude - b.longitude) < eps
}

// MARK: - Projection Helpers

private func averageCoordinate(of coords: [CLLocationCoordinate2D]) -> CLLocationCoordinate2D {
    let sumLat = coords.reduce(0.0) { $0 + $1.latitude }
    let sumLon = coords.reduce(0.0) { $0 + $1.longitude }
    return CLLocationCoordinate2D(latitude: sumLat / Double(coords.count), longitude: sumLon / Double(coords.count))
}

/// Web Mercator-like local projection to meters relative to an origin.
private func projectToLocalMeters(coord: CLLocationCoordinate2D, origin: CLLocationCoordinate2D) -> CGPoint {
    // Convert degrees to meters (approx) around the origin using equirectangular approximation
    let metersPerDegLat = 111_132.92
    let metersPerDegLon = 111_132.92 * cos(origin.latitude * .pi / 180.0)
    let x = (coord.longitude - origin.longitude) * metersPerDegLon
    let y = (coord.latitude - origin.latitude) * metersPerDegLat
    return CGPoint(x: x, y: y)
}


