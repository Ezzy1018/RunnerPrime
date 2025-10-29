//
//  OnboardingView.swift
//  RunnerPrime
//
//  Created by Ankit Yadav on 10/29/25.
//

import SwiftUI
import CoreLocation
import AuthenticationServices

/// OnboardingView provides a beautiful, conversion-optimized onboarding experience
/// Focuses on permission requests and value proposition for Indian users
struct OnboardingView: View {
    @EnvironmentObject var locationManager: LocationManager
    @StateObject private var firebaseService = FirebaseService.shared
    
    @State private var currentStep = 0
    @State private var showLocationRationale = false
    @State private var showHealthKitRationale = false
    @State private var hasCompletedOnboarding = false
    
    private let onboardingSteps: [OnboardingStep] = [
        OnboardingStep(
            title: "Welcome to RunnerPrime",
            subtitle: "Minimal luxury running for India",
            description: "Track your runs, claim territory, and build lasting fitness habits with our premium experience.",
            illustration: "figure.run",
            primaryAction: "Get Started",
            cityFocus: true
        ),
        OnboardingStep(
            title: "Map Your Territory",
            subtitle: "Every step claims ground",
            description: "Run through neighborhoods and watch your territory grow. Turn fitness into ownership with our unique grid system.",
            illustration: "map",
            primaryAction: "Sounds Great",
            showMap: true
        ),
        OnboardingStep(
            title: "Precise Location Required",
            subtitle: "For accurate run tracking",
            description: "We need location access to map your runs and calculate territory claims. Your data stays private and secure.",
            illustration: "location",
            primaryAction: "Allow Location",
            requiresLocation: true
        )
    ]
    
    var body: some View {
        if hasCompletedOnboarding {
            ContentView()
        } else {
            onboardingFlow
        }
    }
    
    private var onboardingFlow: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()
            
            if currentStep < onboardingSteps.count {
                OnboardingStepView(
                    step: onboardingSteps[currentStep],
                    locationManager: locationManager,
                    onNext: handleNext,
                    onShowRationale: { showLocationRationale = true }
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
            } else {
                signInStep
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .sheet(isPresented: $showLocationRationale) {
            LocationRationaleView(locationManager: locationManager)
        }
        .animation(.easeInOut(duration: 0.4), value: currentStep)
    }
    
    private var signInStep: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Logo and branding
            VStack(spacing: 16) {
                Image(systemName: "figure.run.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.rpLimeLiteral)
                
                Text("RunnerPrime")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.rpWhiteLiteral)
                
                Text("Ready to start your journey?")
                    .font(.title3)
                    .foregroundColor(.rpWhiteLiteral.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            // Sign in section
            VStack(spacing: 20) {
                SignInWithAppleButton(.signIn) { request in
                    request.requestedScopes = [.fullName, .email]
                    request.nonce = firebaseService.generateNonce()
                } onCompletion: { result in
                    handleAppleSignIn(result)
                }
                .frame(height: 50)
                .cornerRadius(12)
                .padding(.horizontal)
                
                Button("Continue Without Account") {
                    completeOnboarding()
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.rpWhiteLiteral.opacity(0.8))
                .padding(.top, 8)
            }
            
            // Terms and privacy
            Text("By continuing, you agree to our Terms of Service and Privacy Policy")
                .font(.caption)
                .foregroundColor(.rpWhiteLiteral.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
        }
    }
    
    private var backgroundColor: Color {
        Color.rpEerieBlackLiteral
    }
    
    // MARK: - Actions
    
    private func handleNext() {
        withAnimation {
            if currentStep < onboardingSteps.count - 1 {
                currentStep += 1
            } else {
                currentStep += 1 // Move to sign-in step
            }
        }
        
        // Analytics
        AnalyticsService.shared.logEvent("onboarding_step_completed", params: [
            "step": currentStep,
            "step_name": currentStep < onboardingSteps.count ? onboardingSteps[currentStep].title : "sign_in"
        ])
    }
    
    private func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authResults):
            if let appleIDCredential = authResults.credential as? ASAuthorizationAppleIDCredential {
                firebaseService.signInWithApple(credential: appleIDCredential) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success:
                            AnalyticsService.shared.logEvent("sign_in_success", params: ["method": "apple"])
                            completeOnboarding()
                        case .failure(let error):
                            print("❌ Sign in failed: \(error)")
                            AnalyticsService.shared.logEvent("sign_in_failure", params: [
                                "method": "apple",
                                "error": error.localizedDescription
                            ])
                        }
                    }
                }
            }
        case .failure(let error):
            print("❌ Apple Sign In failed: \(error)")
        }
    }
    
    private func completeOnboarding() {
        // Mark onboarding as complete
        UserDefaults.standard.set(true, forKey: "HasCompletedOnboarding")
        
        withAnimation(.easeInOut(duration: 0.6)) {
            hasCompletedOnboarding = true
        }
        
        AnalyticsService.shared.logEvent("onboarding_completed", params: [
            "signed_in": firebaseService.isAuthenticated
        ])
    }
}

// MARK: - Supporting Views

struct OnboardingStepView: View {
    let step: OnboardingStep
    let locationManager: LocationManager
    let onNext: () -> Void
    let onShowRationale: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                Spacer(minLength: 60)
                
                // Illustration
                illustrationView
                
                // Content
                VStack(spacing: 20) {
                    Text(step.title)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.rpWhiteLiteral)
                        .multilineTextAlignment(.center)
                    
                    Text(step.subtitle)
                        .font(.title2)
                        .foregroundColor(.rpLimeLiteral)
                        .multilineTextAlignment(.center)
                    
                    Text(step.description)
                        .font(.body)
                        .foregroundColor(.rpWhiteLiteral.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal)
                }
                
                // City focus for first step
                if step.cityFocus {
                    cityFocusView
                }
                
                // Territory preview for second step
                if step.showMap {
                    territoryPreviewView
                }
                
                Spacer(minLength: 40)
                
                // Action button
                actionButton
                
                Spacer(minLength: 40)
            }
            .padding(.horizontal, 24)
        }
    }
    
    private var illustrationView: some View {
        ZStack {
            Circle()
                .fill(Color.rpLimeLiteral.opacity(0.1))
                .frame(width: 160, height: 160)
            
            Image(systemName: step.illustration)
                .font(.system(size: 60, weight: .light))
                .foregroundColor(.rpLimeLiteral)
        }
    }
    
    private var cityFocusView: some View {
        VStack(spacing: 16) {
            Text("🎯 Launching in:")
                .font(.headline)
                .foregroundColor(.rpWhiteLiteral)
            
            HStack(spacing: 20) {
                CityBadge(name: "Bangalore")
                CityBadge(name: "Mumbai")
                CityBadge(name: "Delhi")
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.rpWhiteLiteral.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.rpLimeLiteral.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    private var territoryPreviewView: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("0.25 km²")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.rpLimeLiteral)
                    Text("Territory Claimed")
                        .font(.caption)
                        .foregroundColor(.rpWhiteLiteral.opacity(0.7))
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("25")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.rpWhiteLiteral)
                    Text("Grid Tiles")
                        .font(.caption)
                        .foregroundColor(.rpWhiteLiteral.opacity(0.7))
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.rpWhiteLiteral.opacity(0.05))
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.rpWhiteLiteral.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.rpLimeLiteral.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    private var actionButton: some View {
        Button(action: handleAction) {
            HStack {
                Text(step.primaryAction)
                    .font(.headline)
                    .font(.body.weight(.semibold))
                
                if step.requiresLocation {
                    Image(systemName: "location.fill")
                        .font(.system(size: 16))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.rpLimeLiteral)
            .foregroundColor(.rpEerieBlackLiteral)
            .cornerRadius(12)
        }
        .padding(.horizontal)
    }
    
    private func handleAction() {
        if step.requiresLocation {
            handleLocationRequest()
        } else {
            onNext()
        }
    }
    
    private func handleLocationRequest() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestAuthorization()
            // The completion will be handled by the location manager delegate
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways {
                    AnalyticsService.shared.logEvent("location_permission_granted", params: ["auth": "whenInUse"])
                    onNext()
                } else if locationManager.authorizationStatus == .denied {
                    onShowRationale()
                }
            }
        case .denied, .restricted:
            onShowRationale()
        case .authorizedWhenInUse, .authorizedAlways:
            onNext()
        @unknown default:
            locationManager.requestAuthorization()
        }
    }
}

struct CityBadge: View {
    let name: String
    
    var body: some View {
        Text(name)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.rpLimeLiteral.opacity(0.2))
            .foregroundColor(.rpLimeLiteral)
            .cornerRadius(12)
    }
}

// MARK: - Location Rationale Sheet

struct LocationRationaleView: View {
    let locationManager: LocationManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "location.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.rpLimeLiteral)
                    
                    Text("Location Permission")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.rpWhiteLiteral)
                    
                    Text("RunnerPrime needs location access to provide core features")
                        .font(.subheadline)
                        .foregroundColor(.rpWhiteLiteral.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                
                // Why we need it
                VStack(alignment: .leading, spacing: 20) {
                    PermissionReason(
                        icon: "map",
                        title: "Accurate Run Tracking",
                        description: "Map your running route with precision for reliable distance and pace calculations."
                    )
                    
                    PermissionReason(
                        icon: "grid.circle",
                        title: "Territory Claiming",
                        description: "Calculate which grid tiles you've conquered during your runs."
                    )
                    
                    PermissionReason(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "Progress Analytics",
                        description: "Track your running patterns and improvement over time."
                    )
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.rpWhiteLiteral.opacity(0.05))
                )
                
                // Privacy note
                Text("🔒 Your location data is processed locally and encrypted. We never share your exact locations.")
                    .font(.caption)
                    .foregroundColor(.rpWhiteLiteral.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer()
                
                // Action buttons
                VStack(spacing: 12) {
                    Button("Open Settings") {
                        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(settingsUrl)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.rpLimeLiteral)
                    .foregroundColor(.rpEerieBlackLiteral)
                    .font(.body.weight(.semibold))
                    .cornerRadius(12)
                    
                    Button("Maybe Later") {
                        dismiss()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.rpWhiteLiteral.opacity(0.8))
                }
                .padding(.horizontal)
            }
            .padding()
            .background(Color.rpEerieBlackLiteral)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(.rpWhiteLiteral)
                }
            }
        }
    }
}

struct PermissionReason: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.rpLimeLiteral)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .font(.body.weight(.semibold))
                    .foregroundColor(.rpWhiteLiteral)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.rpWhiteLiteral.opacity(0.7))
                    .lineSpacing(2)
            }
            
            Spacer()
        }
    }
}

// MARK: - Data Models

struct OnboardingStep {
    let title: String
    let subtitle: String
    let description: String
    let illustration: String
    let primaryAction: String
    let cityFocus: Bool
    let showMap: Bool
    let requiresLocation: Bool
    
    init(
        title: String,
        subtitle: String,
        description: String,
        illustration: String,
        primaryAction: String,
        cityFocus: Bool = false,
        showMap: Bool = false,
        requiresLocation: Bool = false
    ) {
        self.title = title
        self.subtitle = subtitle
        self.description = description
        self.illustration = illustration
        self.primaryAction = primaryAction
        self.cityFocus = cityFocus
        self.showMap = showMap
        self.requiresLocation = requiresLocation
    }
}

// MARK: - Preview

#Preview {
    OnboardingView()
        .environmentObject(LocationManager())
}