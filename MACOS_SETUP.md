# 🖥️ Running Monetia on macOS

Monetia is now compatible with macOS through **Mac Catalyst**! Follow these steps to build and run the app on your Mac.

## ✅ Prerequisites

- macOS 12.0 (Monterey) or later
- Xcode 14.0 or later
- An Apple Silicon or Intel Mac

## 🚀 How to Enable macOS Support

### Option 1: Mac Catalyst (Recommended for Macs with Apple Silicon)

1. **Open the project in Xcode**
   ```bash
   open Monetia.xcodeproj
   ```

2. **Select the Monetia target**
   - Click on "Monetia" in the project navigator (left sidebar)
   - Make sure you're viewing the "Monetia" target (not the project)

3. **Enable Mac support**
   - Go to the **"General"** tab
   - Scroll down to **"Supported Destinations"**
   - Check the box for **"Mac (Designed for iPad)"** or **"Mac Catalyst"**

4. **Configure minimum macOS version** (if needed)
   - In "Supported Destinations", set macOS deployment target to 12.0 or later

5. **Select "My Mac" as the run destination**
   - At the top of Xcode, next to the scheme selector, choose **"My Mac"**

6. **Build and Run**
   - Press `Cmd + R` or click the Play button
   - The app will launch as a native Mac application!

### Option 2: Mac (Designed for iPad)

If Mac Catalyst isn't available, you can use "Mac (Designed for iPad)" which runs the iPad version on macOS:

1. Follow steps 1-2 from Option 1
2. In "Supported Destinations", check **"Mac (Designed for iPad)"**
3. Continue with steps 5-6

## 📐 Window Size and Layout

The app will automatically adapt to macOS:
- **Default window size**: 800x600 pixels (adjustable)
- **Minimum window size**: 600x400 pixels
- **Layout**: iPad-optimized interface that scales beautifully on Mac
- **Navigation**: Full tab bar navigation (Home, Transactions, Budget, Goals, Settings)

### To customize window size:

Add this to your `MonetiaApp.swift` (inside `WindowGroup`):

```swift
WindowGroup {
    ContentView()
        .environmentObject(dataManager)
        // ... other modifiers
}
.defaultSize(width: 1000, height: 700) // macOS only
.windowResizability(.contentSize)      // Allow window resizing
```

## 🎨 macOS-Specific Features

The app automatically adapts for macOS:

✅ **Haptic feedback** - Disabled on macOS (no haptic engine)
✅ **File pickers** - Native macOS file dialog for backup/restore
✅ **Share sheet** - macOS share dialog for exports
✅ **Keyboard shortcuts** - Standard Cmd+N, Cmd+S, etc. (can be added)
✅ **Toolbar** - macOS-style toolbar (can be customized)
✅ **Menu bar** - App menu with preferences (automatic)

## 🔧 Build Configuration

If you encounter build issues:

1. **Clean Build Folder**
   - In Xcode: `Product` → `Clean Build Folder` (Shift+Cmd+K)

2. **Reset Package Caches**
   - `File` → `Packages` → `Reset Package Caches`

3. **Update Build Settings**
   - Target → Build Settings → Search for "Mac Catalyst"
   - Ensure "Supports Mac Catalyst" is set to "Yes"

## 🐛 Known Limitations on macOS

- **No Haptic Feedback**: Macs don't have haptic engines (already handled in code)
- **Touch Interactions**: Some gestures may feel different with mouse/trackpad
- **Keyboard Navigation**: Not all keyboard shortcuts are implemented yet

## 💡 Tips for macOS

- **Resize the window** to your preferred size
- **Use keyboard shortcuts**: Cmd+W to close, Cmd+Q to quit
- **Full screen**: Click the green maximize button or press Ctrl+Cmd+F
- **Mission Control**: Swipe up with 3 fingers to see all Monetia windows
- **Split View**: Drag Monetia to the side of the screen to use with other apps

## 📦 Building for Distribution (macOS)

To create a distributable macOS app:

```bash
xcodebuild archive \
  -project Monetia.xcodeproj \
  -scheme Monetia \
  -destination 'platform=macOS,variant=Mac Catalyst' \
  -archivePath ~/Desktop/build/Monetia-macOS.xcarchive

xcodebuild -exportArchive \
  -archivePath ~/Desktop/build/Monetia-macOS.xcarchive \
  -exportPath ~/Desktop/build/ \
  -exportOptionsPlist ExportOptions.plist
```

The app will be saved in `~/Desktop/build/Monetia.app`

## 🎉 Enjoy Monetia on macOS!

Your expense tracking app now works seamlessly across iPhone, iPad, and Mac with a single codebase!

---

**Need help?** Open an issue on GitHub or check the main README.md for more information.
