# Quick Start Guide for Evaluators

> **Get Second Voice running in under 5 minutes!**

This guide is designed for judges, reviewers, and evaluators who want to quickly test Second Voice without deep technical setup.

---

## ⚡ Option 1: Demo Mode (No Microphone Required)

**Perfect for:** Initial evaluation, presentations, testing without audio hardware

**Time Required:** 2 minutes

### Steps

1. **Install Flutter** (if not already installed):
   ```bash
   # macOS/Linux
   git clone https://github.com/flutter/flutter.git -b stable
   export PATH="$PATH:`pwd`/flutter/bin"
   
   # Windows
   # Download from: https://flutter.dev/docs/get-started/install/windows
   ```

2. **Clone and run:**
   ```bash
   git clone https://github.com/your-username/SANAD.git
   cd SANAD/SecondVoice_MVP/mobile_app
   flutter pub get
   flutter run -d linux  # Or: android, macos, windows
   ```

3. **Enable Demo Mode:**
   - Click **Settings** (⚙️ icon in top-right)
   - Toggle **"Demo Mode (Simulation)"** to ON
   - Close settings

4. **Start Demo:**
   - Click the **Microphone button** (bottom-center)
   - Watch a pre-scripted 3-speaker conversation unfold
   - Observe:
     - Text appearing in real-time
     - Speaker colors changing (Blue, Green, Red)
     - Haptic feedback (if on mobile)
     - Latency counter (ms)

### What to Look For

- ✅ **Speaker Attribution:** Each message has a speaker name and color
- ✅ **Real-time Updates:** Text appears word-by-word
- ✅ **UI Responsiveness:** Smooth animations, no lag
- ✅ **Accessibility:** Large, readable text with high contrast

---

## 🎤 Option 2: Live Transcription (Microphone Required)

**Perfect for:** Full feature evaluation, accuracy testing

**Time Required:** 5 minutes

### Steps

1. **Complete Option 1 steps 1-2** (clone and run)

2. **Disable Demo Mode:**
   - Settings → Turn OFF "Demo Mode"

3. **Grant Microphone Permission:**
   - App will request permission on first use
   - Accept the permission prompt

4. **Start Transcription:**
   - Click **Microphone button**
   - Speak clearly: "Hello, my name is [Your Name]"
   - Watch your speech transcribed in real-time

5. **Test Speaker Diarization:**
   - Pause for 2 seconds
   - Speak again
   - Notice the speaker color changes (Blue → Green)

### What to Look For

- ✅ **Latency:** Text appears within 0.5 seconds
- ✅ **Accuracy:** Words correctly transcribed (85-90% offline)
- ✅ **Speaker Changes:** Color switches after pauses
- ✅ **Haptic Feedback:** Vibration on speaker change (mobile)

---

## 🌐 Option 3: Cloud Mode (Best Accuracy)

**Perfect for:** Accuracy comparison, feature showcase

**Time Required:** 7 minutes (includes API key setup)

### Steps

1. **Get Gemini API Key:**
   - Visit: https://aistudio.google.com/app/apikey
   - Sign in with Google account
   - Click "Create API Key"
   - Copy the key

2. **Complete Option 2 steps 1-4** (live transcription)

3. **Configure Gemini:**
   - Settings → **"Gemini API Key"** field
   - Paste your API key
   - Select **"Gemini (Online)"** from engine dropdown
   - Close settings

4. **Test Cloud Transcription:**
   - Click Microphone button
   - Speak naturally
   - Compare accuracy to offline mode

### What to Look For

- ✅ **Higher Accuracy:** 95-98% vs 85-90% (offline)
- ✅ **Context Awareness:** Better handling of homophones
- ✅ **Latency:** Still under 1 second
- ✅ **Connection Status:** Green indicator = connected

---

## 📱 Platform-Specific Quick Start

### Android

```bash
# Ensure device is connected
adb devices

# Run
flutter run -d android

# Or install pre-built APK
adb install second-voice.apk
```

### iOS (Requires macOS)

```bash
# Run on simulator
flutter run -d ios

# Or physical device
flutter run -d [device-id]
```

### Linux Desktop

```bash
flutter run -d linux
```

### macOS Desktop

```bash
flutter run -d macos
```

### Windows Desktop

```bash
flutter run -d windows
```

---

## 🧪 Evaluation Checklist

### Core Functionality (5 minutes)

- [ ] **Launch:** App starts without errors
- [ ] **Demo Mode:** Simulated conversation runs
- [ ] **Live Mode:** Microphone captures audio
- [ ] **Transcription:** Speech converted to text
- [ ] **Diarization:** Speaker colors change
- [ ] **Persistence:** Conversation saves automatically

### Accessibility (3 minutes)

- [ ] **Text Size:** Adjust slider (Settings) → Text scales
- [ ] **Contrast:** Readable in bright light
- [ ] **Haptics:** Feel vibration on speaker change (mobile)
- [ ] **RTL:** Switch to Arabic → UI flips direction

### Advanced Features (2 minutes)

- [ ] **History:** View saved conversations
- [ ] **Export:** Share conversation as text
- [ ] **Settings:** All options functional
- [ ] **Performance:** Latency under 1 second

---

## 📊 Expected Performance

| Feature | Expected Result | Tolerance |
|---------|----------------|-----------|
| **Latency (Offline)** | 171-221ms | ±50ms |
| **Latency (Online)** | 276-536ms | ±100ms |
| **Accuracy (Clean)** | 85-90% (Vosk) | ±5% |
| **Accuracy (Clean)** | 95-98% (Gemini) | ±3% |
| **Memory Usage** | 106-140 MB | ±20 MB |
| **Startup Time** | <3 seconds | ±1s |

---

## 🐛 Troubleshooting

### "No devices found"

```bash
# Check available devices
flutter devices

# Start emulator (Android)
flutter emulators --launch Pixel_6_API_33

# Or use desktop
flutter run -d linux
```

### "Microphone permission denied"

- **Android:** Settings → Apps → Second Voice → Permissions → Microphone
- **Linux:** Check PulseAudio/PipeWire permissions
- **macOS:** System Preferences → Security & Privacy → Microphone

### "Vosk model not found"

Models should be in `mobile_app/assets/models/`. If missing:

```bash
cd mobile_app/assets/models
wget https://alphacephei.com/vosk/models/vosk-model-small-en-us-0.15.zip
unzip vosk-model-small-en-us-0.15.zip
```

### "Build failed"

```bash
flutter clean
flutter pub get
flutter run
```

---

## 📹 Video Demo

**Prefer watching?** Check out our demo video:
- **YouTube:** [Link to demo video]
- **Duration:** 3 minutes
- **Covers:** All core features + accessibility showcase

---

## 📚 Additional Documentation

For deeper evaluation:

- **[README.md](README.md)** - Project overview
- **[INSTALLATION.md](INSTALLATION.md)** - Detailed setup
- **[FINAL_TECHNICAL_REPORT.md](SecondVoice_MVP/FINAL_TECHNICAL_REPORT.md)** - Technical deep-dive
- **[SUBMISSION.md](SUBMISSION.md)** - Complete submission document

---

## 💬 Questions?

**Common Questions:**

**Q: Can I use it without internet?**  
A: Yes! Vosk mode is 100% offline.

**Q: How accurate is the speaker detection?**  
A: 70-85% automatic accuracy, with manual correction available.

**Q: What languages are supported?**  
A: English (US) and Arabic (MSA/Tunisian) currently.

**Q: Is my audio data private?**  
A: In Vosk mode, absolutely—nothing leaves your device. In Gemini mode, audio is processed by Google's API.

**Q: Can I export conversations?**  
A: Yes, as formatted text files.

---

## ⭐ Evaluation Criteria

When evaluating Second Voice, consider:

1. **Innovation:** Novel speaker diarization without voice biometrics
2. **Technical Excellence:** Hybrid architecture, WebSocket implementation
3. **Accessibility:** WCAG 2.1 AA compliance, multi-sensory feedback
4. **Usability:** Intuitive UI, demo mode, clear documentation
5. **Impact:** Addresses real need in deaf/HoH community
6. **Scalability:** Cross-platform, extensible architecture
7. **Documentation:** Comprehensive technical and user docs

---

## 🙏 Thank You!

Thank you for taking the time to evaluate Second Voice. We hope this tool demonstrates our commitment to building accessible technology that empowers the deaf and hard-of-hearing community.

**For questions or issues during evaluation:**
- Open a GitHub issue
- Email: [your-email@domain.com]
- Check troubleshooting section above

---

<div align="center">

**Happy testing! 🎙️💙**

[⬆ Back to Top](#quick-start-guide-for-evaluators)

</div>
