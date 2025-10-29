# Firebase SDK Integration Guide

## 📦 Adding Firebase Dependencies to Xcode

### Step 1: Add Package Dependencies

1. **Open your RunnerPrime project in Xcode**

2. **Navigate to Package Manager**
   ```
   File → Add Package Dependencies...
   ```

3. **Add Firebase SDK**
   ```
   URL: https://github.com/firebase/firebase-ios-sdk
   ```

4. **Select Required Packages**
   ```
   ☑️ FirebaseAuth      - Apple Sign-In integration
   ☑️ FirebaseFirestore - Cloud database for runs/users
   ☑️ FirebaseAnalytics - Event tracking and retention metrics
   ☑️ FirebaseCore      - Required foundation for all Firebase services
   ```

5. **Version Selection**
   ```
   Dependency Rule: Up to Next Major Version
   Version: 10.0.0 (or latest)
   ```

6. **Add to Target**
   ```
   Select: RunnerPrime (your main app target)
   ```

### Step 2: Verify Installation

After adding the packages, verify they appear in:
```
Project Navigator → Package Dependencies:
- firebase-ios-sdk
  ├── FirebaseAnalytics
  ├── FirebaseAuth  
  ├── FirebaseCore
  └── FirebaseFirestore
```

### Step 3: Import in Source Files

The following files already have the correct imports:

**RunnerPrimeApp.swift:**
```swift
import FirebaseCore
```

**FirebaseService.swift:**
```swift
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
```

**AnalyticsService.swift:**
```swift
import FirebaseAnalytics
```

### Step 4: Add GoogleService-Info.plist

1. **Download from Firebase Console**
   - Go to https://console.firebase.google.com
   - Select your project → Project Settings
   - Download `GoogleService-Info.plist`

2. **Add to Xcode Project**
   ```
   Drag GoogleService-Info.plist into Xcode
   ✅ Copy items if needed
   ✅ Add to target: RunnerPrime
   ```

3. **Verify Location**
   ```
   The file should appear in your project root alongside other source files
   ```

## 🚨 Common Issues & Solutions

### Package Resolution Fails
```bash
# Clear package cache
rm -rf ~/Library/Developer/Xcode/DerivedData
rm -rf ~/.swiftpm

# In Xcode:
File → Swift Packages → Reset Package Caches
```

### Build Errors After Adding
```bash
# Clean build folder
Product → Clean Build Folder (⇧⌘K)

# Reset package dependencies  
File → Swift Packages → Update to Latest Package Versions
```

### Import Errors
Make sure you've imported the correct modules:
```swift
// ✅ Correct
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import FirebaseAnalytics

// ❌ Wrong
import Firebase  // This doesn't exist
```

## 🎯 Firebase Console Setup

### 1. Create Firebase Project
1. Go to https://console.firebase.google.com
2. Click "Create a project"
3. Project name: "RunnerPrime"
4. Enable Google Analytics: Yes
5. Choose analytics account or create new one

### 2. Add iOS App
1. Click "Add app" → iOS
2. Bundle ID: `com.yourteam.runnerprime` (match your Xcode project)
3. App nickname: "RunnerPrime"
4. Download `GoogleService-Info.plist`

### 3. Enable Authentication
```
Authentication → Sign-in method → Apple → Enable
- No additional configuration needed for Apple Sign-In
```

### 4. Create Firestore Database
```
Firestore Database → Create database
- Start in test mode (for development)
- Choose location: asia-south1 (Mumbai) for Indian users
```

### 5. Enable Analytics
```
Analytics → Dashboard
- Should be enabled by default if you chose it during project creation
- Events will appear here after app usage
```

## 🔧 Build Configuration

### App-Level Configuration (Already Done)
The following is already configured in your app:

**Info.plist additions needed:**
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>RunnerPrime needs location access to track your runs and calculate territory claims.</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Background location allows RunnerPrime to continue tracking during runs even when the app isn't active.</string>

<key>NSHealthShareUsageDescription</key>
<string>Connect with Apple Health to import your workout history and enhance your running analytics.</string>
```

### Capabilities Required
```
Target → Signing & Capabilities:
☑️ Sign in with Apple
☑️ Background Modes → Location updates
☑️ Push Notifications (for future features)
```

## ✅ Verification Checklist

After adding Firebase dependencies, verify:

- [ ] Firebase packages appear in Package Dependencies
- [ ] GoogleService-Info.plist is in project root
- [ ] App builds without errors
- [ ] Firebase console shows your iOS app
- [ ] Authentication, Firestore, and Analytics are enabled
- [ ] Required capabilities are configured
- [ ] Privacy strings are added to Info.plist

## 🚀 Testing Firebase Integration

### Test Authentication
```swift
// This should work without errors after setup:
import FirebaseAuth

// In your app:
FirebaseService.shared.configure()
print("Firebase configured successfully")
```

### Test Firestore Connection
```swift
// This should connect without errors:
import FirebaseFirestore

let db = Firestore.firestore()
db.collection("test").document("test").setData(["test": true])
```

### Test Analytics
```swift
// This should log events:
import FirebaseAnalytics

Analytics.logEvent("app_configured", parameters: nil)
```

## 📱 Platform Support

**Minimum Requirements:**
- iOS 15.0+
- Xcode 15.0+
- Swift 5.9+

**Firebase SDK Compatibility:**
- Firebase iOS SDK 10.x supports iOS 12.0+
- All RunnerPrime features work on iOS 15.0+

## 📚 Additional Resources

- [Firebase iOS Documentation](https://firebase.google.com/docs/ios/setup)
- [Firebase Console](https://console.firebase.google.com)
- [Apple Sign-In Documentation](https://firebase.google.com/docs/auth/ios/apple)
- [Firestore Documentation](https://firebase.google.com/docs/firestore/quickstart)
- [Firebase Analytics Documentation](https://firebase.google.com/docs/analytics/ios/start)

---

**Next Steps:** 
After completing this setup, your RunnerPrime app will have full Firebase integration for authentication, data storage, and analytics tracking! 🚀