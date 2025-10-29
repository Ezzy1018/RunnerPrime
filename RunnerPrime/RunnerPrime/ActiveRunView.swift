//
//  ActiveRunView.swift
//  RunnerPrime
//
//  Active run recording screen with distance, pace, and controls
//

import SwiftUI
import MapKit

struct ActiveRunView: View {
    @EnvironmentObject var runRecorder: RunRecorder
    @Environment(\.dismiss) var dismiss
    @State private var showStopConfirmation = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.rpEerieBlackLiteral
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header with back button
                    HStack {
                        Button(action: {
                            showStopConfirmation = true
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.rpWhiteLiteral)
                                .frame(width: 44, height: 44)
                        }
                        
                        Spacer()
                        
                        Text("Running")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.rpWhiteLiteral)
                        
                        Spacer()
                        
                        // Invisible placeholder for symmetry
                        Color.clear
                            .frame(width: 44, height: 44)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, geometry.safeAreaInsets.top + 34)
                    
                    // Main stats area - 70% of screen
                    VStack(spacing: 24) {
                        Spacer()
                        
                        // Primary stat - Distance (LARGE)
                        VStack(spacing: 8) {
                            Text(formatDistance(runRecorder.liveDistance))
                                .font(.system(size: min(80, geometry.size.width * 0.2), weight: .bold, design: .rounded))
                                .foregroundColor(.rpLimeLiteral)
                            
                            Text("kilometers")
                                .font(.system(size: min(20, geometry.size.width * 0.05)))
                                .foregroundColor(.rpWhiteLiteral.opacity(0.6))
                        }
                        
                        Spacer()
                        
                        // Secondary stats row
                        HStack(spacing: 20) {
                            // Duration
                            StatPill(
                                icon: "clock.fill",
                                label: "Time",
                                value: formatDuration(runRecorder.liveDuration),
                                geometry: geometry
                            )
                            
                            // Speed
                            StatPill(
                                icon: "speedometer",
                                label: "Speed",
                                value: formatSpeed(runRecorder.livePace),
                                geometry: geometry
                            )
                        }
                        .padding(.horizontal, 24)
                        
                        Spacer()
                    }
                    .frame(height: geometry.size.height * 0.7)
                    
                    // Bottom controls - 30%
                    VStack(spacing: 16) {
                        // Pause/Resume button
                        Button(action: {
                            if runRecorder.isPaused {
                                runRecorder.resumeRun()
                            } else {
                                runRecorder.pauseRun()
                            }
                        }) {
                            HStack {
                                Image(systemName: runRecorder.isPaused ? "play.fill" : "pause.fill")
                                    .font(.system(size: 20))
                                Text(runRecorder.isPaused ? "Resume" : "Pause")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.rpWhiteLiteral.opacity(0.1))
                            .foregroundColor(.rpWhiteLiteral)
                            .cornerRadius(16)
                        }
                        
                        // Stop button
                        Button(action: {
                            showStopConfirmation = true
                        }) {
                            HStack {
                                Image(systemName: "stop.fill")
                                    .font(.system(size: 20))
                                Text("End Run")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.rpLimeLiteral)
                            .foregroundColor(.rpEerieBlackLiteral)
                            .cornerRadius(16)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, max(20, geometry.safeAreaInsets.bottom + 10))
                }
            }
        }
        .navigationBarHidden(true)
        .alert("End Run?", isPresented: $showStopConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("End Run", role: .destructive) {
                runRecorder.stopRun()
                dismiss()
            }
        } message: {
            Text("Are you sure you want to end your run?")
        }
    }
    
    private func formatDistance(_ meters: Double) -> String {
        let km = meters / 1000.0
        return String(format: "%.2f", km)
    }
    
    private func formatDuration(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        let secs = Int(seconds) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        } else {
            return String(format: "%02d:%02d", minutes, secs)
        }
    }
    
    private func formatSpeed(_ secondsPerKm: Double) -> String {
        if secondsPerKm <= 0 || secondsPerKm.isInfinite || secondsPerKm > 10000 {
            return "0.0 km/h"
        }
        // Convert seconds per km to km per hour
        let kmPerHour = 3600.0 / secondsPerKm
        return String(format: "%.1f km/h", kmPerHour)
    }
}

struct StatPill: View {
    let icon: String
    let label: String
    let value: String
    let geometry: GeometryProxy
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.rpLimeLiteral)
            
            Text(value)
                .font(.system(size: min(24, geometry.size.width * 0.06), weight: .bold))
                .foregroundColor(.rpWhiteLiteral)
            
            Text(label)
                .font(.system(size: min(12, geometry.size.width * 0.03)))
                .foregroundColor(.rpWhiteLiteral.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.rpWhiteLiteral.opacity(0.05))
        )
    }
}

#Preview {
    ActiveRunView()
        .environmentObject(RunRecorder())
}

