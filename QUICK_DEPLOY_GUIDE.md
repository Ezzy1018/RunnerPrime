# RunnerPrime - Quick Deploy Guide 🚀

## TL;DR - Fast Track to App Store

### Prerequisites (One-Time Setup)
1. **Apple Developer Account** ($99/year)
   - Enroll at: https://developer.apple.com/programs/enroll/
   - Wait for approval (24-48 hours)

2. **App Store Connect Access**
   - Same Apple ID as Developer Account
   - Access at: https://appstoreconnect.apple.com/

### Quick Steps (2-3 Hours Total)

#### STEP 1: App Icons (15 minutes)
```bash
# 1. Go to https://www.appicon.co/
# 2. Upload: RunnerPrime/assets/RP logo.png
# 3. Download the icon set
# 4. Replace contents of:
#    RunnerPrime/RunnerPrime/Assets.xcassets/AppIcon.appiconset/
```

#### STEP 2: Screenshots (30 minutes)
```bash
# Open iPhone 15 Pro Max simulator
open -a Simulator

# Run app in Xcode
# Take 5 screenshots (Cmd+S):
# 1. Home screen
# 2. Active run
# 3. Run history
# 4. Run detail with map
# 5. Onboarding (optional)
```

#### STEP 3: Host Privacy Policy (10 minutes)

**Option A - GitHub Pages (Free & Fast)**:
```bash
cd /Users/ankity/Documents/Projects/RunnerPrime

# Create gh-pages branch
git checkout -b gh-pages

# Copy privacy policy
cp PRIVACY_POLICY.md index.md
cp TERMS_OF_SERVICE.md terms.md

# Commit and push
git add index.md terms.md
git commit -m "Add privacy policy and terms"
git push origin gh-pages

# Enable GitHub Pages in repo settings
# Your URLs will be:
# https://[username].github.io/RunnerPrime/
# https://[username].github.io/RunnerPrime/terms
```

**Option B - Host on Your Domain**:
Upload PRIVACY_POLICY.md and TERMS_OF_SERVICE.md to your website.

#### STEP 4: Create App Store Listing (30 minutes)
```
1. Go to https://appstoreconnect.apple.com/
2. Click "My Apps" → "+" → "New App"
3. Fill in basic info:
   - Name: RunnerPrime
   - Language: English
   - Bundle ID: com.runnerprime.app
   - SKU: com.runnerprime.app.1.0
   
4. Go to "App Information":
   - Copy from APP_STORE_METADATA.md
   - Add Privacy Policy URL
   - Add Support URL
   
5. Upload screenshots (6.7", 6.5", 5.5" displays)

6. Fill in App Privacy:
   - Location: Yes (for tracking)
   - Health & Fitness: Yes
   - User ID: Yes (if using Apple Sign In)
```

#### STEP 5: Build & Upload (20 minutes)
```bash
# Option A: Use our script (Easiest)
cd /Users/ankity/Documents/Projects/RunnerPrime
./build-and-upload.sh

# Follow prompts to open Organizer
# Click "Distribute App" → "App Store Connect" → "Upload"

# Option B: Use Xcode GUI
# 1. Open RunnerPrime.xcodeproj
# 2. Select "Any iOS Device (arm64)"
# 3. Product → Archive (Cmd+Shift+B wait ~5 min)
# 4. In Organizer: "Distribute App" → "Upload"
```

#### STEP 6: Submit for Review (15 minutes)
```
1. Wait 5-15 minutes for build to process
2. In App Store Connect → Version 1.0:
   - Select the uploaded build
   - Add review notes (from APP_STORE_METADATA.md)
   - Add contact information
   - Click "Submit for Review"
   
3. Review typically takes 1-3 days
```

---

## What If You Hit Issues?

### Issue: "No Code Signing Identity Found"
**Solution**:
```
1. Xcode → Settings → Accounts
2. Add your Apple ID
3. Download certificates
4. In project: Signing & Capabilities → Team → Select your team
```

### Issue: "Bundle ID Already in Use"
**Solution**:
```
1. Check if you registered it in App Store Connect
2. Or change to: com.runnerprime.ios or com.yourname.runnerprime
3. Update in Xcode: Target → Signing & Capabilities
```

### Issue: "Privacy Policy URL Required"
**Solution**:
Host PRIVACY_POLICY.md online (see Step 3 above)

### Issue: "Screenshots Wrong Size"
**Solution**:
```
# Use correct simulator:
- iPhone 15 Pro Max (6.7")
- iPhone 11 Pro Max (6.5") 
- iPhone 8 Plus (5.5")

# Save with Cmd+S in Simulator
# Or use Device → Screenshot in Simulator menu
```

### Issue: "App Crashes During Review"
**Solution**:
```
# Test on real device first:
1. Connect iPhone via USB
2. Select your iPhone in Xcode
3. Product → Run
4. Test all features thoroughly
```

---

## Files Created for You

✅ **DEPLOYMENT_GUIDE.md** - Complete deployment documentation  
✅ **PRIVACY_POLICY.md** - Privacy policy template  
✅ **TERMS_OF_SERVICE.md** - Terms of service template  
✅ **APP_STORE_METADATA.md** - All metadata & descriptions  
✅ **ExportOptions.plist** - Build export configuration  
✅ **build-and-upload.sh** - Automated build script  

---

## Timeline Estimate

| Task | Time | Difficulty |
|------|------|------------|
| Apple Developer enrollment | 24-48h | Easy |
| App icons generation | 15 min | Easy |
| Take screenshots | 30 min | Easy |
| Host privacy policy | 10 min | Easy |
| Create App Store listing | 30 min | Medium |
| Build & upload | 20 min | Easy |
| Submit for review | 15 min | Easy |
| **Total active time** | **~2 hours** | |
| Apple review time | 1-3 days | - |
| **Total to launch** | **3-5 days** | |

---

## Pro Tips 🎯

1. **Test on Real Device**: Connect your iPhone and test everything
2. **Check Location**: Make sure GPS works outdoors
3. **Battery Test**: Run app for 30+ minutes to check battery impact
4. **Screenshots Look Good**: Use clean data, not "0.00 km" everywhere
5. **Privacy Policy**: MUST be hosted online before submission
6. **Backup**: Commit all changes to git before archiving

---

## After Approval 🎉

Once your app is approved:

1. **Set Release**:
   - Automatic: Goes live immediately
   - Manual: You control when to release
   - Scheduled: Set a specific date/time

2. **Monitor**:
   - Check crash reports in App Store Connect
   - Monitor reviews and respond
   - Track downloads and analytics

3. **Update**:
   - Increment version (1.1, 1.2, etc.)
   - Increment build number
   - Archive and upload again
   - Same review process

---

## Need Help?

**Documentation**:
- DEPLOYMENT_GUIDE.md (detailed guide)
- APP_STORE_METADATA.md (all copy & descriptions)
- PRIVACY_POLICY.md (legal document)
- TERMS_OF_SERVICE.md (legal document)

**Apple Resources**:
- Developer: https://developer.apple.com/
- App Store Connect: https://appstoreconnect.apple.com/
- Review Guidelines: https://developer.apple.com/app-store/review/guidelines/
- Human Interface Guidelines: https://developer.apple.com/design/human-interface-guidelines/

**Common Questions**:
- TestFlight beta: https://developer.apple.com/testflight/
- App rejection appeals: Use Resolution Center in App Store Connect
- Expedited review: Request only for critical bug fixes

---

## Ready to Deploy?

**Your Next Action Items**:

1. [ ] Ensure you have Apple Developer Account ($99/year)
2. [ ] Generate app icons using appicon.co
3. [ ] Take 5 screenshots in iPhone simulators
4. [ ] Host PRIVACY_POLICY.md on GitHub Pages or your site
5. [ ] Run: `./build-and-upload.sh`
6. [ ] Create App Store Connect listing
7. [ ] Submit for review

**Estimated Time**: 2-3 hours of active work  
**Expected Review Time**: 1-3 days  
**Total Time to Launch**: 3-5 days

---

**Let's ship this! 🚀**

Built with love in India 🇮🇳

