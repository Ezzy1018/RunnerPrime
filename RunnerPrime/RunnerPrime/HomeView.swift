//
//  HomeView.swift
//  RunnerPrime
//
//  Created by Ankit Yadav on 10/29/25.
//

import SwiftUI
import CoreLocation

struct HomeView: View {
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var runRecorder: RunRecorder
    @StateObject private var localStore = LocalStore.shared
    @State private var showRunHistory = false
    @State private var navigateToActiveRun = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color.rpEerieBlackLiteral
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Top section with branding - 25%
                    VStack(spacing: 12) {
                        Image(systemName: "figure.run.circle.fill")
                            .font(.system(size: min(60, geometry.size.width * 0.15)))
                            .foregroundColor(.rpLimeLiteral)
                        
                        Text("RunnerPrime")
                            .font(.system(size: min(36, geometry.size.width * 0.09), weight: .bold))
                            .foregroundColor(.rpWhiteLiteral)
                        
                        Text("Run. Track. Own.")
                            .font(.system(size: min(18, geometry.size.width * 0.045)))
                            .foregroundColor(.rpLimeLiteral)
                    }
                    .frame(height: geometry.size.height * 0.25)
                    
                    // Middle section with stats/info - 35%
                    VStack(spacing: 16) {
                        // Quick stats from saved runs
                        HStack(spacing: 20) {
                            StatCard(title: "\(localStore.allRuns.count)", subtitle: "Runs", geometry: geometry)
                            StatCard(title: formatTotalDistance(), subtitle: "Distance", geometry: geometry)
                            StatCard(title: "0 km²", subtitle: "Territory", geometry: geometry)
                        }
                        .padding(.horizontal, 24)
                        
                        Text("Start your first run to claim territory")
                            .font(.system(size: min(14, geometry.size.width * 0.035)))
                            .foregroundColor(.rpWhiteLiteral.opacity(0.6))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    .frame(height: geometry.size.height * 0.35)
                    
                    Spacer()
                    
                    // Bottom section with CTAs - fixed at bottom
                    VStack(spacing: 16) {
                        // Primary CTA - Start Run
                        if locationManager.authorizationStatus == .authorizedAlways || locationManager.authorizationStatus == .authorizedWhenInUse {
                            Button(action: {
                                runRecorder.startRun()
                                navigateToActiveRun = true
                            }) {
                                HStack {
                                    Image(systemName: "play.circle.fill")
                                        .font(.system(size: 24))
                                    Text("Start Run")
                                        .font(.system(size: 20, weight: .semibold))
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                                .background(Color.rpLimeLiteral)
                                .foregroundColor(.rpEerieBlackLiteral)
                                .cornerRadius(16)
                            }
                            .accessibilityIdentifier("startRunButton")
                        } else {
                            Button(action: {
                                locationManager.requestAuthorization()
                            }) {
                                HStack {
                                    Image(systemName: "location.circle.fill")
                                        .font(.system(size: 24))
                                    Text("Enable Location")
                                        .font(.system(size: 20, weight: .semibold))
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                                .background(Color.clear)
                                .foregroundColor(.rpLimeLiteral)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.rpLimeLiteral, lineWidth: 2)
                                )
                            }
                        }
                        
                        // Secondary CTA - View Last Run
                        Button(action: {
                            showRunHistory = true
                        }) {
                            HStack {
                                Image(systemName: "clock.arrow.circlepath")
                                    .font(.system(size: 18))
                                Text("View Last Run")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .foregroundColor(.rpWhiteLiteral.opacity(0.8))
                        }
                        
                        // Footer text
                        Text("Bangalore • Mumbai • Delhi")
                            .font(.system(size: 12))
                            .foregroundColor(.rpWhiteLiteral.opacity(0.4))
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, max(20, geometry.safeAreaInsets.bottom + 10))
                }
            }
        }
        .sheet(isPresented: $showRunHistory) {
            RunHistoryView()
        }
        .fullScreenCover(isPresented: $navigateToActiveRun) {
            ActiveRunView()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            localStore.loadRuns()
        }
    }
    
    private func formatTotalDistance() -> String {
        let totalMeters = localStore.allRuns.reduce(0.0) { $0 + $1.distance }
        let km = totalMeters / 1000.0
        return String(format: "%.1f km", km)
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let title: String
    let subtitle: String
    let geometry: GeometryProxy
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: min(24, geometry.size.width * 0.06), weight: .bold))
                .foregroundColor(.rpLimeLiteral)
            Text(subtitle)
                .font(.system(size: min(12, geometry.size.width * 0.03)))
                .foregroundColor(.rpWhiteLiteral.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.rpWhiteLiteral.opacity(0.05))
        )
    }
}

#Preview {
    NavigationView {
        HomeView()
            .environmentObject(LocationManager())
            .environmentObject(RunRecorder(locationManager: LocationManager()))
    }
    .preferredColorScheme(.dark)
}
