//
//  HomeView.swift
//  RunnerPrime
//
//  Created by Ankit Yadav on 10/29/25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var runRecorder: RunRecorder

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Text("RunnerPrime")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.rpWhiteLiteral)

            Text("Minimal, premium run tracking — track, claim, repeat.")
                .multilineTextAlignment(.center)
                .foregroundColor(.rpWhiteLiteral.opacity(0.8))
                .padding(.horizontal)

            Spacer()

            if locationManager.authorizationStatus == .authorizedAlways || locationManager.authorizationStatus == .authorizedWhenInUse {
                Button(action: {
                    runRecorder.startRun()
                }) {
                    Text("Start Run")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.rpLimeLiteral)
                        .foregroundColor(.rpEerieBlackLiteral)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
                .accessibilityIdentifier("startRunButton")
            } else {
                Button(action: {
                    locationManager.requestAuthorization()
                }) {
                    Text("Enable Location")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.clear)
                        .foregroundColor(.rpWhiteLiteral)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.rpLimeLiteral, lineWidth: 1.5))
                        .padding(.horizontal)
                }
            }

            NavigationLink(destination: RunView()) {
                Text("View Last Run")
                    .foregroundColor(.rpWhiteLiteral)
            }

            Spacer()

            Text("Designed for India — launch cities: Bangalore, Mumbai, Delhi")
                .font(.footnote)
                .foregroundColor(.rpWhiteLiteral.opacity(0.6))
                .padding()
        }
        .background(Color.rpEerieBlackLiteral.ignoresSafeArea())
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
