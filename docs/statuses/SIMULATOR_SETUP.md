# 📱 Running RunnerPrime on iOS 15 Simulator

## ⚠️ IMPORTANT: Simulator Limitations

**GPS/Location Features are LIMITED on simulator:**
- ✅ Basic location permissions work
- ✅ Simulated locations work
- ⚠️ GPS accuracy is poor
- ❌ Background location tracking doesn't work properly
- ❌ Real-time GPS updates are unreliable
- ❌ Territory tile calculations may not work accurately

**For REAL testing, you MUST use a physical iPhone!** 🏃‍♂️

But simulator is great for:
- ✅ Testing UI/UX
- ✅ Testing onboarding flow
- ✅ Testing Firebase authentication
- ✅ Testing app navigation
- ✅ Testing settings screens

---

## 🚀 Quick Setup for Simulator

### Step 1: Fix Bundle ID First! ⚠️

**CRITICAL:** Your Bundle IDs don't match!

In Xcode:
```
1. Select RunnerPrime target
2. Signing & Capabilities tab
3. Change Bundle Identifier to: com.runnerprime.app
   (to match your GoogleService-Info.plist)
```

### Step 2: Add Firebase Packages (Required!)

```
File → Add Package Dependencies
URL: https://github.com/firebase/firebase-ios-sdk

Select these packages:
☑️ FirebaseAuth
☑️ FirebaseFirestore
☑️ FirebaseAnalytics
☑️ FirebaseCore
```

### Step 3: Configure Capabilities

```
Target → Signing & Capabilities:

Add:
+ Sign in with Apple
+ HealthKit (will show warning on simulator - ignore)
+ Background Modes → Location updates

Build Settings:
CODE_SIGN_ENTITLEMENTS: RunnerPrime/RunnerPrime.entitlements
```

### Step 4: Disable Code Signing for Simulator (if needed)

```
Build Settings → Search "Code Signing"
CODE_SIGN_IDENTITY[sdk=iphonesimulator*]: -
```

### Step 5: Select iOS 15 Simulator

```
1. Xcode toolbar → Click device selector
2. Choose: iPhone 13 (iOS 15.x) or similar
3. If no iOS 15 simulator, download it:
   Xcode → Settings → Platforms → iOS 15.x → Download
```

### Step 6: Build & Run!

```
Press ⌘+R or click Play button
```

---

## 🗺️ Simulating GPS Location

Once the app is running:

### Method 1: Simulate Location in Xcode
```
Debug Menu → Simulate Location → Choose:
- City Run (Bengaluru, Mumbai, etc.)
- Custom Location (enter coordinates)
- Apple (Cupertino - for testing)
```

### Method 2: Use GPX File
```
1. Create a GPX file with coordinates
2. Debug → Simulate Location → Add GPX File
3. Play the route
```

### Sample GPX for Testing:
Create `TestRun.gpx` in your project:

```xml
<?xml version="1.0"?>
<gpx version="1.1" creator="RunnerPrime">
  <trk>
    <name>Test Run</name>
    <trkseg>
      <!-- Bengaluru coordinates example -->
      <trkpt lat="12.9716" lon="77.5946"><time>2024-01-01T10:00:00Z</time></trkpt>
      <trkpt lat="12.9726" lon="77.5956"><time>2024-01-01T10:00:30Z</time></trkpt>
      <trkpt lat="12.9736" lon="77.5966"><time>2024-01-01T10:01:00Z</time></trkpt>
      <!-- Add more points for longer run -->
    </trkseg>
  </trk>
</gpx>
```

---

## 🐛 Common Simulator Issues & Fixes

### Issue: Build fails with signing error
**Fix:** 
```
Target → Signing & Capabilities
Team: Select "None" or your personal team
```

### Issue: "App installation failed"
**Fix:**
```
1. Reset simulator: Device → Erase All Content and Settings
2. Clean build: ⌘+Shift+K
3. Rebuild: ⌘+B
```

### Issue: HealthKit not available
**Fix:** This is EXPECTED on simulator. HealthKit requires real device.
```
Your app will show: "HealthKit not available"
This is normal and won't crash the app.
```

### Issue: Background location doesn't work
**Fix:** This is NORMAL on simulator. Background location requires real device.

### Issue: Sign in with Apple fails
**Fix:**
```
1. Simulator → Features → Sign In → Apple ID
2. Use a test Apple ID
3. Or test on device for real Sign in with Apple
```

### Issue: Firebase connection fails
**Fix:**
```
1. Check GoogleService-Info.plist is in project
2. Verify Bundle ID matches: com.runnerprime.app
3. Enable Analytics in Firebase Console
```

---

## 🎯 What You CAN Test on Simulator

### ✅ Onboarding Flow
- Welcome screen
- Location permission request (will work)
- Sign in with Apple (limited)
- Onboarding completion

### ✅ Home Screen
- UI layout
- Start run button
- Navigation

### ✅ Settings
- All settings screens
- UI/UX testing
- Theme and colors

### ✅ Firebase Integration
- Authentication (with test Apple ID)
- Firestore read/write
- Basic cloud sync

---

## ❌ What You CANNOT Test on Simulator

### ❌ Real GPS Tracking
- Accurate distance calculation
- Proper pace tracking
- Real-time location updates

### ❌ Territory System
- Accurate tile claiming (GPS-dependent)
- Territory area calculations
- Map overlay accuracy

### ❌ Background Tracking
- App in background
- Location updates when not active

### ❌ HealthKit
- Workout import
- Health data sync
- Requires physical device

### ❌ Real Run Experience
- Battery usage
- GPS accuracy
- Performance under movement

---

## 📱 For REAL Testing: Use iPhone

After basic simulator testing:

```
1. Connect your iPhone via USB
2. Select your iPhone in device selector
3. Trust the computer on iPhone
4. Build & Run (⌘+R)
5. Go outside and test a real run! 🏃‍♂️
```

---

## 🚀 Quick Command Reference

```bash
# List available simulators
xcrun simctl list devices

# Boot a specific simulator
xcrun simctl boot "iPhone 13"

# Install app on simulator
xcrun simctl install booted YourApp.app

# Reset simulator
xcrun simctl erase "iPhone 13"
```

---

## 🎯 Recommended Testing Flow

### Phase 1: Simulator (UI/UX)
1. ✅ Test onboarding flow
2. ✅ Test navigation
3. ✅ Test settings
4. ✅ Test Firebase auth (basic)
5. ✅ Test UI responsiveness

### Phase 2: Device (GPS Features)
1. 🏃‍♂️ Test real GPS tracking
2. 🗺️ Test territory claiming
3. 🔋 Test background tracking
4. ❤️ Test HealthKit integration
5. 📊 Test real run recording

---

## 📋 Pre-Launch Checklist

Before running on simulator:

- [ ] Bundle ID changed to: `com.runnerprime.app`
- [ ] Firebase packages added via SPM
- [ ] GoogleService-Info.plist in project
- [ ] Capabilities configured (Sign in, HealthKit, Background)
- [ ] iOS 15+ simulator selected
- [ ] Build settings configured

---

## 💡 Pro Tips

1. **Use Simulator for Speed**: Iterate quickly on UI/UX
2. **Use Device for GPS**: Always test location features on real device
3. **Test Both**: Simulator for dev, device for final testing
4. **GPX Files**: Create test routes for repeatable testing
5. **Console Logs**: Watch Xcode console for Firebase/location logs

---

**Remember: Simulator is for UI testing. Real device is for GPS testing!** 🏃‍♂️

Your app will run on simulator, but location features will be limited. 
That's normal and expected for GPS-based apps!

---

*Ready to test? Fix Bundle ID, add Firebase packages, and press ⌘+R!* 🚀

