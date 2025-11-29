# Kleen - Tinder-Style Photo Gallery Cleaner for iOS

<p align="center">
  <img src="https://img.shields.io/badge/Platform-iOS%2014%2B-blue.svg" alt="Platform">
  <img src="https://img.shields.io/badge/Swift-5.0-orange.svg" alt="Swift">
  <img src="https://img.shields.io/badge/License-MIT-green.svg" alt="License">
</p>

Kleen is a fast, intuitive iOS app that helps you clean up your photo gallery using a Tinder-like swipe interface. Swipe left to delete, swipe right to keep - it's that simple!

## ✨ Features

### Core Functionality
- **Tinder-Style Swipe Interface**: Swipe left to delete photos, swipe right to keep them
- **Batch Deletion**: Queue photos for deletion and delete them all at once with a single confirmation
- **Smart Trash Management**: Review queued deletions anytime before committing
- **Real-time Counter**: See how many photos you've marked for deletion

### Advanced Features
- **Persistence**: Your deletion queue is saved automatically - close the app and come back anytime
- **External Sync**: Automatically detects if you delete photos in the Apple Photos app
- **Pagination**: Loads photos in batches of 50 for instant startup, even with 50,000+ photos
- **Burst Photo Handling**: Automatically shows only one photo per burst sequence
- **Limited Access Support**: Works with both full library access and selected photos
- **Performance Optimized**: Smooth animations and instant response

### User Experience
- **Onboarding Tutorial**: First-time users get a quick 3-page guide
- **Beautiful Loading Screen**: Animated logo with gradient effects
- **Dark Mode UI**: Sleek, modern interface designed for OLED screens
- **Smooth Animations**: Spring animations and transitions throughout

## 📱 Screenshots

### Main Interface
- **Swipe View**: Tinder-style card interface with visual feedback
- **Trash Button**: Red badge showing deletion count in top-right
- **Trash View**: Grid view of all queued photos before deletion

## 🚀 Getting Started

### Prerequisites
- **Xcode 14.0+**
- **iOS 14.0+** deployment target
- **Swift 5.0+**
- **Apple Developer Account** (for device testing)

### Installation

1. **Clone or Download the Project**
   ```bash
   cd /path/to/Kleen
   ```

2. **Open in Xcode**
   - Open `Kleen.xcodeproj` in Xcode
   - Or drag the entire `Kleen` folder into Xcode to create a new project

3. **Configure Project Settings**
   - Select your Development Team in Signing & Capabilities
   - Ensure Bundle Identifier is set to `com.A2Labs.Kleen` (or your own)
   - Verify `Info.plist` contains `NSPhotoLibraryUsageDescription`

4. **Add Files to Xcode Project**
   Make sure all these files are included in your target:
   - `KleenApp.swift` (App entry point)
   - `ContentView.swift` (Main view)
   - `PhotoManager.swift` (Core logic)
   - `CardView.swift` (Swipeable card)
   - `LoadingView.swift` (Loading screen)
   - `FinishedView.swift` (Completion screen)
   - `OnboardingView.swift` (Tutorial)
   - `TrashView.swift` (Trash management)
   - `Info.plist` (Permissions)

5. **Build and Run**
   - Select your device or simulator
   - Press `Cmd + R` to build and run
   - Grant photo library access when prompted

## 📖 How to Use

### First Launch
1. **Onboarding**: You'll see a 3-page tutorial explaining how to use the app
2. **Permission**: Grant photo library access (full or limited)
3. **Loading**: The app loads your photos in batches

### Cleaning Your Gallery
1. **Swipe Right**: Keep the photo (it disappears from the deck)
2. **Swipe Left**: Mark for deletion (added to trash queue)
3. **Visual Feedback**:
   - Green "KEEP" overlay when swiping right
   - Red "DELETE" overlay when swiping left

### Managing Deletions
1. **Trash Button**: Tap the red badge in top-right to view queued deletions
2. **Review**: See thumbnails of all photos marked for deletion
3. **Delete**: Tap "Delete X Photos" to permanently delete them
4. **One Confirmation**: iOS shows a single system prompt for all deletions

### Mid-Session Deletion
- You don't need to swipe through all photos
- Mark 50 photos, delete them, continue swiping
- Perfect for large libraries (5000+ photos)

### Limited Access
- If you selected "Select Photos" instead of "Allow All Photos"
- Tap the `+` button (top-left) to add more photos to the app's access

## 🏗️ Project Structure

```
Kleen/
├── KleenApp.swift           # App entry point (@main)
├── ContentView.swift        # Main view coordinator
├── PhotoManager.swift       # Core business logic (PhotoKit)
├── CardView.swift          # Swipeable photo card
├── LoadingView.swift       # Animated loading screen
├── FinishedView.swift      # Completion/success screen
├── OnboardingView.swift    # First-time tutorial
├── TrashView.swift         # Trash management UI
└── Info.plist              # App configuration & permissions
```

## 🔧 Technical Details

### Architecture
- **SwiftUI**: Modern declarative UI framework
- **PhotoKit**: Apple's framework for photo library access
- **Combine**: Reactive state management with `@Published`
- **UserDefaults**: Persistence for trash queue and onboarding state

### Key Components

#### PhotoManager
- Manages photo library permissions and access
- Implements `PHPhotoLibraryChangeObserver` for external sync
- Handles batch deletion and persistence
- Pagination for performance

#### State Management
- `@StateObject` for PhotoManager lifecycle
- `@Published` properties for reactive UI updates
- `@State` for local view state (onboarding, trash view)

### Performance Optimizations
1. **Lazy Loading**: Photos loaded in batches of 50
2. **Thumbnail Caching**: Uses `PHImageManager` with appropriate sizes
3. **Burst Filtering**: `includeAllBurstAssets = false`
4. **Main Thread Dispatch**: All UI updates on main queue

## 🐛 Troubleshooting

### App crashes on launch
- **Check**: Info.plist contains `NSPhotoLibraryUsageDescription`
- **Solution**: Add the key with a description string

### Photos don't load
- **Check**: Permission was granted
- **Solution**: Go to Settings → Kleen → Photos → Allow Access

### Trash button doesn't work
- **Check**: Button is fully tappable (fixed in latest version)
- **Solution**: Update to latest code with `.onTapGesture` and `.zIndex(10)`

### Loading screen flashes permission view
- **Check**: Using latest PhotoManager with synchronous status check
- **Solution**: Update `init()` to check `authorizationStatus()` synchronously

### Deletion fails with error 3072
- **Meaning**: User cancelled the system deletion prompt
- **Behavior**: App shows friendly "Deletion cancelled" message and preserves queue

## 📝 Permissions

The app requires the following permission:

- **Photo Library Access** (`NSPhotoLibraryUsageDescription`)
  - Used to: Read photos, delete photos
  - When: On first launch or when accessing photos
  - Scope: Full library or selected photos (user choice)

## 🤝 Contributing

This is a personal project, but suggestions are welcome!

## 📄 License

MIT License - feel free to use this code for your own projects.

## 🙏 Acknowledgments

- Built with SwiftUI and PhotoKit
- Inspired by Tinder's swipe interface
- Created to solve the problem of cluttered photo galleries

## 📧 Contact

For questions or feedback, please open an issue on GitHub.

---

**Made with ❤️ for people with too many photos**
