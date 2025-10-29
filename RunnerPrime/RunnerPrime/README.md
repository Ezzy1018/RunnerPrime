# RunnerPrime — iOS MVP (Scaffold)

This scaffold contains the minimal Swift / SwiftUI code to get a working skeleton for the RunnerPrime app (run recording, map view, territory grid logic stub, Sign in with Apple flow placeholder).

## What is included
- App entry: `RunnerPrimeApp.swift`
- Location & run core: `LocationManager.swift`, `RunRecorder.swift`, `RunModel.swift`
- Map view wrapper: `RunMapView.swift`
- Simple UI screens: `HomeView.swift`, `RunView.swift`, `SignInView.swift`
- Service placeholders: `FirebaseService.swift`, `AnalyticsService.swift`, `HealthKitService.swift`
- `Assets` color palette & Localizable strings (placeholders)
- README with Firebase setup steps and TestFlight notes below.

## Next steps (what you need to do locally)
1. Open Xcode on your Mac and create a new project (App) named `RunnerPrime` with SwiftUI lifecycle. Alternatively add these files into a new project.
2. Add the files from this scaffold into the Xcode project.
3. Add Firebase using Swift Package Manager; or add `GoogleService-Info.plist` (downloaded from Firebase console) into the project when ready.
   - Firebase packages (via SPM): `FirebaseAuth`, `FirebaseFirestore`, `FirebaseAnalytics`, `FirebaseCore`
4. Configure Apple Sign In capability in Xcode (Signing & Capabilities) and register your app on Apple Developer portal.
5. Test on a real device for GPS accuracy (Simulator has limited GPS capability).

## Firebase quick setup (dev)
- Console: https://console.firebase.google.com
- Create project -> Add iOS app -> bundle id (e.g., com.runnerprime.app) -> download `GoogleService-Info.plist`
- Firestore -> create database in test mode for early dev
- Auth -> enable Sign in with Apple

## Notes
- This scaffold intentionally keeps logic minimal and focused on the run loop, map visualization and territory grid mapping stubs.
- Many production concerns (security rules, server-side validation, anti-cheat) are intentionally stubbed for MVP and will be added in a later iteration.

## Running locally
1. Create a new Xcode project or add these files into a new SwiftUI App project.
2. Add the provided Swift files to the project.
3. Add `GoogleService-Info.plist` to the project root when you create a Firebase app.
4. In Xcode: Signing & Capabilities -> enable Background Modes -> Location updates (for future iterations)
5. Build & run on a real device for accurate GPS testing.

## Firebase packages (SPM)
- In Xcode: File -> Swift Packages -> Add Package Dependency
  - https://github.com/firebase/firebase-ios-sdk
  - Select packages: FirebaseAuth, FirebaseFirestore, FirebaseAnalytics

## Testing GPS on Simulator
- Simulator -> Features -> Location -> select a predefined location or a GPX file (limited behaviour). For real runs, use device.

## Next recommended steps
- Integrate Firestore upload in `persist(run:)` in `RunRecorder` and call `FirebaseService.uploadRun`.
- Implement server-side Cloud Function for run validation if you want anti-cheat.
- Add HealthKit import and optional Strava sync after basic run loop is stable.
