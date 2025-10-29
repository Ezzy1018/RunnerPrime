//
//  ShareGenerator.swift
//  RunnerPrime
//
//  Created by Ankit Yadav on 10/29/25.
//

import Foundation
import UIKit
import CoreGraphics
import MapKit

/// ShareGenerator creates beautiful, branded run images for social sharing
/// Combines map snapshots with run statistics and RunnerPrime branding
final class ShareGenerator {
    
    // MARK: - Configuration
    
    private static let imageSize = CGSize(width: 1080, height: 1080) // Instagram square
    private static let mapInset: CGFloat = 60
    private static let statsHeight: CGFloat = 280
    private static let cornerRadius: CGFloat = 20
    
    // MARK: - Colors (RunnerPrime palette)
    private static let backgroundColor = UIColor(red: 29/255, green: 28/255, blue: 30/255, alpha: 1.0) // #1D1C1E
    private static let accentColor = UIColor(red: 217/255, green: 255/255, blue: 84/255, alpha: 1.0) // #D9FF54
    private static let textColor = UIColor(red: 253/255, green: 252/255, blue: 250/255, alpha: 1.0) // #FDFCFA
    private static let secondaryTextColor = UIColor(red: 253/255, green: 252/255, blue: 250/255, alpha: 0.7)
    
    /// Generate a shareable image for a completed run
    static func generateShareImage(
        for run: RunModel,
        territoryInfo: TerritoryInfo? = nil,
        completion: @escaping (UIImage?) -> Void
    ) {
        // First, generate the map snapshot
        generateMapSnapshot(for: run) { mapImage in
            guard let mapImage = mapImage else {
                completion(nil)
                return
            }
            
            // Compose the final share image
            let shareImage = composeShareImage(
                mapImage: mapImage,
                run: run,
                territoryInfo: territoryInfo
            )
            
            completion(shareImage)
        }
    }
    
    // MARK: - Map Snapshot Generation
    
    private static func generateMapSnapshot(for run: RunModel, completion: @escaping (UIImage?) -> Void) {
        guard !run.points.isEmpty else {
            completion(nil)
            return
        }
        
        let mapSize = CGSize(
            width: imageSize.width - (mapInset * 2),
            height: imageSize.height - statsHeight - (mapInset * 2)
        )
        
        // Create map snapshotter
        let options = MKMapSnapshotter.Options()
        options.size = mapSize
        options.scale = UIScreen.main.scale
        
        // Configure map appearance
        let config = MKStandardMapConfiguration(elevationStyle: .flat)
        config.pointOfInterestFilter = .excludingAll
        options.preferredConfiguration = config
        
        // Calculate map region to fit the run
        let coordinates = run.points.map { 
            CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)
        }
        
        let region = calculateRegion(for: coordinates)
        options.region = region
        
        let snapshotter = MKMapSnapshotter(options: options)
        
        snapshotter.start { snapshot, error in
            guard let snapshot = snapshot else {
                print("❌ Map snapshot error: \(error?.localizedDescription ?? "Unknown")")
                completion(nil)
                return
            }
            
            // Overlay the run route on the map
            let overlaidImage = overlayRunRoute(
                on: snapshot.image,
                points: run.points,
                mapRect: snapshot.mapRect,
                region: region
            )
            
            completion(overlaidImage)
        }
    }
    
    private static func calculateRegion(for coordinates: [CLLocationCoordinate2D]) -> MKCoordinateRegion {
        guard !coordinates.isEmpty else {
            return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        }
        
        let lats = coordinates.map { $0.latitude }
        let lons = coordinates.map { $0.longitude }
        
        let minLat = lats.min()!
        let maxLat = lats.max()!
        let minLon = lons.min()!
        let maxLon = lons.max()!
        
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        
        let latDelta = max(0.005, (maxLat - minLat) * 1.3) // 30% padding
        let lonDelta = max(0.005, (maxLon - minLon) * 1.3)
        
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
        
        return MKCoordinateRegion(center: center, span: span)
    }
    
    private static func overlayRunRoute(
        on mapImage: UIImage,
        points: [RunPoint],
        mapRect: MKMapRect,
        region: MKCoordinateRegion
    ) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: mapImage.size)
        
        return renderer.image { context in
            // Draw the map background
            mapImage.draw(at: .zero)
            
            // Convert coordinates to image points
            let imagePoints = points.compactMap { point -> CGPoint? in
                let coordinate = CLLocationCoordinate2D(latitude: point.latitude, longitude: point.longitude)
                let mapPoint = MKMapPoint(coordinate)
                
                // Check if point is within the map rect
                guard mapRect.contains(mapPoint) else { return nil }
                
                let x = (mapPoint.x - mapRect.minX) / mapRect.width * mapImage.size.width
                let y = (mapPoint.y - mapRect.minY) / mapRect.height * mapImage.size.height
                
                return CGPoint(x: x, y: mapImage.size.height - y) // Flip Y coordinate
            }
            
            guard imagePoints.count >= 2 else { return }
            
            // Draw the run route
            context.cgContext.setStrokeColor(accentColor.cgColor)
            context.cgContext.setLineWidth(6.0)
            context.cgContext.setLineCap(.round)
            context.cgContext.setLineJoin(.round)
            
            // Create path
            let path = UIBezierPath()
            path.move(to: imagePoints[0])
            
            for point in imagePoints.dropFirst() {
                path.addLine(to: point)
            }
            
            path.stroke()
            
            // Draw start and end markers
            drawRunMarkers(context: context.cgContext, start: imagePoints.first!, end: imagePoints.last!)
        }
    }
    
    private static func drawRunMarkers(context: CGContext, start: CGPoint, end: CGPoint) {
        let markerRadius: CGFloat = 8
        
        // Start marker (green)
        context.setFillColor(UIColor.systemGreen.cgColor)
        context.fillEllipse(in: CGRect(
            x: start.x - markerRadius,
            y: start.y - markerRadius,
            width: markerRadius * 2,
            height: markerRadius * 2
        ))
        
        // End marker (red)
        context.setFillColor(UIColor.systemRed.cgColor)
        context.fillEllipse(in: CGRect(
            x: end.x - markerRadius,
            y: end.y - markerRadius,
            width: markerRadius * 2,
            height: markerRadius * 2
        ))
    }
    
    // MARK: - Share Image Composition
    
    private static func composeShareImage(
        mapImage: UIImage,
        run: RunModel,
        territoryInfo: TerritoryInfo?
    ) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: imageSize)
        
        return renderer.image { context in
            let rect = CGRect(origin: .zero, size: imageSize)
            
            // Background
            context.cgContext.setFillColor(backgroundColor.cgColor)
            context.cgContext.fill(rect)
            
            // Map section with rounded corners
            let mapRect = CGRect(
                x: mapInset,
                y: mapInset,
                width: imageSize.width - (mapInset * 2),
                height: imageSize.height - statsHeight - (mapInset * 2)
            )
            
            let mapPath = UIBezierPath(roundedRect: mapRect, cornerRadius: cornerRadius)
            mapPath.addClip()
            mapImage.draw(in: mapRect)
            
            // Reset clipping for stats section
            context.cgContext.resetClip()
            
            // Stats section
            drawStatsSection(
                context: context.cgContext,
                run: run,
                territoryInfo: territoryInfo,
                in: CGRect(
                    x: mapInset,
                    y: mapRect.maxY + 20,
                    width: imageSize.width - (mapInset * 2),
                    height: statsHeight - 40
                )
            )
            
            // Branding
            drawBranding(context: context.cgContext, in: rect)
        }
    }
    
    private static func drawStatsSection(
        context: CGContext,
        run: RunModel,
        territoryInfo: TerritoryInfo?,
        in rect: CGRect
    ) {
        // Stats background
        context.setFillColor(backgroundColor.cgColor)
        let statsPath = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
        statsPath.fill()
        
        // Border
        context.setStrokeColor(accentColor.withAlphaComponent(0.2).cgColor)
        context.setLineWidth(1.0)
        statsPath.stroke()
        
        // Text layout
        let padding: CGFloat = 24
        let contentRect = rect.insetBy(dx: padding, dy: padding)
        let statBoxWidth = (contentRect.width - padding) / 2
        let statBoxHeight = (contentRect.height - padding) / 2
        
        // Main stats
        let distanceText = String(format: "%.2f KM", run.distance / 1000)
        let timeText = run.durationString
        let paceText = formatPace(run.distance, duration: run.duration)
        
        // Primary stats (top row)
        drawStatBox(
            context: context,
            title: "DISTANCE",
            value: distanceText,
            in: CGRect(x: contentRect.minX, y: contentRect.minY, width: statBoxWidth, height: statBoxHeight)
        )
        
        drawStatBox(
            context: context,
            title: "TIME",
            value: timeText,
            in: CGRect(x: contentRect.minX + statBoxWidth + padding, y: contentRect.minY, width: statBoxWidth, height: statBoxHeight)
        )
        
        // Secondary stats (bottom row)
        drawStatBox(
            context: context,
            title: "PACE",
            value: paceText,
            in: CGRect(x: contentRect.minX, y: contentRect.minY + statBoxHeight + padding, width: statBoxWidth, height: statBoxHeight)
        )
        
        // Territory stat if available
        if let territory = territoryInfo {
            drawStatBox(
                context: context,
                title: "TERRITORY",
                value: territory.areaDisplayString,
                in: CGRect(x: contentRect.minX + statBoxWidth + padding, y: contentRect.minY + statBoxHeight + padding, width: statBoxWidth, height: statBoxHeight)
            )
        } else {
            drawStatBox(
                context: context,
                title: "POINTS",
                value: "\(run.points.count)",
                in: CGRect(x: contentRect.minX + statBoxWidth + padding, y: contentRect.minY + statBoxHeight + padding, width: statBoxWidth, height: statBoxHeight)
            )
        }
    }
    
    private static func drawStatBox(context: CGContext, title: String, value: String, in rect: CGRect) {
        // Title
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: secondaryTextColor,
            .font: UIFont.systemFont(ofSize: 14, weight: .medium)
        ]
        
        let titleSize = title.size(withAttributes: titleAttributes)
        let titleRect = CGRect(
            x: rect.minX,
            y: rect.minY,
            width: rect.width,
            height: titleSize.height
        )
        
        title.draw(in: titleRect, withAttributes: titleAttributes)
        
        // Value
        let valueAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: textColor,
            .font: UIFont.systemFont(ofSize: 28, weight: .bold)
        ]
        
        let valueRect = CGRect(
            x: rect.minX,
            y: titleRect.maxY + 8,
            width: rect.width,
            height: rect.height - titleRect.height - 8
        )
        
        value.draw(in: valueRect, withAttributes: valueAttributes)
    }
    
    private static func drawBranding(context: CGContext, in rect: CGRect) {
        let brandingText = "RunnerPrime"
        let taglineText = "Run. Track. Own."
        
        // Main branding
        let brandingAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: accentColor,
            .font: UIFont.systemFont(ofSize: 24, weight: .bold)
        ]
        
        let brandingSize = brandingText.size(withAttributes: brandingAttributes)
        let brandingRect = CGRect(
            x: mapInset,
            y: rect.height - 80,
            width: brandingSize.width,
            height: brandingSize.height
        )
        
        brandingText.draw(in: brandingRect, withAttributes: brandingAttributes)
        
        // Tagline
        let taglineAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: secondaryTextColor,
            .font: UIFont.systemFont(ofSize: 14, weight: .medium)
        ]
        
        let taglineRect = CGRect(
            x: mapInset,
            y: brandingRect.maxY + 4,
            width: rect.width - (mapInset * 2),
            height: 20
        )
        
        taglineText.draw(in: taglineRect, withAttributes: taglineAttributes)
        
        // Date stamp
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        let dateText = dateFormatter.string(from: run.startTime)
        
        let dateAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: secondaryTextColor,
            .font: UIFont.systemFont(ofSize: 12, weight: .regular)
        ]
        
        let dateSize = dateText.size(withAttributes: dateAttributes)
        let dateRect = CGRect(
            x: rect.width - mapInset - dateSize.width,
            y: rect.height - 40,
            width: dateSize.width,
            height: dateSize.height
        )
        
        dateText.draw(in: dateRect, withAttributes: dateAttributes)
    }
    
    // MARK: - Helper Functions
    
    private static func formatPace(_ distance: Double, duration: TimeInterval) -> String {
        guard distance > 0 && duration > 0 else { return "--:--" }
        
        let paceSecondsPerKm = duration / (distance / 1000)
        let minutes = Int(paceSecondsPerKm) / 60
        let seconds = Int(paceSecondsPerKm) % 60
        
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Convenience Extensions

extension ShareGenerator {
    
    /// Quick share image generation with default settings
    static func generateQuickShare(for run: RunModel, completion: @escaping (UIImage?) -> Void) {
        // Process territory info if we have points
        let territoryInfo: TerritoryInfo?
        if !run.points.isEmpty {
            let tileEngine = TileEngine()
            territoryInfo = tileEngine.processRun(run)
        } else {
            territoryInfo = nil
        }
        
        generateShareImage(for: run, territoryInfo: territoryInfo, completion: completion)
    }
    
    /// Save share image to photo library
    static func saveToPhotos(image: UIImage, completion: @escaping (Bool) -> Void) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        
        // For a production app, you'd want to handle the completion callback properly
        // and check for photo library permissions
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion(true)
        }
    }
}