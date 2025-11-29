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
- **Restore from Trash**: Tap any photo in trash to restore it back to your review queue
- **Real-time Counter**: See how many photos you've marked for deletion
- **Progress Tracking**: Live progress bar showing how many photos you've reviewed and how many remain
- **Infinite Scroll**: Automatically loads more photos as you swipe - never see an "All Clean" screen until you're truly done

### Advanced Features
- **Smart Persistence**:
  - Your deletion queue is saved automatically
  - Photos you've kept are remembered - you'll never see them again
  - Close the app and come back anytime without losing progress
- **External Sync**: Automatically detects if you delete photos in the Apple Photos app
- **Pagination**: Loads photos in batches of 50 for instant startup, even with 50,000+ photos
- **Burst Photo Handling**: Automatically shows only one photo per burst sequence
- **Limited Access Support**: Works with both full library access and selected photos
- **Performance Optimized**: Smooth animations and instant response

### User Experience
- **Branded Splash Screen**: Beautiful "Kleen" splash screen on every app launch
- **Onboarding Tutorial**: First-time users get a quick 3-page guide
- **Modern UI Design**:
  - Clean header with "Kleen" branding
  - Premium card design with subtle borders and shadows
  - Gradient progress bar with smooth animations
- **Photo Details**: Tap the info icon to see full metadata (date, resolution, location, file size)
- **Dark Mode UI**: Sleek, modern interface designed for OLED screens
- **Smooth Animations**: Spring animations and transitions throughout

## 📱 Screenshots

### Main Interface
- **Splash Screen**: Minimalist "Kleen" branding on app launch
- **Swipe View**: Tinder-style card interface with visual feedback and metadata overlay
- **Progress Bar**: Bottom bar showing review progress with percentage and counts
- **Trash Button**: Capsule badge showing deletion count in top-right
- **Trash View**: Grid view of all queued photos with tap-to-restore functionality
- **Photo Details**: Full metadata sheet with location map, file size, and technical info

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
   - `LoadingView.swift` (Splash screen)
   - `FinishedView.swift` (Completion screen)
   - `OnboardingView.swift` (Tutorial)
   - `TrashView.swift` (Trash management)
   - `PhotoDetailView.swift` (Photo metadata details)
   - `ProgressBar.swift` (Progress tracking UI)
   - `Info.plist` (Permissions)

5. **Build and Run**
   - Select your device or simulator
   - Press `Cmd + R` to build and run
   - Grant photo library access when prompted

## 📖 How to Use

### First Launch
1. **Splash Screen**: See the branded "Kleen" splash screen (2 seconds)
2. **Onboarding**: You'll see a 3-page tutorial explaining how to use the app
3. **Permission**: Grant photo library access (full or limited)
4. **Loading**: The app loads your photos in batches

### Cleaning Your Gallery
1. **Swipe Right**: Keep the photo (it disappears from the deck and won't show again)
2. **Swipe Left**: Mark for deletion (added to trash queue)
3. **Visual Feedback**:
   - Green "KEEP" overlay when swiping right
   - Red "DELETE" overlay when swiping left
4. **Photo Info**: Tap the info icon (bottom-right) to view detailed metadata
5. **Progress Tracking**: Watch the progress bar at the bottom to see your completion percentage

### Managing Deletions
1. **Trash Button**: Tap the capsule badge in top-right to view queued deletions
2. **Review**: See thumbnails of all photos marked for deletion
3. **Restore**: Tap any photo to restore it back to your review queue
4. **Delete**: Tap "Delete X Photos" to permanently delete them
5. **One Confirmation**: iOS shows a single system prompt for all deletions

### Infinite Scrolling
- The app automatically loads more photos as you swipe
- No need to manually "load more" - it happens seamlessly
- You'll only see "All Clean" when you've truly reviewed everything

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
