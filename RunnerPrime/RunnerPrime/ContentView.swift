//
//  ContentView.swift
//  RunnerPrime
//
//  Created by Ankit Yadav on 10/29/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var runRecorder: RunRecorder

    var body: some View {
        NavigationView {
            HomeView()
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
        .environmentObject(LocationManager())
        .environmentObject(RunRecorder())
        .preferredColorScheme(.dark)
}
