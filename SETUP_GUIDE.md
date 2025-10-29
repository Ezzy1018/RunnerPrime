# 🚀 RunnerPrime - Complete Setup Guide

## ✅ What's Already Done

Your codebase is now **clean and organized**! I've:
- ✅ Removed 6 duplicate files
- ✅ Moved misplaced files to correct locations
- ✅ Created `RunnerPrime.entitlements` with required capabilities
- ✅ Created `Info.plist` with all privacy descriptions

---

## 🔧 Manual Setup Required (Do These Next)

### 1. **Add Firebase Configuration** ⚠️ CRITICAL

You need to download `GoogleService-Info.plist` from Firebase:

**Steps:**
1. Go to https://console.firebase.google.com
2. Click "Create a project" or use existing
3. Enter project name: `RunnerPrime`
4. Click "Add app" → Select iOS
5. Enter Bundle ID: `com.word.RunnerPrime` ⚠️ (Must match your Xcode project!)
6. Download **GoogleService-Info.plist**
7. In Xcode: Drag the file into your project root (next to `RunnerPrimeApp.swift`)
8. **IMPORTANT**: Make sure "Copy items if needed" is checked ✅

**Enable Firebase Services:**
1. In Firebase Console → Authentication → Sign-in method
   - Enable **Apple** ✅
2. Firestore Database → Create database
   - Start in **Test mode** (for development)
   - Location: Choose nearest region (e.g., asia-south1 for India)
3. Analytics → Enable Google Analytics ✅

---

### 2. **Add Firebase Swift Packages** 📦

In Xcode:
1. File → Add Package Dependencies
2. Enter URL: `https://github.com/firebase/firebase-ios-sdk`
3. Version: Up to Next Major (11.0.0)
4. Select these packages:
   - ✅ `FirebaseAuth`
   - ✅ `FirebaseFirestore`
   - ✅ `FirebaseAnalytics`
   - ✅ `FirebaseCore`
5. Click "Add Package"

---

### 3. **Configure Xcode Project Settings** ⚙️

#### A. Add Entitlements File
1. In Xcode Project Navigator, select your target (RunnerPrime)
2. Go to "Signing & Capabilities" tab
3. Click "+ Capability"
4. Add these:
   - ✅ **Sign in with Apple**
   - ✅ **HealthKit**
   - ✅ **Background Modes**
     - Check: ✅ Location updates
     - Check: ✅ Background fetch

5. In Build Settings, search for "CODE_SIGN_ENTITLEMENTS"
6. Set to: `RunnerPrime/RunnerPrime.entitlements`

#### B. Configure Info.plist in Xcode
1. Select target → Info tab
2. The Info.plist I created should be detected
3. If not, in Build Settings search "INFOPLIST_FILE"
4. Set to: `RunnerPrime/Info.plist`

#### C. Configure Signing
1. Select your target → Signing & Capabilities
2. Choose your Team
3. Ensure "Automatically manage signing" is checked ✅

---

### 4. **Apple Developer Portal Setup** 🍎

For Sign in with Apple to work:

1. Go to https://developer.apple.com/account
2. Certificates, Identifiers & Profiles → Identifiers
3. Find your App ID (`com.word.RunnerPrime`)
4. Enable capabilities:
   - ✅ Sign in with Apple
   - ✅ HealthKit
5. Click "Save"

---

### 5. **Test on Real Device** 📱

⚠️ **GPS testing requires a physical iPhone!**

1. Connect your iPhone
2. Select it as the run destination in Xcode
3. Build & Run (⌘+R)
4. Grant permissions:
   - Location: "Allow While Using App" → later "Always Allow"
   - HealthKit: Optional
   - Notifications: Optional

---

## 📋 Verification Checklist

Before first run, verify:
- [ ] `GoogleService-Info.plist` in project root
- [ ] Firebase packages added via SPM
- [ ] Entitlements file referenced in Build Settings
- [ ] Info.plist configured
- [ ] Sign in with Apple capability enabled
- [ ] HealthKit capability enabled
- [ ] Background Modes configured
- [ ] Team selected for signing
- [ ] Apple Developer capabilities enabled
- [ ] Testing on real device (not simulator)

---

## 🎯 First Launch Testing

After setup, test these flows:

### 1. Onboarding
- [ ] Welcome screen shows
- [ ] Location permission request works
- [ ] Apple Sign-In flow completes
- [ ] Completes onboarding and shows home

### 2. Run Recording
- [ ] Start run button works
- [ ] GPS tracking shows live stats
- [ ] Map displays route
- [ ] Territory tiles calculate
- [ ] Stop run saves data

### 3. Data Sync
- [ ] Run uploads to Firebase
- [ ] Territory syncs to cloud
- [ ] Sign out works
- [ ] Sign back in restores data

---

## 🐛 Common Issues & Fixes

### Issue: "FirebaseApp.configure() failed"
**Fix:** Make sure `GoogleService-Info.plist` is in the project and added to target

### Issue: "No such module 'Firebase'"
**Fix:** Add Firebase packages via SPM (see step 2 above)

### Issue: "Code signing error"
**Fix:** Select your team in Signing & Capabilities

### Issue: "Location permission denied"
**Fix:** Settings → Privacy → Location → RunnerPrime → Allow

### Issue: "GPS not working in simulator"
**Fix:** Must test on real device for accurate GPS

### Issue: "Background tracking stops"
**Fix:** Verify Background Modes → Location updates is enabled

---

## 🎨 App Architecture

Your app includes:
- **15+ Swift files** - All implemented ✅
- **Territory System** - 100m×100m grid tiles
- **GPS Tracking** - Background-capable LocationManager
- **Firebase Integration** - Auth, Firestore, Analytics
- **Offline-First** - LocalStore with sync queue
- **Anti-Cheat** - Run validation with confidence scoring
- **HealthKit** - Apple Health integration
- **Premium Design** - Dark theme with lime accents

---

## 📊 Expected Behavior

### First Launch
1. Shows 3-step onboarding
2. Requests location permission
3. Offers Apple Sign-In (optional)
4. Shows home screen with "Start Run" button

### During Run
1. Live stats update (distance, time, pace)
2. Map shows route in real-time
3. Territory tiles highlight as claimed
4. Background tracking continues

### After Run
1. Run saves locally immediately
2. Uploads to Firebase when connected
3. Territory area displayed in m² or km²
4. Share option to social media

---

## 🔜 Next Steps After Setup

Once everything works:

1. **Add App Icon**
   - Design 1024×1024px icon
   - Add to Assets.xcassets/AppIcon

2. **Test Territory System**
   - Go for an actual run
   - Verify tiles are claimed correctly
   - Check area calculations

3. **Firebase Security Rules**
   - Set up Firestore rules for production
   - Implement server-side validation

4. **TestFlight**
   - Archive app for distribution
   - Upload to App Store Connect
   - Add beta testers

---

## 📞 Need Help?

If you encounter issues:
1. Check the common issues section above
2. Verify all checkboxes in verification checklist
3. Check Xcode console for error messages
4. Ensure Firebase is properly configured

---

**Your app is ready to run! 🏃‍♂️**

Just complete the manual setup steps above and you'll be tracking runs in no time!

---

_Last Updated: October 29, 2025_
_Bundle ID: com.word.RunnerPrime_
_iOS Deployment Target: 15.6+_

