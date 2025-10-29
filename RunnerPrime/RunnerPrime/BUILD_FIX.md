# 🔧 Build Error Fix: Multiple Info.plist Commands

**Error**: `Multiple commands produce '/Users/ankity/Library/Developer/Xcode/DerivedData/RunnerPrime-fuhwmwsgnmdpyibxrrlkujtazbvh/Build/Products/Debug-iphoneos/RunnerPrime.app/Info.plist'`

## 🎯 Quick Fix Steps

### Step 1: Clean Build Environment
```bash
# In Xcode:
1. Product → Clean Build Folder (⇧⌘K)
2. Quit Xcode completely
3. Delete DerivedData folder
```

**Terminal command to delete DerivedData:**
```bash
rm -rf ~/Library/Developer/Xcode/DerivedData
```

### Step 2: Check for Duplicate Info.plist Files

1. **Open Xcode Project Navigator**
2. **Search for "Info.plist"** (⌘F in project navigator)
3. **You should see ONLY ONE Info.plist file**

**If you see multiple Info.plist files:**
- Keep only the one in your main app target
- Delete any duplicates (right-click → Delete → Move to Trash)

### Step 3: Verify Build Settings

1. **Select RunnerPrime target** (not project)
2. **Build Settings tab**
3. **Search for "Info.plist"**
4. **Verify these settings:**

```
Info.plist File: RunnerPrime/Info.plist
Generate Info.plist File: NO
```

### Step 4: Check Firebase Configuration

**If you added GoogleService-Info.plist:**
1. **Verify it's added correctly** to the project (not just dragged into folder)
2. **Check target membership**: Select GoogleService-Info.plist → File Inspector → Target Membership → ✅ RunnerPrime

### Step 5: Fix RunRecorder Initialization Issue

The ContentView.swift has been updated to fix the RunRecorder initialization. The issue was:

**Before (Incorrect):**
```swift
RunRecorder(locationManager: LocationManager()) // Creates circular dependency
```

**After (Fixed):**
```swift
RunRecorder() // Will be bound in RunnerPrimeApp.swift
```

### Step 6: Rebuild Project

1. **Open Terminal in project directory**
2. **Clean everything:**
```bash
# Delete build artifacts
rm -rf ~/Library/Developer/Xcode/DerivedData/RunnerPrime*

# Clean Swift Package Manager cache
rm -rf ~/Library/Caches/org.swift.swiftpm
```

3. **In Xcode:**
```bash
Product → Clean Build Folder
File → Swift Packages → Reset Package Caches
Product → Build (⌘B)
```

## 🚨 Advanced Troubleshooting

### If Error Persists: Check Build Phases

1. **RunnerPrime target → Build Phases**
2. **Copy Bundle Resources** section
3. **Verify these files are listed ONLY ONCE:**
   - Info.plist (should NOT be here)
   - GoogleService-Info.plist (should be here)
   - Assets.xcassets

### Remove Info.plist from Copy Bundle Resources

**If Info.plist appears in Copy Bundle Resources:**
1. **Select Info.plist** in that section
2. **Click the minus (-)** button to remove it
3. **Info.plist should NOT be copied as a bundle resource**

### Check for Conflicting Targets

1. **Project Navigator → RunnerPrime (blue icon)**
2. **TARGETS section should show:**
   - ✅ RunnerPrime (app target)
   - ✅ RunnerPrimeTests (test target)
   - ❌ No duplicate app targets

### Verify Bundle Identifier

1. **RunnerPrime target → General tab**
2. **Bundle Identifier**: `com.yourname.runnerprime` (must be unique)
3. **Should match** what you set up in Firebase console

## 🔧 Manual Info.plist Creation (Last Resort)

If all else fails, create a new Info.plist:

1. **Delete existing Info.plist**
2. **Right-click project → New File**
3. **iOS → Resource → Property List**
4. **Name it "Info.plist"**
5. **Add to RunnerPrime target**

**Then add these key entries:**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>en</string>
	<key>CFBundleDisplayName</key>
	<string>RunnerPrime</string>
	<key>CFBundleExecutable</key>
	<string>$(EXECUTABLE_NAME)</string>
	<key>CFBundleIdentifier</key>
	<string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>$(PRODUCT_NAME)</string>
	<key>CFBundlePackageType</key>
	<string>APPL</string>
	<key>CFBundleShortVersionString</key>
	<string>1.0</string>
	<key>CFBundleVersion</key>
	<string>1</string>
	<key>LSRequiresIPhoneOS</key>
	<true/>
	<key>NSLocationWhenInUseUsageDescription</key>
	<string>RunnerPrime needs location access to track your runs and calculate territory claims.</string>
	<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
	<string>Background location allows RunnerPrime to continue tracking during runs even when the app isn't active.</string>
	<key>UIBackgroundModes</key>
	<array>
		<string>location</string>
	</array>
	<key>UILaunchStoryboardName</key>
	<string>LaunchScreen</string>
	<key>UIRequiredDeviceCapabilities</key>
	<array>
		<string>location-services</string>
	</array>
	<key>UISupportedInterfaceOrientations</key>
	<array>
		<string>UIInterfaceOrientationPortrait</string>
	</array>
	<key>UIUserInterfaceStyle</key>
	<string>Dark</string>
</dict>
</plist>
```

## ✅ Verification Steps

After applying fixes:

1. **Build succeeds** without Info.plist error
2. **App installs** on device/simulator
3. **Location permissions** prompt appears
4. **Dark theme** displays correctly
5. **Firebase** initializes (check debug console)

## 🎯 Most Common Cause

**99% of the time, this error is caused by:**
1. **DerivedData corruption** - Fixed by cleaning
2. **Duplicate Info.plist files** - Fixed by removing duplicates
3. **Info.plist in wrong build phase** - Fixed by removing from Copy Bundle Resources

## 📞 If Still Having Issues

**Check these final items:**
- [ ] Only ONE Info.plist file in project
- [ ] Info.plist NOT in Copy Bundle Resources build phase
- [ ] GoogleService-Info.plist IS in Copy Bundle Resources
- [ ] Bundle identifier is unique and valid
- [ ] No conflicting app targets
- [ ] DerivedData cleaned completely

**Debug command to see what's generating Info.plist:**
```bash
# In Terminal, from project directory:
find . -name "Info.plist" -type f
```

Should show only: `./RunnerPrime/Info.plist`

---

**After following these steps, your RunnerPrime app should build successfully!** 🚀📱