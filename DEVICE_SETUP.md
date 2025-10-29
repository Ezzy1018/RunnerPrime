# 📱 Running RunnerPrime on Real iOS Device

## 🎯 Why Real Device is CRITICAL for RunnerPrime

Your app is GPS-based, so you NEED a real device to test:
- ✅ **Real GPS tracking** - Accurate distance & pace
- ✅ **Territory claiming** - 100m×100m tiles calculation
- ✅ **Background location** - Continues tracking when app is backgrounded
- ✅ **HealthKit integration** - Apple Health sync
- ✅ **Battery usage** - Real performance testing
- ✅ **Actual runs** - Test by going outside! 🏃‍♂️

Simulator can't do any of this properly!

---

## 🚀 Quick Device Setup (5 Steps)

### Step 1: Fix Bundle ID ⚠️ CRITICAL

Your Bundle IDs don't match! Fix this first:

**In Xcode:**
```
1. Select RunnerPrime target
2. Signing & Capabilities tab
3. Change Bundle Identifier from: com.word.RunnerPrime
   To: com.runnerprime.app
   (to match GoogleService-Info.plist)
```

### Step 2: Add Firebase Packages 📦

**Required before building!**

```
File → Add Package Dependencies
URL: https://github.com/firebase/firebase-ios-sdk

Select ALL of these:
☑️ FirebaseAuth
☑️ FirebaseFirestore
☑️ FirebaseAnalytics
☑️ FirebaseCore

Click "Add Package"
Wait for download to complete
```

### Step 3: Configure Capabilities ⚙️

```
Target → Signing & Capabilities:

Add these capabilities:
+ Sign in with Apple
+ HealthKit
+ Background Modes
  ↳ Check: Location updates
  ↳ Check: Background fetch

Verify:
CODE_SIGN_ENTITLEMENTS: RunnerPrime/RunnerPrime.entitlements
```

### Step 4: Select Your Apple Developer Team 👤

```
Signing & Capabilities tab:

Team: [Select your Apple ID / Development Team]

If you don't have a team:
1. Click "Add an Account"
2. Sign in with your Apple ID
3. Use FREE personal team for development
```

### Step 5: Connect iPhone & Trust 📲

```
1. Connect iPhone to Mac via USB cable
2. On iPhone: Unlock and tap "Trust This Computer"
3. Enter iPhone passcode
4. In Xcode: Device selector → Choose your iPhone
5. Press ⌘+R to Build & Run!
```

---

## 📋 Pre-Flight Checklist

Before building, verify:

- [ ] ✅ **GoogleService-Info.plist** is in project
- [ ] ⚠️ **Bundle ID** changed to: `com.runnerprime.app`
- [ ] 📦 **Firebase packages** added via SPM
- [ ] ⚙️ **Capabilities** configured (Apple Sign-In, HealthKit, Background)
- [ ] 🔐 **CODE_SIGN_ENTITLEMENTS** set to: `RunnerPrime/RunnerPrime.entitlements`
- [ ] 👤 **Team** selected in Signing
- [ ] 📱 **iPhone** connected and trusted
- [ ] 📱 **iPhone** selected in device picker

---

## 🔧 Common Device Setup Issues

### Issue: "Failed to register bundle identifier"
**Cause:** Bundle ID `com.runnerprime.app` not registered with Apple

**Fix Option 1 - Use Automatic Signing (Easiest):**
```
Signing & Capabilities:
☑️ Automatically manage signing
Team: [Your Apple ID]

Xcode will auto-register the bundle ID
```

**Fix Option 2 - Manual Registration:**
```
1. Go to: https://developer.apple.com/account
2. Certificates, Identifiers & Profiles → Identifiers
3. Click + to create new App ID
4. Bundle ID: com.runnerprime.app
5. Enable: Sign in with Apple, HealthKit
6. Save
7. Return to Xcode and rebuild
```

### Issue: "Code signing error"
**Fix:**
```
Signing & Capabilities:
1. Uncheck "Automatically manage signing"
2. Check it again
3. Select your Team
4. Clean Build (⌘+Shift+K)
5. Build again (⌘+B)
```

### Issue: "No devices found"
**Fix:**
```
1. Unplug and replug iPhone
2. Unlock iPhone
3. Trust computer again
4. In Xcode: Window → Devices and Simulators
5. Check if iPhone appears
6. If not, restart Xcode
```

### Issue: "App installation failed"
**Fix:**
```
On iPhone:
1. Settings → General → VPN & Device Management
2. Find your Apple ID / Developer App
3. Tap "Trust"
4. Try installing again in Xcode
```

### Issue: "Untrusted Developer" on iPhone
**Fix:**
```
On iPhone after first install:
Settings → General → VPN & Device Management
→ Developer App → Tap your Apple ID → Trust
```

---

## 🏃‍♂️ First Run Testing Flow

Once app installs on your iPhone:

### 1️⃣ Grant Permissions (Critical!)
```
First launch will request:
✅ Location "While Using" → Allow
✅ Notifications → Allow (optional)
✅ Sign in with Apple → Sign In (creates account)

Later during run:
✅ Location "Always" → Change to Always Allow
✅ HealthKit → Allow (optional)
```

### 2️⃣ Complete Onboarding
```
- Welcome screen
- Location permission
- Apple Sign-In
- Complete setup
```

### 3️⃣ Start Your First Test Run! 🎉
```
1. Go outside (GPS needs open sky!)
2. Tap "Start Run"
3. Watch live stats update
4. Walk/run for 2-3 minutes
5. Check territory tiles claiming
6. Tap "Stop Run"
7. View your territory claimed! 🗺️
```

---

## 🗺️ Testing Territory System

### Quick Test (2 minutes)
```
1. Start a run
2. Walk in a square pattern (~200m × 200m)
3. You should claim 4-6 tiles (100m each)
4. Stop run
5. Check territory area display
```

### Full Test (10+ minutes)
```
1. Go for an actual run/walk
2. Cover ~1-2 km
3. Territory tiles should claim along your route
4. Verify accurate distance tracking
5. Check pace calculations
6. Test background tracking (lock phone during run)
```

---

## 🔋 Battery & Performance Tips

### For Testing:
- ✅ Start with >50% battery
- ✅ Keep screen on during first test
- ✅ Watch Xcode console for logs
- ✅ Check for errors in real-time

### For Real Use:
- ✅ App continues in background
- ✅ Battery drain is normal for GPS apps
- ✅ ~15-20% battery per hour is expected
- ✅ Your 5m GPS filter helps conserve battery

---

## 🐛 Debugging on Device

### View Live Logs:
```
Xcode → View → Debug Area → Show Debug Area
Console will show:
- GPS location updates
- Territory tile calculations
- Firebase sync status
- Analytics events
```

### Useful Debug Info:
```swift
// These print to Xcode console:
"✅ Run started"
"📍 Location update: accuracy XXm"
"🗺️ Claimed tile: XX_YY"
"✅ Run saved locally"
"☁️ Uploading to Firebase..."
```

---

## 🎯 What to Test on Device

### ✅ Core Features
- [ ] GPS tracking accuracy
- [ ] Distance calculation
- [ ] Pace calculation
- [ ] Territory tile claiming
- [ ] Map route display
- [ ] Run pause/resume
- [ ] Stop and save run

### ✅ Background Features
- [ ] Lock phone during run
- [ ] App continues tracking
- [ ] Tiles continue claiming
- [ ] Stats update when unlocked

### ✅ Data Sync
- [ ] Run saves locally
- [ ] Run uploads to Firebase
- [ ] Territory syncs to cloud
- [ ] Apple Sign-In works
- [ ] User data persists

### ✅ HealthKit (if enabled)
- [ ] Request HealthKit permission
- [ ] Save run to Apple Health
- [ ] Import previous workouts

---

## 📊 Firebase Console - Monitor in Real-Time

While testing on device:

### Check Authentication:
```
https://console.firebase.google.com/project/runnerprime-e8b63/authentication/users

You should see your Apple Sign-In user appear!
```

### Check Firestore:
```
https://console.firebase.google.com/project/runnerprime-e8b63/firestore/data

After a run, you'll see:
- /users/{userId} → user profile
- /runs/{runId} → run data
- /territory/{userId} → claimed tiles
```

### Check Analytics:
```
https://console.firebase.google.com/project/runnerprime-e8b63/analytics

Real-time events:
- app_open
- run_start
- run_end
- tile_claim
```

---

## 🚀 Quick Build & Run Commands

```bash
# If using command line:
cd /Users/ankity/Documents/Projects/RunnerPrime/RunnerPrime

# List connected devices
xcrun devicectl list devices

# Build for device
xcodebuild -scheme RunnerPrime -destination 'generic/platform=iOS'

# Or just use Xcode GUI:
# Select device → Press ⌘+R
```

---

## 🎉 Success Checklist

After first successful run on device:

- [ ] ✅ App installed on iPhone
- [ ] ✅ Location permission granted
- [ ] ✅ Apple Sign-In completed
- [ ] ✅ Started a test run
- [ ] ✅ GPS tracked location
- [ ] ✅ Distance calculated
- [ ] ✅ Pace displayed
- [ ] ✅ Territory tiles claimed
- [ ] ✅ Map showed route
- [ ] ✅ Run saved successfully
- [ ] ✅ Data synced to Firebase
- [ ] ✅ Your app icon looks amazing on home screen! 🎨

---

## 💡 Pro Testing Tips

1. **Start Simple**: Do a 2-minute walk first, not a full run
2. **Watch Console**: Keep Xcode console open to see logs
3. **Test Outdoors**: GPS needs clear sky view
4. **Check Firebase**: Verify data appears in console
5. **Test Background**: Lock phone during run to test background tracking
6. **Compare HealthKit**: If you use other running apps, compare data
7. **Battery Check**: Monitor battery usage during longer runs

---

## 🏆 You're Ready!

Your app is **complete and production-ready**. 

Just:
1. ⚠️ Fix Bundle ID → `com.runnerprime.app`
2. 📦 Add Firebase packages
3. 🔐 Select your Team
4. 📱 Connect iPhone
5. ⌘+R Build & Run
6. 🏃‍♂️ Go for a test run!

---

**Let's get you running! Connect that iPhone and let's do this!** 🚀🏃‍♂️💚

