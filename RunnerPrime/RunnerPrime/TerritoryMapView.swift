//
//  TerritoryMapView.swift
//  RunnerPrime
//
//  World map showing tiles/areas claimed across all runs.
//

import SwiftUI
import MapKit

struct TerritoryMapView: UIViewRepresentable {
    @ObservedObject var localStore = LocalStore.shared
    private let tileEngine = TileEngine()
    private let earthRadius: Double = 6_378_137.0

    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView(frame: .zero)
        map.showsCompass = true
        map.showsScale = false
        map.isRotateEnabled = false
        map.overrideUserInterfaceStyle = .dark
        map.pointOfInterestFilter = .includingAll
        map.delegate = context.coordinator
        return map
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeOverlays(uiView.overlays)

        // Aggregate tiles from all runs (local-only for MVP)
        var allTiles: Set<String> = []
        for run in localStore.allRuns {
            let coords = run.points.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
            let hull = coords.count >= 10 ? computeConcaveHull(points: coords, k: 3) : nil
            let info = tileEngine.processRun(run, polygon: hull)
            allTiles.formUnion(info.tileIds)
        }

        // Convert tiles to MKPolygon overlays
        for tileId in allTiles {
            if let overlay = polygonForTile(tileId: tileId) {
                uiView.addOverlay(overlay)
            }
        }

        // Zoom to show overlays if any
        if let first = uiView.overlays.first {
            let rect = uiView.overlays.dropFirst().reduce(first.boundingMapRect) { $0.union($1.boundingMapRect) }
            let padding = UIEdgeInsets(top: 60, left: 60, bottom: 60, right: 60)
            uiView.setVisibleMapRect(rect, edgePadding: padding, animated: false)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polygon = overlay as? MKPolygon {
                let renderer = MKPolygonRenderer(polygon: polygon)
                renderer.fillColor = UIColor(red: 217/255, green: 255/255, blue: 84/255, alpha: 0.15)
                renderer.strokeColor = UIColor(red: 217/255, green: 255/255, blue: 84/255, alpha: 0.35)
                renderer.lineWidth = 1
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    }

    // MARK: - Tile Helpers

    private func polygonForTile(tileId: String) -> MKPolygon? {
        let parts = tileId.split(separator: "_")
        guard parts.count == 2, let tx = Int(parts[0]), let ty = Int(parts[1]) else { return nil }

        let size = tileEngine.tileSizeMeters

        let minX = Double(tx) * size
        let minY = Double(ty) * size
        let maxX = minX + size
        let maxY = minY + size

        let c1 = mercatorToCoordinate(x: minX, y: minY)
        let c2 = mercatorToCoordinate(x: maxX, y: minY)
        let c3 = mercatorToCoordinate(x: maxX, y: maxY)
        let c4 = mercatorToCoordinate(x: minX, y: maxY)

        var coords = [c1, c2, c3, c4]
        return MKPolygon(coordinates: &coords, count: coords.count)
    }

    private func mercatorToCoordinate(x: Double, y: Double) -> CLLocationCoordinate2D {
        let lon = (x / earthRadius) * 180.0 / .pi
        let lat = (2 * atan(exp(y / earthRadius)) - .pi / 2) * 180.0 / .pi
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}

#Preview {
    TerritoryMapView()
}


