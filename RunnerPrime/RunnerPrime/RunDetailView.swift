//
//  RunDetailView.swift
//  RunnerPrime
//
//  Detailed view for a specific run with map and stats
//

import SwiftUI
import MapKit

struct RunDetailView: View {
    let run: RunModel
    @Environment(\.dismiss) var dismiss
    @State private var hasArea: Bool = false
    @State private var areaKm2: Double = 0.0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.rpEerieBlackLiteral
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.rpWhiteLiteral)
                                .frame(width: 44, height: 44)
                        }
                        
                        Text("Run Details")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.rpWhiteLiteral)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, geometry.safeAreaInsets.top + 10)
                    .padding(.bottom, 20)
                    
                    // Map view - 50% of screen
                    RunDetailMapView(run: run, hasArea: $hasArea, areaKm2: $areaKm2)
                        .frame(height: geometry.size.height * 0.5)
                        .cornerRadius(16)
                        .padding(.horizontal, 20)
                    
                    // Stats section
                    ScrollView {
                        VStack(spacing: 16) {
                            // Date and time
                            Text(formatDate(run.startTime))
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.rpLimeLiteral)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 24)
                            
                            // Main stats grid
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 16) {
                                StatDetailCard(
                                    title: "Distance",
                                    value: formatDistance(run.distance),
                                    icon: "arrow.right"
                                )
                                
                                StatDetailCard(
                                    title: "Duration",
                                    value: formatDuration(run.duration),
                                    icon: "clock"
                                )
                                
                                StatDetailCard(
                                    title: "Avg Speed",
                                    value: formatSpeed(run.duration, run.distance),
                                    icon: "speedometer"
                                )
                                
                                if hasArea {
                                    StatDetailCard(
                                        title: "Area Covered",
                                        value: String(format: "%.3f km²", areaKm2),
                                        icon: "map"
                                    )
                                }
                            }
                            
                            // Route information
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Route Information")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.rpWhiteLiteral)
                                
                                HStack {
                                    Image(systemName: "point.topleft.down.curvedto.point.bottomright.up")
                                        .foregroundColor(.rpLimeLiteral)
                                    Text("Total Points: \(run.points.count)")
                                        .font(.system(size: 14))
                                        .foregroundColor(.rpWhiteLiteral.opacity(0.8))
                                    Spacer()
                                }
                                
                                if hasArea {
                                    HStack {
                                        Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                                            .foregroundColor(.rpLimeLiteral)
                                        Text("This run captured an area")
                                            .font(.system(size: 14))
                                            .foregroundColor(.rpWhiteLiteral.opacity(0.8))
                                        Spacer()
                                    }
                                }
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.rpWhiteLiteral.opacity(0.05))
                            )
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - Formatting helpers
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, yyyy • h:mm a"
        return formatter.string(from: date)
    }
    
    private func formatDistance(_ meters: Double) -> String {
        let km = meters / 1000.0
        return String(format: "%.2f km", km)
    }
    
    private func formatDuration(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        let secs = Int(seconds) % 60
        
        if hours > 0 {
            return String(format: "%dh %dm %ds", hours, minutes, secs)
        } else {
            return String(format: "%dm %ds", minutes, secs)
        }
    }
    
    private func formatSpeed(_ duration: TimeInterval, _ distance: Double) -> String {
        guard distance > 0 && duration > 0 else { return "0.0 km/h" }
        let km = distance / 1000.0
        let hours = duration / 3600.0
        let kmPerHour = km / hours
        return String(format: "%.1f km/h", kmPerHour)
    }
}

// MARK: - Supporting Views

struct StatDetailCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.rpLimeLiteral)
            
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.rpWhiteLiteral)
            
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(.rpWhiteLiteral.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.rpWhiteLiteral.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.rpWhiteLiteral.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

// MARK: - Map View with Loop Detection

struct RunDetailMapView: UIViewRepresentable {
    var run: RunModel
    @Binding var hasArea: Bool
    @Binding var areaKm2: Double
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.showsCompass = true
        mapView.showsScale = true
        mapView.isRotateEnabled = true
        mapView.overrideUserInterfaceStyle = .dark
        mapView.pointOfInterestFilter = .excludingAll
        mapView.delegate = context.coordinator
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeOverlays(uiView.overlays)
        uiView.removeAnnotations(uiView.annotations)
        
        guard run.points.count > 0 else { return }
        
        let coords = run.points.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
        
        // Try to compute a concave hull for coverage area
        if let hull = computeConcaveHull(points: coords, k: 3), hull.count >= 3 {
            // Update bindings
            let area = polygonAreaKm2(hull)
            DispatchQueue.main.async {
                self.hasArea = true
                self.areaKm2 = area
            }
            // Add polygon overlay
            var hullCoords = hull
            let poly = MKPolygon(coordinates: &hullCoords, count: hullCoords.count)
            uiView.addOverlay(poly)
        } else {
            DispatchQueue.main.async {
                self.hasArea = false
                self.areaKm2 = 0
            }
        }
        
        // Add polyline for the route (always)
        let polyline = MKPolyline(coordinates: coords, count: coords.count)
        uiView.addOverlay(polyline)
        
        // Add start and end markers
        if let first = coords.first {
            let startAnnotation = MKPointAnnotation()
            startAnnotation.coordinate = first
            startAnnotation.title = "Start"
            uiView.addAnnotation(startAnnotation)
        }
        
        if let last = coords.last, coords.count > 1 {
            let endAnnotation = MKPointAnnotation()
            endAnnotation.coordinate = last
            endAnnotation.title = "End"
            uiView.addAnnotation(endAnnotation)
        }
        
        // Fit the map to show the entire route
        if coords.count > 0 {
            let polyline = MKPolyline(coordinates: coords, count: coords.count)
            var visibleRect = polyline.boundingMapRect
            if let hull = computeConcaveHull(points: coords, k: 3), hull.count >= 3 {
                var hullCoords = hull
                let poly = MKPolygon(coordinates: &hullCoords, count: hullCoords.count)
                visibleRect = visibleRect.union(poly.boundingMapRect)
            }
            let padding = UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50)
            uiView.setVisibleMapRect(visibleRect, edgePadding: padding, animated: true)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    // (Closed loop heuristic removed; replaced by concave hull computation)
    
    // MARK: - Coordinator
    
    class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = UIColor(red: 217/255, green: 255/255, blue: 84/255, alpha: 1.0) // Lime
                renderer.lineWidth = 4
                renderer.lineJoin = .round
                renderer.lineCap = .round
                return renderer
            } else if let polygon = overlay as? MKPolygon {
                let renderer = MKPolygonRenderer(polygon: polygon)
                renderer.fillColor = UIColor(red: 217/255, green: 255/255, blue: 84/255, alpha: 0.2) // Transparent lime
                renderer.strokeColor = UIColor(red: 217/255, green: 255/255, blue: 84/255, alpha: 1.0) // Lime border
                renderer.lineWidth = 4
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            let identifier = "RunPoint"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
            } else {
                annotationView?.annotation = annotation
            }
            
            if let markerView = annotationView as? MKMarkerAnnotationView {
                if annotation.title == "Start" {
                    markerView.markerTintColor = UIColor(red: 217/255, green: 255/255, blue: 84/255, alpha: 1.0) // Lime
                    markerView.glyphImage = UIImage(systemName: "flag.fill")
                } else if annotation.title == "End" {
                    markerView.markerTintColor = UIColor.systemRed
                    markerView.glyphImage = UIImage(systemName: "flag.checkered")
                }
            }
            
            return annotationView
        }
    }
}

#Preview {
    let sampleRun = RunModel(startTime: Date())
    return RunDetailView(run: sampleRun)
}

