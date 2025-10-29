//
//  RunHistoryView.swift
//  RunnerPrime
//
//  View showing all past runs
//

import SwiftUI

struct RunHistoryView: View {
    @StateObject private var localStore = LocalStore.shared
    @Environment(\.dismiss) var dismiss
    
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
                        
                        Text("Run History")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.rpWhiteLiteral)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, geometry.safeAreaInsets.top + 10)
                    .padding(.bottom, 20)
                    
                    // Runs list
                    if localStore.allRuns.isEmpty {
                        VStack(spacing: 16) {
                            Spacer()
                            
                            Image(systemName: "figure.run.circle")
                                .font(.system(size: 60))
                                .foregroundColor(.rpLimeLiteral.opacity(0.5))
                            
                            Text("No runs yet")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.rpWhiteLiteral)
                            
                            Text("Start your first run to see it here")
                                .font(.system(size: 14))
                                .foregroundColor(.rpWhiteLiteral.opacity(0.6))
                            
                            Spacer()
                        }
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(localStore.allRuns) { run in
                                    RunHistoryCard(run: run)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            localStore.loadRuns()
        }
    }
}

struct RunHistoryCard: View {
    let run: RunModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Date
            Text(formatDate(run.startTime))
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.rpLimeLiteral)
            
            // Stats row
            HStack(spacing: 20) {
                // Distance
                VStack(alignment: .leading, spacing: 4) {
                    Text(formatDistance(run.distance))
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.rpWhiteLiteral)
                    Text("Distance")
                        .font(.system(size: 12))
                        .foregroundColor(.rpWhiteLiteral.opacity(0.6))
                }
                
                Spacer()
                
                // Duration
                VStack(alignment: .leading, spacing: 4) {
                    Text(formatDuration(run.duration))
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.rpWhiteLiteral)
                    Text("Duration")
                        .font(.system(size: 12))
                        .foregroundColor(.rpWhiteLiteral.opacity(0.6))
                }
                
                // Pace
                VStack(alignment: .leading, spacing: 4) {
                    Text(formatPace(run.duration, run.distance))
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.rpWhiteLiteral)
                    Text("Pace")
                        .font(.system(size: 12))
                        .foregroundColor(.rpWhiteLiteral.opacity(0.6))
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.rpWhiteLiteral.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.rpWhiteLiteral.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
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
            return String(format: "%dh %dm", hours, minutes)
        } else {
            return String(format: "%dm %ds", minutes, secs)
        }
    }
    
    private func formatPace(_ duration: TimeInterval, _ distance: Double) -> String {
        guard distance > 0 else { return "--:--" }
        let km = distance / 1000.0
        let secondsPerKm = duration / km
        let minutes = Int(secondsPerKm) / 60
        let seconds = Int(secondsPerKm) % 60
        return String(format: "%d:%02d /km", minutes, seconds)
    }
}

#Preview {
    RunHistoryView()
}

