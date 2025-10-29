//
//  SettingsView.swift
//  RunnerPrime
//
//  Created by Ankit Yadav on 10/29/25.
//

import SwiftUI

/// SettingsView provides user preferences and app configuration
/// Follows the minimal, premium design aesthetic of RunnerPrime
struct SettingsView: View {
    @StateObject private var firebaseService = FirebaseService.shared
    @StateObject private var healthKitService = HealthKitService.shared
    
    @State private var selectedUnits = UserDefaults.standard.string(forKey: "units") ?? "km"
    @State private var selectedLanguage = UserDefaults.standard.string(forKey: "language") ?? "en"
    @State private var backgroundLocationEnabled = UserDefaults.standard.bool(forKey: "backgroundLocation")
    @State private var healthKitEnabled = UserDefaults.standard.bool(forKey: "healthKitEnabled")
    @State private var notificationsEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")
    
    @State private var showSignOutAlert = false
    @State private var showDeleteAccountAlert = false
    @State private var showHealthKitSetup = false
    @State private var showAbout = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 0) {
                    
                    // Profile Section
                    if firebaseService.isAuthenticated {
                        profileSection
                    }
                    
                    // Units & Language
                    preferencesSection
                    
                    // Privacy & Permissions
                    privacySection
                    
                    // Data & Storage
                    dataSection
                    
                    // About & Support
                    aboutSection
                    
                    // Account Actions
                    if firebaseService.isAuthenticated {
                        accountSection
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .background(Color.rpEerieBlackLiteral.ignoresSafeArea())
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .preferredColorScheme(.dark)
        }
        .sheet(isPresented: $showAbout) {
            AboutView()
        }
        .alert("Sign Out", isPresented: $showSignOutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out", role: .destructive) {
                signOut()
            }
        } message: {
            Text("Are you sure you want to sign out? Your runs will remain saved locally.")
        }
        .alert("Delete Account", isPresented: $showDeleteAccountAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteAccount()
            }
        } message: {
            Text("This will permanently delete your account and all cloud data. Local runs will remain on device.")
        }
        .onChange(of: selectedUnits) { _, newValue in
            updateUnits(newValue)
        }
        .onChange(of: selectedLanguage) { _, newValue in
            updateLanguage(newValue)
        }
    }
    
    // MARK: - Profile Section
    
    private var profileSection: some View {
        SettingsSection(title: "Profile") {
            if let user = firebaseService.currentUser {
                SettingsRow(
                    icon: "person.circle.fill",
                    title: user.displayName,
                    subtitle: user.email,
                    iconColor: .rpLimeLiteral
                )
                
                SettingsRow(
                    icon: "chart.bar.fill",
                    title: "Running Stats",
                    subtitle: "\(user.totalRuns) runs • \(String(format: "%.1f", user.totalDistance/1000))km total",
                    iconColor: .blue,
                    hasChevron: true
                ) {
                    // Navigate to stats view (future implementation)
                }
            }
        }
    }
    
    // MARK: - Preferences Section
    
    private var preferencesSection: some View {
        SettingsSection(title: "Preferences") {
            // Units
            SettingsRow(
                icon: "ruler.fill",
                title: "Units",
                subtitle: selectedUnits == "km" ? "Metric (km, m/s)" : "Imperial (mi, mph)",
                iconColor: .orange,
                hasChevron: true
            ) {
                // Show units picker
            }
            
            // Language
            SettingsRow(
                icon: "globe",
                title: "Language",
                subtitle: selectedLanguage == "en" ? "English" : "हिन्दी",
                iconColor: .purple,
                hasChevron: true
            ) {
                // Show language picker
            }
        }
    }
    
    // MARK: - Privacy Section
    
    private var privacySection: some View {
        SettingsSection(title: "Privacy & Permissions") {
            // Location
            SettingsRow(
                icon: "location.fill",
                title: "Location Services",
                subtitle: "Required for run tracking",
                iconColor: .red
            ) {
                openLocationSettings()
            }
            
            // Background Location
            SettingsToggleRow(
                icon: "location.circle.fill",
                title: "Background Location",
                subtitle: "Allow run tracking when app is closed",
                iconColor: .red,
                isOn: $backgroundLocationEnabled
            )
            
            // HealthKit
            SettingsToggleRow(
                icon: "heart.fill",
                title: "Apple Health",
                subtitle: healthKitService.isAuthorized ? "Connected" : "Import workout history",
                iconColor: .red,
                isOn: $healthKitEnabled
            ) {
                if !healthKitService.isAuthorized {
                    connectHealthKit()
                }
            }
            
            // Notifications
            SettingsToggleRow(
                icon: "bell.fill",
                title: "Notifications",
                subtitle: "Run reminders and achievements",
                iconColor: .blue,
                isOn: $notificationsEnabled
            )
        }
    }
    
    // MARK: - Data Section
    
    private var dataSection: some View {
        SettingsSection(title: "Data & Storage") {
            let storageInfo = LocalStore.shared.getStorageInfo()
            
            SettingsRow(
                icon: "internaldrive.fill",
                title: "Local Storage",
                subtitle: "\(storageInfo.runCount) runs • \(storageInfo.formattedSize)",
                iconColor: .gray,
                hasChevron: true
            ) {
                // Show storage management view
            }
            
            SettingsRow(
                icon: "icloud.fill",
                title: "Cloud Sync",
                subtitle: firebaseService.isAuthenticated ? "Syncing" : "Sign in to sync",
                iconColor: .blue,
                hasChevron: false
            )
            
            SettingsRow(
                icon: "square.and.arrow.up.fill",
                title: "Export Data",
                subtitle: "Export runs as GPX files",
                iconColor: .green,
                hasChevron: true
            ) {
                exportData()
            }
        }
    }
    
    // MARK: - About Section
    
    private var aboutSection: some View {
        SettingsSection(title: "About & Support") {
            SettingsRow(
                icon: "info.circle.fill",
                title: "About RunnerPrime",
                subtitle: "Version \(Bundle.main.appVersion)",
                iconColor: .rpLimeLiteral,
                hasChevron: true
            ) {
                showAbout = true
            }
            
            SettingsRow(
                icon: "questionmark.circle.fill",
                title: "Help & Support",
                subtitle: "FAQs and contact support",
                iconColor: .blue,
                hasChevron: true
            ) {
                openSupport()
            }
            
            SettingsRow(
                icon: "star.fill",
                title: "Rate App",
                subtitle: "Leave a review on the App Store",
                iconColor: .yellow,
                hasChevron: true
            ) {
                rateApp()
            }
        }
    }
    
    // MARK: - Account Section
    
    private var accountSection: some View {
        SettingsSection(title: "Account") {
            SettingsRow(
                icon: "rectangle.portrait.and.arrow.right.fill",
                title: "Sign Out",
                subtitle: "Stay signed in to sync across devices",
                iconColor: .orange,
                hasChevron: false
            ) {
                showSignOutAlert = true
            }
            
            SettingsRow(
                icon: "trash.fill",
                title: "Delete Account",
                subtitle: "Permanently delete your RunnerPrime account",
                iconColor: .red,
                hasChevron: false
            ) {
                showDeleteAccountAlert = true
            }
        }
    }
    
    // MARK: - Actions
    
    private func updateUnits(_ units: String) {
        UserDefaults.standard.set(units, forKey: "units")
        AnalyticsService.shared.setUserUnits(units)
        AnalyticsService.shared.logSettingsChange(setting: "units", newValue: units)
    }
    
    private func updateLanguage(_ language: String) {
        UserDefaults.standard.set(language, forKey: "language")
        AnalyticsService.shared.logSettingsChange(setting: "language", newValue: language)
        // Note: Full localization would require app restart
    }
    
    private func connectHealthKit() {
        healthKitService.requestAuthorization { success, error in
            DispatchQueue.main.async {
                if success {
                    healthKitEnabled = true
                    UserDefaults.standard.set(true, forKey: "healthKitEnabled")
                    AnalyticsService.shared.logHealthKitConnected()
                } else {
                    print("HealthKit authorization failed: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
    }
    
    private func openLocationSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
    
    private func exportData() {
        // Implementation would create GPX files and present share sheet
        AnalyticsService.shared.logEvent("data_export_initiated")
    }
    
    private func openSupport() {
        if let url = URL(string: "mailto:support@runnerprime.app") {
            UIApplication.shared.open(url)
        }
    }
    
    private func rateApp() {
        if let url = URL(string: "itms-apps://itunes.apple.com/app/id") {
            UIApplication.shared.open(url)
        }
    }
    
    private func signOut() {
        do {
            try firebaseService.signOut()
            AnalyticsService.shared.logEvent("sign_out")
        } catch {
            print("Sign out error: \(error)")
        }
    }
    
    private func deleteAccount() {
        // Implementation would delete user account
        AnalyticsService.shared.logEvent("account_deletion_initiated")
    }
}

// MARK: - Supporting Views

struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Section Header
            Text(title.uppercased())
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.rpWhiteLiteral.opacity(0.6))
                .padding(.horizontal, 16)
                .padding(.top, 24)
                .padding(.bottom, 8)
            
            // Section Content
            VStack(spacing: 0) {
                content
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.rpWhiteLiteral.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.rpWhiteLiteral.opacity(0.1), lineWidth: 1)
            )
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String?
    let iconColor: Color
    let hasChevron: Bool
    let action: (() -> Void)?
    
    init(
        icon: String,
        title: String,
        subtitle: String? = nil,
        iconColor: Color = .rpLimeLiteral,
        hasChevron: Bool = false,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.iconColor = iconColor
        self.hasChevron = hasChevron
        self.action = action
    }
    
    var body: some View {
        Button(action: action ?? {}) {
            HStack(spacing: 16) {
                // Icon
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(iconColor)
                    .frame(width: 24, height: 24)
                
                // Content
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.rpWhiteLiteral)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.system(size: 14))
                            .foregroundColor(.rpWhiteLiteral.opacity(0.7))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                
                // Chevron
                if hasChevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.rpWhiteLiteral.opacity(0.4))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SettingsToggleRow: View {
    let icon: String
    let title: String
    let subtitle: String?
    let iconColor: Color
    @Binding var isOn: Bool
    let onToggle: (() -> Void)?
    
    init(
        icon: String,
        title: String,
        subtitle: String? = nil,
        iconColor: Color = .rpLimeLiteral,
        isOn: Binding<Bool>,
        onToggle: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.iconColor = iconColor
        self._isOn = isOn
        self.onToggle = onToggle
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(iconColor)
                .frame(width: 24, height: 24)
            
            // Content
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.rpWhiteLiteral)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(.rpWhiteLiteral.opacity(0.7))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            
            // Toggle
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: .rpLimeLiteral))
                .onChange(of: isOn) { _, newValue in
                    if newValue {
                        onToggle?()
                    }
                }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - About View

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Logo
                    Image(systemName: "figure.run.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.rpLimeLiteral)
                    
                    // App Info
                    VStack(spacing: 8) {
                        Text("RunnerPrime")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.rpWhiteLiteral)
                        
                        Text("Version \(Bundle.main.appVersion)")
                            .font(.subheadline)
                            .foregroundColor(.rpWhiteLiteral.opacity(0.7))
                    }
                    
                    // Description
                    Text("Minimal luxury running for India. Track your runs, claim territory, and build lasting fitness habits with our premium experience.")
                        .font(.body)
                        .foregroundColor(.rpWhiteLiteral.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal)
                    
                    // Features
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Features")
                            .font(.headline)
                            .foregroundColor(.rpWhiteLiteral)
                        
                        FeatureRow(icon: "map", title: "Territory Mapping", description: "Claim 100m grid tiles as you run")
                        FeatureRow(icon: "location", title: "GPS Tracking", description: "Accurate distance and route recording")
                        FeatureRow(icon: "icloud", title: "Cloud Sync", description: "Secure backup with Firebase")
                        FeatureRow(icon: "heart", title: "Health Integration", description: "Connect with Apple Health")
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.rpWhiteLiteral.opacity(0.05))
                    )
                    
                    // Credits
                    Text("Made with ❤️ for Indian runners")
                        .font(.caption)
                        .foregroundColor(.rpWhiteLiteral.opacity(0.6))
                        .padding(.top)
                }
                .padding()
            }
            .background(Color.rpEerieBlackLiteral.ignoresSafeArea())
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.rpLimeLiteral)
                }
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.rpLimeLiteral)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.rpWhiteLiteral)
                
                Text(description)
                    .font(.system(size: 12))
                    .foregroundColor(.rpWhiteLiteral.opacity(0.7))
            }
            
            Spacer()
        }
    }
}

// MARK: - Bundle Extension

extension Bundle {
    var appVersion: String {
        return infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
}