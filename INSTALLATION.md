# Installation Guide

This guide provides detailed instructions for installing and setting up Second Voice on various platforms.

## Table of Contents

- [System Requirements](#system-requirements)
- [Quick Start (5 minutes)](#quick-start-5-minutes)
- [Platform-Specific Setup](#platform-specific-setup)
  - [Android](#android)
  - [iOS](#ios)
  - [Linux](#linux)
  - [macOS](#macos)
  - [Windows](#windows)
- [Gemini API Setup](#gemini-api-setup)
- [Troubleshooting](#troubleshooting)

## System Requirements

### Minimum Requirements

- **RAM:** 4 GB
- **Storage:** 500 MB free space
- **OS Versions:**
  - Android 5.0+ (API 21+)
  - iOS 12.0+
  - Linux (any recent distribution)
  - macOS 10.14+
  - Windows 10+

### Recommended Requirements

- **RAM:** 8 GB
- **Storage:** 1 GB free space
- **Microphone:** Built-in or external (required for live transcription)
- **Internet:** Optional (for Gemini mode only)

### Development Requirements

- **Flutter SDK:** 3.x or later
- **Dart SDK:** Included with Flutter
- **Git:** Latest version
- **IDE:** VS Code, Android Studio, or IntelliJ IDEA

## Quick Start (5 minutes)

```bash
# 1. Clone the repository
git clone https://github.com/your-username/SANAD.git

# 2. Navigate to mobile app directory
cd SANAD/SecondVoice_MVP/mobile_app

# 3. Install dependencies
flutter pub get

# 4. Run on your preferred platform
flutter run -d linux        # Linux
flutter run -d android      # Android
flutter run -d ios          # iOS
flutter run -d macos        # macOS
flutter run -d windows      # Windows
```

## Platform-Specific Setup

### Android

#### Prerequisites

1. **Install Android Studio:** [Download here](https://developer.android.com/studio)
2. **Install Android SDK:**
   - Open Android Studio → SDK Manager
   - Install Android SDK Platform 33 (or latest)
   - Install Android SDK Build-Tools
   - Install Android Emulator (optional)

3. **Enable Developer Options on your device:**
   - Go to Settings → About Phone
   - Tap "Build Number" 7 times
   - Go back to Settings → Developer Options
   - Enable "USB Debugging"

#### Build and Run

```bash
# Connect your Android device via USB or start emulator
adb devices  # Verify device is connected

# Run in debug mode
flutter run -d android

# Build release APK
flutter build apk --release

# Built APK location: build/app/outputs/flutter-apk/app-release.apk
```

#### Installing APK on Device

```bash
# Install via ADB
adb install build/app/outputs/flutter-apk/app-release.apk

# Or transfer APK to device and install manually
```

#### Permissions

The app requires the following permissions:
- **RECORD_AUDIO:** For microphone access
- **VIBRATE:** For haptic feedback
- **INTERNET:** For Gemini mode only (optional)

All permissions are requested at runtime.

### iOS

#### Prerequisites

1. **macOS Required:** iOS development requires a Mac
2. **Install Xcode:** [Download from App Store](https://apps.apple.com/us/app/xcode/id497799835)
3. **Install Xcode Command Line Tools:**
   ```bash
   sudo xcode-select --install
   ```
4. **Install CocoaPods:**
   ```bash
   sudo gem install cocoapods
   ```

#### Setup

```bash
cd SecondVoice_MVP/mobile_app

# Install iOS dependencies
cd ios
pod install
cd ..

# Open Xcode to configure signing
open ios/Runner.xcworkspace
```

#### Configure Code Signing

1. In Xcode, select the "Runner" project
2. Go to "Signing & Capabilities"
3. Select your team under "Team"
4. Ensure "Automatically manage signing" is checked

#### Build and Run

```bash
# Run on iOS simulator
flutter run -d ios

# Run on physical device
flutter run -d [device-id]

# Build release IPA (requires Apple Developer account)
flutter build ipa --release
```

### Linux

#### Prerequisites

```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev

# Fedora
sudo dnf install clang cmake ninja-build gtk3-devel xz-devel

# Arch
sudo pacman -S clang cmake ninja gtk3 xz
```

#### Build and Run

```bash
cd SecondVoice_MVP/mobile_app

# Run in debug mode
flutter run -d linux

# Build release binary
flutter build linux --release

# Built binary location: build/linux/x64/release/bundle/
```

#### Running the Built Binary

```bash
cd build/linux/x64/release/bundle/
./second_voice
```

### macOS

#### Prerequisites

1. **Install Xcode:** Required even for macOS development
2. **Enable macOS development:**
   ```bash
   sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
   sudo xcodebuild -runFirstLaunch
   ```

#### Build and Run

```bash
cd SecondVoice_MVP/mobile_app

# Run in debug mode
flutter run -d macos

# Build release app
flutter build macos --release

# Built app location: build/macos/Build/Products/Release/second_voice.app
```

#### Installation

Double-click `second_voice.app` to install, or:

```bash
cp -r build/macos/Build/Products/Release/second_voice.app /Applications/
```

### Windows

#### Prerequisites

1. **Install Visual Studio 2019 or later:** [Download here](https://visualstudio.microsoft.com/)
   - During installation, select "Desktop development with C++"
   - Include "C++ CMake tools for Windows"

2. **Verify installation:**
   ```powershell
   flutter doctor -v
   ```

#### Build and Run

```powershell
cd SecondVoice_MVP\mobile_app

# Run in debug mode
flutter run -d windows

# Build release executable
flutter build windows --release

# Built executable location: build\windows\runner\Release\second_voice.exe
```

#### Installation

1. Navigate to `build\windows\runner\Release\`
2. Copy the entire folder to desired location (e.g., `C:\Program Files\SecondVoice\`)
3. Create a desktop shortcut to `second_voice.exe`

## Gemini API Setup

To use the online Gemini mode for enhanced transcription:

### 1. Get API Key

1. Visit [Google AI Studio](https://aistudio.google.com/app/apikey)
2. Sign in with your Google account
3. Click "Create API Key"
4. Copy the generated key

### 2. Configure in App

1. Launch Second Voice
2. Tap **Settings** (⚙️ icon)
3. Scroll to **"Gemini API Key"**
4. Paste your API key
5. Toggle to **"Gemini (Online)"** engine
6. Start transcribing!

### 3. Verify Connection

Watch the status indicator:
- 🟢 **Green:** Connected
- 🔴 **Red:** Connection error
- 🟡 **Yellow:** Connecting

### API Costs

- Gemini 2.5 Flash is free for moderate usage
- Check current pricing: [Google AI Pricing](https://ai.google.dev/pricing)
- Estimated usage: ~5 tokens/second of audio

## Troubleshooting

### Common Issues

#### "Flutter command not found"

**Solution:** Add Flutter to your PATH:

```bash
# Linux/macOS
export PATH="$PATH:`pwd`/flutter/bin"

# Windows (PowerShell)
$env:Path += ";C:\path\to\flutter\bin"
```

#### "Unable to locate Android SDK"

**Solution:**

```bash
flutter config --android-sdk /path/to/android/sdk
```

#### "No devices found"

**Solution:**

```bash
# Check connected devices
flutter devices

# For Android
adb devices

# For iOS
idevice_id -l

# Start an emulator
flutter emulators --launch <emulator-id>
```

#### "Vosk model not found"

**Solution:**

Vosk models should be included in `mobile_app/assets/models/`. If missing:

1. Download from [Vosk Models](https://alphacephei.com/vosk/models)
2. Extract to `mobile_app/assets/models/vosk-model-small-en-us-0.15/`
3. Run `flutter pub get` again

#### "Build failed: Execution failed for task ':app:mergeDebugResources'"

**Solution:**

```bash
# Clean build cache
flutter clean
flutter pub get
flutter run
```

#### "Gemini API connection failed"

**Solution:**

1. Verify API key is correct
2. Check internet connection
3. Ensure firewall isn't blocking WebSocket connections
4. Try fallback to Vosk mode

#### "Permission denied: Microphone"

**Solution:**

- **Android:** Settings → Apps → Second Voice → Permissions → Microphone → Allow
- **iOS:** Settings → Second Voice → Microphone → Enable
- **Linux:** Check `pulseaudio` or `pipewire` permissions
- **macOS:** System Preferences → Security & Privacy → Microphone → Enable for Second Voice
- **Windows:** Settings → Privacy → Microphone → Allow apps to access

### Getting Help

If you encounter issues not covered here:

1. Check [GitHub Issues](https://github.com/your-username/SANAD/issues)
2. Run `flutter doctor -v` and share output
3. Open a new issue with:
   - Platform and version
   - Flutter version (`flutter --version`)
   - Error logs
   - Steps to reproduce

### Logs

To get detailed logs:

```bash
# Run with verbose logging
flutter run -v

# Android logs
adb logcat

# iOS logs (macOS only)
idevicesyslog
```

---

## Next Steps

After installation:

1. ✅ **Try Demo Mode:** Test without microphone
2. ✅ **Configure Settings:** Adjust font size, number of speakers
3. ✅ **Test Live Mode:** Start a conversation
4. ✅ **Explore History:** Save and review conversations
5. ✅ **Read Documentation:** Check [FINAL_TECHNICAL_REPORT.md](SecondVoice_MVP/FINAL_TECHNICAL_REPORT.md)

---

**Need more help?** See [CONTRIBUTING.md](CONTRIBUTING.md) or open an issue on GitHub.

Happy transcribing! 🎙️💙
