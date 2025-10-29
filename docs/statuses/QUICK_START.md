# ⚡ RunnerPrime - Quick Start (5 Minutes!)

## ✅ DONE - No Action Needed!
- ✅ Codebase cleaned (removed 6 duplicate files)
- ✅ Files organized properly
- ✅ `RunnerPrime.entitlements` created
- ✅ `Info.plist` with privacy descriptions created
- ✅ **App icon set up** (your awesome RP logo!) 🎨

---

## 🔥 DO THESE NOW (Required!)

### 1. **Add Firebase Config** (2 mins)
```bash
1. Go to: https://console.firebase.google.com
2. Create/select project
3. Add iOS app → Bundle ID: com.word.RunnerPrime
4. Download GoogleService-Info.plist
5. Drag into Xcode (next to RunnerPrimeApp.swift)
6. Check "Copy items if needed" ✅
```

### 2. **Add Firebase Packages** (2 mins)
```bash
In Xcode:
File → Add Package Dependencies
URL: https://github.com/firebase/firebase-ios-sdk

Select these 4 packages:
☑️ FirebaseAuth
☑️ FirebaseFirestore  
☑️ FirebaseAnalytics
☑️ FirebaseCore
```

### 3. **Configure Capabilities** (1 min)
```bash
In Xcode → Target → Signing & Capabilities:

Add Capability → Sign in with Apple ✅
Add Capability → HealthKit ✅
Add Capability → Background Modes ✅
  ↳ Check: Location updates
  
Build Settings → Search: CODE_SIGN_ENTITLEMENTS
Set to: RunnerPrime/RunnerPrime.entitlements
```

### 4. **Select Team & Build** (30 secs)
```bash
Signing & Capabilities → Team: [Select your Apple Developer account]
Connect iPhone → Select as target
Press ⌘+R to build & run! 🚀
```

---

## 🎯 Enable in Firebase Console

After adding config file:

```bash
Firebase Console → Your Project:

1. Authentication → Sign-in method → Enable "Apple" ✅
2. Firestore Database → Create database → Start in test mode ✅
3. Analytics → Enable ✅
```

---

## 📱 First Run Test

When app launches:
1. Grant location permission
2. Complete onboarding
3. Optional: Sign in with Apple
4. Press "Start Run"
5. Go for a quick walk/run
6. Watch live stats update!
7. Stop run and see territory claimed! 🗺️

---

## 🐛 If Build Fails

**Error: "No such module Firebase"**
→ Add Firebase packages (step 2 above)

**Error: "GoogleService-Info.plist not found"**
→ Add config file (step 1 above)

**Error: "Code signing failed"**
→ Select your team in Signing & Capabilities

---

## 📚 Full Documentation

- `SETUP_GUIDE.md` - Complete setup instructions
- `CLEANUP_SUMMARY.md` - What was cleaned/fixed
- `README.md` (in .xcodeproj) - Full app architecture

---

**Total time: ~5 minutes** ⏱️  
**Your app is ready to run!** 🏃‍♂️💚

*Bundle ID: com.word.RunnerPrime*  
*iOS Target: 15.6+*

