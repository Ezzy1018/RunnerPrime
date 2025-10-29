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
    @State private var selectedRun: RunModel?
    @State private var showRunDetail = false
    
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
                                        .onTapGesture {
                                            selectedRun = run
                                            showRunDetail = true
                                        }
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
        .sheet(isPresented: $showRunDetail) {
            if let run = selectedRun {
                RunDetailView(run: run)
            }
        }
        .onAppear {
            localStore.loadRuns()
        }
    }
}

struct RunHistoryCard: View {
    let run: RunModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Date with chevron indicator
            HStack {
                Text(formatDate(run.startTime))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.rpLimeLiteral)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.rpWhiteLiteral.opacity(0.3))
            }
            
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
                
                // Speed
                VStack(alignment: .leading, spacing: 4) {
                    Text(formatSpeed(run.duration, run.distance))
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.rpWhiteLiteral)
                    Text("Avg Speed")
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
    
    private func formatSpeed(_ duration: TimeInterval, _ distance: Double) -> String {
        guard distance > 0 && duration > 0 else { return "0.0 km/h" }
        let km = distance / 1000.0
        let hours = duration / 3600.0
        let kmPerHour = km / hours
        return String(format: "%.1f km/h", kmPerHour)
    }
}

#Preview {
    RunHistoryView()
}

