# Second Voice MVP

> **Real-time speech-to-text transcription with intelligent speaker diarization for the deaf and hard-of-hearing community.**

## 📍 Quick Links

- **[Main Project README](../README.md)** - Complete project overview
- **[Installation Guide](../INSTALLATION.md)** - Detailed setup instructions
- **[Technical Whitepaper](FINAL_TECHNICAL_REPORT.md)** - Deep technical documentation (1600+ lines)
- **[Contributing Guide](../CONTRIBUTING.md)** - How to contribute
- **[Changelog](../CHANGELOG.md)** - Version history

---

## 🎯 SANAD Challenge Submission

**Category:** Accessibility, Inclusion, and Dignity - Hearing Impairment

**Innovation:** Hybrid offline/online transcription with constraint-based speaker diarization

---

## 📁 Project Structure

```
SecondVoice_MVP/
├── FINAL_TECHNICAL_REPORT.md    # Comprehensive technical whitepaper
├── TECHNICAL_REPORT.md           # Development documentation
├── README.md                     # This file
├── mobile_app/                   # Flutter cross-platform app
│   ├── lib/
│   │   ├── main.dart             # Application entry point
│   │   ├── models/               # Data models
│   │   │   ├── conversation.dart
│   │   │   ├── conversation_message.dart
│   │   │   └── speaker_color.dart
│   │   ├── screens/              # UI screens
│   │   │   ├── conversation_screen.dart
│   │   │   └── conversation_history_screen.dart
│   │   ├── services/             # Business logic
│   │   │   ├── audio_stream_service.dart
│   │   │   ├── conversation_provider.dart
│   │   │   ├── database_service.dart
│   │   │   ├── gemini_live_service.dart
│   │   │   └── vosk_service.dart
│   │   ├── theme/                # Accessibility-first design
│   │   │   └── app_theme.dart
│   │   └── widgets/              # Reusable components
│   │       ├── message_bubble.dart
│   │       ├── settings_drawer.dart
│   │       └── waveform_visualizer.dart
│   ├── assets/
│   │   └── models/               # Vosk AI models
│   │       └── vosk-model-small-en-us-0.15/
│   ├── android/                  # Android platform code
│   ├── ios/                      # iOS platform code
│   ├── linux/                    # Linux platform code
│   ├── macos/                    # macOS platform code
│   ├── windows/                  # Windows platform code
│   ├── pubspec.yaml              # Flutter dependencies
│   └── test/                     # Unit and widget tests
└── ai_engine/                    # Python R&D prototypes
    ├── diarizer.py               # Speaker diarization research
    ├── transcribe_demo.py        # Vosk testing
    ├── requirements.txt          # Python dependencies
    └── models/                   # Vosk model storage
```

---

## 🚀 Quick Start

### Prerequisites

- Flutter SDK 3.x or later
- Git
- Platform-specific tools (see [Installation Guide](../INSTALLATION.md))

### Installation (3 steps)

```bash
# 1. Navigate to mobile app directory
cd mobile_app

# 2. Install dependencies
flutter pub get

# 3. Run the app
flutter run -d linux        # Linux desktop
flutter run -d android      # Android device/emulator
flutter run -d ios          # iOS device/simulator
flutter run -d macos        # macOS
flutter run -d windows      # Windows
```

### First-Time Setup (One-time)

If platform files are missing:

```bash
flutter create . --project-name second_voice --org com.sanad --platforms=linux,android,ios,macos,windows
```

---

## 🎬 Demo Mode

Perfect for testing without microphone access:

1. Launch the app
2. Open **Settings** (⚙️ icon)
3. Enable **"Demo Mode (Simulation)"**
4. Tap the **Microphone button**
5. Watch a pre-scripted conversation unfold

---

## 🛠️ Development

### Running Tests

```bash
# Unit tests
flutter test

# With coverage
flutter test --coverage

# Integration tests
flutter test integration_test/
```

### Building for Production

```bash
# Android APK
flutter build apk --release

# iOS IPA (requires macOS)
flutter build ipa --release

# Linux binary
flutter build linux --release

# macOS app
flutter build macos --release

# Windows executable
flutter build windows --release
```

### Code Quality

```bash
# Format code
flutter format .

# Analyze for issues
flutter analyze

# Run all checks
flutter format . && flutter analyze && flutter test
```

---

## 📊 Key Features

### Dual-Engine Architecture
- **Offline (Vosk):** 50-150ms latency, 100% privacy
- **Online (Gemini):** 200-500ms latency, 95-98% accuracy

### Speaker Diarization
- Automatic speaker detection via pause analysis
- Visual color coding (8 high-contrast colors)
- Manual correction with long-press
- Custom speaker naming

### Accessibility
- WCAG 2.1 compliant
- Dynamic text scaling (20-40pt)
- Haptic feedback patterns
- RTL language support

### Data Persistence
- SQLite database for conversations
- Export as formatted text
- Search and filter history

---

## 🌐 Supported Languages

- **English (US):** Vosk + Gemini
- **Arabic (MSA/Tunisian):** Vosk + Gemini
- Full RTL rendering for Arabic

---

## 📚 Documentation

### For Users
- **[Main README](../README.md)** - Project overview and features
- **[Installation Guide](../INSTALLATION.md)** - Platform-specific setup

### For Developers
- **[FINAL_TECHNICAL_REPORT.md](FINAL_TECHNICAL_REPORT.md)** - Complete technical analysis
  - Architecture deep-dive
  - Algorithm documentation
  - Performance benchmarks
  - API integration guides
- **[TECHNICAL_REPORT.md](TECHNICAL_REPORT.md)** - Development timeline
- **[Contributing Guide](../CONTRIBUTING.md)** - Development workflow

### Research
- **[AI Engine Documentation](ai_engine/README.md)** - Python prototypes and research

---

## 🧪 Testing Checklist

Manual testing before submission:

- [ ] Demo mode runs without errors
- [ ] Microphone permission requested correctly
- [ ] Vosk transcription works offline
- [ ] Gemini transcription works online
- [ ] Speaker colors change on pauses
- [ ] Haptic feedback triggers on speaker change
- [ ] Text scaling adjusts UI properly
- [ ] Conversations save to database
- [ ] History screen loads conversations
- [ ] Export functionality works
- [ ] Language switching (EN ↔ AR)
- [ ] Settings persist after app restart

---

## 📞 Support

**Issues?** Check:
1. [Installation Guide](../INSTALLATION.md) - Troubleshooting section
2. [GitHub Issues](https://github.com/your-username/SANAD/issues) - Known problems
3. [Flutter Doctor](https://flutter.dev/docs/get-started/install) - `flutter doctor -v`

---

## 🤝 Contributing

We welcome contributions! See [CONTRIBUTING.md](../CONTRIBUTING.md) for:
- Code style guidelines
- Testing requirements
- Pull request process
- Accessibility standards

---

## 📜 License

MIT License - see [LICENSE](../LICENSE)

---

## 🙏 Acknowledgements

- **[Vosk Team](https://alphacephei.com/vosk/)** - Offline speech recognition
- **[Google AI](https://ai.google.dev/)** - Gemini Live API
- **[Flutter Team](https://flutter.dev/)** - Cross-platform framework
- **SANAD Initiative** - Accessibility advocacy
- **Deaf & Hard-of-Hearing Community** - Invaluable feedback

---

<div align="center">

**Making conversations accessible, one transcription at a time. 💙**

[📖 Main Documentation](../README.md) • [🚀 Installation](../INSTALLATION.md) • [🔧 Technical Report](FINAL_TECHNICAL_REPORT.md)

</div>

python transcribe_demo.py --demo
```

## ✨ Features

- **Offline-First**: Runs entirely on-device using Vosk
- **Speaker Diarization**: Color-coded speaker identification
- **High Accessibility**: Dark mode, adjustable text, haptic feedback
- **Privacy**: No data leaves the device

## 📋 Requirements

- Flutter 3.x
- Python 3.8+
- Vosk model: `vosk-model-small-en-us-0.15` (download from [Vosk Models](https://alphacephei.com/vosk/models))

## 📱 Vosk Model Setup

1. Download the model: `vosk-model-small-en-us-0.15`
2. Extract to: `mobile_app/assets/models/vosk-model-small-en-us-0.15/`
