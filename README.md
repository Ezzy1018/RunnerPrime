# RunnerPrime 🏃‍♂️

> **Minimal luxury running for India** - Track your runs, claim territory, and build lasting fitness habits with our premium experience.

![RunnerPrime Logo](assets/RP%20logo.png)

[![Platform](https://img.shields.io/badge/Platform-iOS%2015%2B-blue)](https://www.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-5.9-orange)](https://swift.org)
[![SwiftUI](https://img.shields.io/badge/UI-SwiftUI-green)](https://developer.apple.com/swiftui/)
[![Firebase](https://img.shields.io/badge/Backend-Firebase-yellow)](https://firebase.google.com)

## 🎯 Mission

Help Indian runners form consistent fitness habits by making runs meaningful and visible through our unique **territory capture system** - "run, track, own".

---

## ✨ Features

- **🗺️ Territory Mapping**: Claim 100m×100m grid tiles as you run
- **📍 Precise GPS Tracking**: Accurate distance, pace, and route recording
- **☁️ Cloud Sync**: Secure backup with Apple Sign-In integration
- **🎨 Premium Design**: Dark theme with lime accents for minimal luxury
- **📊 Smart Analytics**: Track habits, progress, and achievements
- **🍎 Health Integration**: Connect with Apple Health for workout history

### Target Markets
- **Primary**: Bengaluru, Mumbai, Delhi
- **Users**: Urban weekend runners (25-40), fitness newcomers (20-35)
- **Languages**: English + Hindi support

---

## 🚀 Quick Start

### Prerequisites
- **Xcode**: 15.0+ with iOS 15+ deployment target
- **Apple Developer Account**: For Sign in with Apple capability
- **Firebase Project**: For backend services
- **Real Device**: GPS testing requires physical iPhone

### Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/Ezzy1018/RunnerPrime.git
   cd RunnerPrime
   ```

2. **Open in Xcode**
   ```bash
   open RunnerPrime/RunnerPrime.xcodeproj
   ```

3. **Configure Firebase**
   - Add your `GoogleService-Info.plist` to `RunnerPrime/RunnerPrime/`
   - Enable Authentication, Firestore, and Analytics in Firebase Console

4. **Build and Run**
   - Select a target device (physical device recommended for GPS)
   - Press ⌘+R to build and run

For detailed setup instructions, see [docs/statuses/SETUP_GUIDE.md](docs/statuses/SETUP_GUIDE.md)

---

## 📁 Project Structure

```
RunnerPrime/
├── assets/                      # Images and resources
│   └── RP logo.png             # App logo
├── docs/                       # Documentation
│   └── statuses/               # Status and setup guides
│       ├── SETUP_GUIDE.md      # Complete setup instructions
│       ├── FIREBASE_STATUS.md  # Firebase configuration
│       ├── DEVICE_SETUP.md     # Device setup guide
│       └── ...                 # Other status documents
├── RunnerPrime/                # Main app directory
│   ├── RunnerPrime/            # Source code
│   │   ├── *.swift             # Swift source files
│   │   ├── Assets.xcassets/    # App icons and colors
│   │   ├── Info.plist          # App configuration
│   │   └── GoogleService-Info.plist
│   └── RunnerPrime.xcodeproj/  # Xcode project
└── README.md                   # This file
```

### Core Files

**App Entry**
- `RunnerPrimeApp.swift` - App entry point with Firebase config
- `ContentView.swift` - Navigation container

**Core Features**
- `LocationManager.swift` - GPS tracking engine
- `RunRecorder.swift` - Run recording logic
- `RunModel.swift` - Data models
- `TileEngine.swift` - Territory grid system (100m tiles)
- `RunValidator.swift` - Anti-cheat validation

**Services**
- `FirebaseService.swift` - Cloud sync, Apple Sign-In
- `LocalStore.swift` - Local JSON persistence
- `AnalyticsService.swift` - Event tracking
- `HealthKitService.swift` - Apple Health integration
- `ShareGenerator.swift` - Social sharing

**Views**
- `OnboardingView.swift` - First-time user experience
- `HomeView.swift` - Main dashboard
- `RunView.swift` - Active run tracking
- `RunMapView.swift` - Map visualization
- `SettingsView.swift` - User preferences

---

## 🛠️ Tech Stack

- **Frontend**: Swift 5.9, SwiftUI, MapKit
- **Backend**: Firebase (Auth, Firestore, Analytics)
- **Storage**: Local JSON + Cloud Firestore
- **Maps**: Apple MapKit with custom overlays
- **Health**: HealthKit integration (optional)
- **Analytics**: Firebase Analytics

---

## 🎨 Design System

### Color Palette
- **Eerie Black**: `#1D1C1E` - Primary background
- **Lime**: `#D9FF54` - Accent color
- **White**: `#FDFCFA` - Text and UI elements

### Design Principles
- Dark-first design
- Generous spacing (16-24pt)
- Rounded corners (12-16pt)
- Smooth transitions (0.3s easing)
- Premium, minimal aesthetic

---

## 📊 Success Metrics

- **D1 Retention**: ≥40%
- **D7 Retention**: ≥20%
- **First Week Runs**: ≥35% of new users
- **Run Completion**: ≥85%
- **Territory Claims**: ≥3 tiles per active user per week
- **Crash-Free Rate**: ≥99%

---

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Style
- Follow SwiftLint rules
- Use camelCase for variables, PascalCase for types
- Document public APIs with `///`
- 120 character line limit

---

## 📄 License

MIT License - see LICENSE file for details.

Copyright (c) 2025 RunnerPrime Team

---

## 📞 Support

- **GitHub Issues**: [Report bugs or request features](https://github.com/Ezzy1018/RunnerPrime/issues)
- **Documentation**: See [docs/statuses/](docs/statuses/) for detailed guides
- **Firebase Setup**: [docs/statuses/FIREBASE_STATUS.md](docs/statuses/FIREBASE_STATUS.md)
- **Device Setup**: [docs/statuses/DEVICE_SETUP.md](docs/statuses/DEVICE_SETUP.md)

---

**Made with ❤️ for Indian runners**

*RunnerPrime - Run. Track. Own.*

