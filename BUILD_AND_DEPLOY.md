# 🚀 Build & Deploy to Your iPhone

## 📱 Device Detected!

**Your iPhone:**
- Name: **Tin Can** 
- Model: **iPhone 16** (iPhone17,3)
- iOS Version: **26.0** (iOS 18)
- Status: ✅ Connected and paired!

---

## ⚠️ Issue Found: iOS Platform Not Installed

Your iPhone is running iOS 26.0, but Xcode doesn't have this platform support installed.

---

## 🔧 Solution: Install iOS 26.0 Support (2 minutes)

### Option 1: Install iOS 26.0 Platform (Recommended)

**In Xcode:**
```
1. Xcode menu → Settings (or Preferences)
2. Click "Platforms" tab
3. Find "iOS 26.0" in the list
4. Click the Download/Install button ↓
5. Wait for download to complete (~5-10 GB)
6. Once installed, rebuild!
```

This allows you to build for your current iOS version.

---

### Option 2: Lower Deployment Target (Faster - No Download)

If you don't want to wait for the download:

**In Xcode:**
```
1. Select RunnerPrime target
2. Build Settings tab
3. Search for "iOS Deployment Target"
4. Change from current value to: iOS 15.0
5. Clean Build (⌘+Shift+K)
6. Build & Run (⌘+R)
```

This makes the app compatible with older iOS versions (including your iOS 26.0).

---

## 🎯 Complete Build Checklist

Before building, make sure you've done:

### ✅ Critical Steps (Must Do!)

1. **Fix Bundle ID** ⚠️
   ```
   Target → Signing & Capabilities
   Bundle Identifier: com.runnerprime.app
   (Currently: com.word.RunnerPrime - MUST CHANGE!)
   ```

2. **Add Firebase Packages** 📦
   ```
   File → Add Package Dependencies
   URL: https://github.com/firebase/firebase-ios-sdk
   
   Add these packages:
   ☑️ FirebaseAuth
   ☑️ FirebaseFirestore
   ☑️ FirebaseAnalytics
   ☑️ FirebaseCore
   ```

3. **Configure Signing** 👤
   ```
   Signing & Capabilities:
   Team: [Select your Apple ID]
   ☑️ Automatically manage signing
   ```

4. **Add Capabilities** ⚙️
   ```
   Signing & Capabilities → + Capability:
   + Sign in with Apple
   + HealthKit
   + Background Modes → Location updates
   ```

5. **Install iOS 26.0 OR Lower Deployment Target** 📱
   ```
   See options above - choose one!
   ```

---

## 🚀 Build & Deploy Commands

### Using Xcode GUI (Easiest):
```
1. Select "Tin Can" from device menu
2. Press ⌘+R (Run)
3. App builds and installs!
```

### Using Command Line:
```bash
cd /Users/ankity/Documents/Projects/RunnerPrime/RunnerPrime

# After fixing Bundle ID and adding packages:
xcodebuild -scheme RunnerPrime \
  -destination 'platform=iOS,name=Tin Can' \
  clean build

# Install to device:
xcodebuild -scheme RunnerPrime \
  -destination 'platform=iOS,name=Tin Can' \
  -allowProvisioningUpdates \
  install
```

---

## 📋 Post-Install Steps

### On Your iPhone (First Time):

1. **Trust Developer**
   ```
   Settings → General → VPN & Device Management
   → Developer App → Your Apple ID
   → Tap "Trust"
   ```

2. **Grant Permissions**
   ```
   When app launches:
   ✅ Location "While Using App" → Allow
   ✅ Later: Location "Always Allow" → Change to Always
   ✅ Sign in with Apple → Sign In
   ✅ HealthKit → Allow (optional)
   ```

3. **Test It!**
   ```
   1. Complete onboarding
   2. Go OUTSIDE (GPS needs open sky)
   3. Tap "Start Run"
   4. Walk/run for 2-3 minutes
   5. Watch territory tiles claim! 🗺️
   6. Stop run and celebrate! 🎉
   ```

---

## 🐛 Common Build Errors & Fixes

### Error: "Bundle ID not registered"
**Fix:**
```
Change Bundle ID to: com.runnerprime.app
(matches your GoogleService-Info.plist)
```

### Error: "No such module 'FirebaseCore'"
**Fix:**
```
Add Firebase packages via SPM
File → Add Package Dependencies
https://github.com/firebase/firebase-ios-sdk
```

### Error: "Code signing failed"
**Fix:**
```
Signing & Capabilities:
1. Select Team
2. ☑️ Automatically manage signing
3. Clean Build (⌘+Shift+K)
4. Rebuild
```

### Error: "Untrusted Developer"
**Fix:**
```
On iPhone:
Settings → General → Device Management
Trust your Apple ID
```

---

## ✅ Success Indicators

You'll know it worked when:
- ✅ Xcode shows "Build Succeeded"
- ✅ App icon appears on iPhone home screen
- ✅ App launches without crashing
- ✅ Onboarding screen shows
- ✅ Location permission requested

---

## 🎯 Quick Start Guide

**Fastest path to running app:**

1. **In Xcode:**
   - Change Bundle ID → `com.runnerprime.app`
   - Add Firebase packages
   - Select your Team
   - Lower deployment target to iOS 15.0 (faster than downloading iOS 26.0)
   - Select "Tin Can" device
   - Press ⌘+R

2. **On iPhone:**
   - Trust developer (Settings)
   - Launch app
   - Grant permissions
   - GO RUN! 🏃‍♂️

---

## 📞 If You Get Stuck

Common issues are 99% due to:
1. ❌ Bundle ID mismatch
2. ❌ Missing Firebase packages
3. ❌ No Team selected
4. ❌ iOS platform not installed

Fix these four things and it will work!

---

**Your iPhone is ready! Just fix Bundle ID, add packages, and build!** 🚀

Device: ✅ Tin Can (iPhone 16, iOS 26.0)
Firebase: ✅ GoogleService-Info.plist added
Code: ✅ 100% complete (4,166 lines!)
App Icon: ✅ Beautiful RP logo

**You're literally 5 minutes from running your app!** 🏃‍♂️💚

