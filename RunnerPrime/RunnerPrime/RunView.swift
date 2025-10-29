//
//  RunView.swift
//  RunnerPrime
//
//  Created by Ankit Yadav on 10/29/25.
//

import SwiftUI
import MapKit

struct RunView: View {
    @EnvironmentObject var runRecorder: RunRecorder

    var body: some View {
        VStack {
            RunMapView(run: runRecorder.currentRun)
                .frame(height: 380)
                .cornerRadius(12)
                .padding()

            HStack {
                VStack(alignment: .leading) {
                    Text("Distance")
                        .font(.subheadline)
                        .foregroundColor(.rpWhiteLiteral)
                    Text(String(format: "%.2f km", (runRecorder.currentRun?.distance ?? 0) / 1000))
                        .font(.title2)
                        .foregroundColor(.rpLimeLiteral)
                }
                Spacer()
                VStack(alignment: .leading) {
                    Text("Duration")
                        .font(.subheadline)
                        .foregroundColor(.rpWhiteLiteral)
                    Text(runRecorder.currentRun?.durationString ?? "00:00:00")
                        .font(.title2)
                        .foregroundColor(.rpWhiteLiteral)
                }
            }
            .padding()

            Spacer()

            HStack {
                Button(action: { runRecorder.stopRun() }) {
                    Text("Stop")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.clear)
                        .foregroundColor(.rpWhiteLiteral)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.rpLimeLiteral, lineWidth: 1.2))
                }

                Button(action: { runRecorder.pauseRun() }) {
                    Text("Pause")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.rpLimeLiteral)
                        .foregroundColor(.rpEerieBlackLiteral)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
        .background(Color.rpEerieBlackLiteral.edgesIgnoringSafeArea(.all))
    }
}
