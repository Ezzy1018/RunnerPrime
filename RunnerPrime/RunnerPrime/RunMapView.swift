//
//  RunMapView.swift
//  RunnerPrime
//
//  Created by Ankit Yadav on 10/29/25.
//

import SwiftUI
import MapKit

struct RunMapView: UIViewRepresentable {
    var run: RunModel?

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.showsCompass = false
        mapView.showsScale = false
        mapView.isRotateEnabled = false
        mapView.overrideUserInterfaceStyle = .dark
        let config = MKStandardMapConfiguration(elevationStyle: .flat)
        config.pointOfInterestFilter = .excludingAll
        mapView.preferredConfiguration = config
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeOverlays(uiView.overlays)
        uiView.removeAnnotations(uiView.annotations)

        guard let run = run, run.points.count > 0 else { return }
        let coords = run.points.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
        let poly = MKPolyline(coordinates: coords, count: coords.count)
        uiView.addOverlay(poly)

        if let first = coords.first {
            let region = MKCoordinateRegion(center: first, latitudinalMeters: 800, longitudinalMeters: 800)
            uiView.setRegion(region, animated: true)
        }
        uiView.delegate = context.coordinator

        // TODO: render territory tiles later
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let poly = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: poly)
                renderer.strokeColor = UIColor(red: 217/255, green: 255/255, blue: 84/255, alpha: 0.9) // Lime
                renderer.lineWidth = 5
                renderer.lineJoin = .round
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}
