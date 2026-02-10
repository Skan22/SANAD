# Second Voice (صوتك الثاني)

<div align="center">

![Second Voice Banner](https://img.shields.io/badge/SANAD-Accessibility%20Challenge-blue?style=for-the-badge)
![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

**An AI-powered accessibility solution breaking communication barriers for the deaf and hard-of-hearing community**

[Features](#-features) • [Demo](#-demo) • [Installation](#-installation) • [Architecture](#-architecture) • [Documentation](#-documentation)

</div>

---

## 📖 Overview

**Second Voice** is a production-ready mobile accessibility application that solves the critical "Text Wall" problem in traditional speech-to-text systems. By combining **real-time transcription** with **intelligent speaker diarization**, it transforms undifferentiated text streams into natural, multi-party conversations with visual speaker attribution.

### 🎯 SANAD Challenge Submission
**Category:** Accessibility, Inclusion, and Dignity - Hearing Impairment  
**Innovation:** Hybrid offline/online architecture with constraint-based speaker identification

### 🏆 Key Innovation

Unlike traditional captioning apps that present conversation as a continuous text wall, Second Voice:
- ✅ **Identifies individual speakers** using novel pause-based diarization
- ✅ **Works 100% offline** with Vosk for privacy-first operation
- ✅ **Scales to cloud** with optional Gemini Live API for enhanced accuracy
- ✅ **Provides haptic feedback** so users can "feel" conversation dynamics
- ✅ **Supports accessibility** with dynamic typography (20-40pt) and RTL languages

---

## ✨ Features

### 🎙️ Hybrid Transcription System

**Dual-Engine Architecture:**
- **Offline Mode (Vosk):** 100% on-device processing, zero network dependency
  - Latency: 50-150ms
  - Privacy: No data ever leaves device
  - Model size: 35MB (English/Arabic)
- **Online Mode (Gemini Live API):** Cloud-powered accuracy
  - Latency: 200-500ms  
  - Accuracy: 95-98% (clean audio)
  - Real-time WebSocket streaming

### 🗣️ Speaker Diarization

**Constraint-Based Cycling Algorithm:**
- Automatically detects speaker changes via silence detection
- Configurable pause threshold (1.0s - 3.0s)
- Manual correction with long-press gesture
- Visual color coding (8 distinct high-contrast colors)
- Custom speaker naming

### 🌍 Multi-Language Support

- **English (US):** Vosk model + Gemini support
- **Arabic (MSA/Tunisian):** Full RTL rendering
- Language-aware demo mode
- Seamless model switching

### 📱 Accessibility-First Design

**WCAG 2.1 Compliant:**
- Dynamic text scaling (20pt to 40pt)
- Minimum 4.5:1 contrast ratio
- Haptic feedback patterns:
  - Triple-tap: Speaker change
  - Single pulse: Recording start
  - Short pulse: Recording stop
- Responsive typography with automatic layout reflow

### 📜 Data Persistence

- **SQLite database** for conversation history
- **SharedPreferences** for user settings
- Export conversations as formatted text
- Search and filter capabilities

### 🎬 Demo Mode

- Built-in simulation engine for testing without live audio
- Language-aware conversational scripts
- Perfect for presentations and development

---

## 🛠️ Technology Stack

| Layer | Technology | Purpose |
|-------|------------|----------|
| **Frontend** | Flutter 3.x (Dart) | Cross-platform UI framework |
| **Offline STT** | Vosk (Kaldi-based) | On-device speech recognition |
| **Online STT** | Google Gemini 2.5 Flash | Cloud transcription via Live API |
| **Audio** | `record` package | PCM16 capture (16kHz, Mono) |
| **Database** | SQLite (sqflite) | Local conversation storage |
| **State** | Provider pattern | Reactive state management |
| **Persistence** | shared_preferences | Settings & preferences |
| **Networking** | web_socket_channel | WebSocket for Gemini API |
| **Platforms** | Android, iOS, Linux, macOS, Windows | Full cross-platform support |

---

## 📁 Repository Structure

```text
SANAD/
├── README.md                           # This file - Project overview
└── SecondVoice_MVP/
    ├── FINAL_TECHNICAL_REPORT.md       # Comprehensive technical whitepaper
    ├── TECHNICAL_REPORT.md             # Development documentation
    ├── README.md                       # MVP-specific documentation
    ├── mobile_app/                     # Flutter application
    │   ├── lib/
    │   │   ├── main.dart               # Application entry point
    │   │   ├── models/                 # Data models
    │   │   │   ├── conversation.dart
    │   │   │   ├── conversation_message.dart
    │   │   │   └── speaker_color.dart
    │   │   ├── screens/                # UI screens
    │   │   │   ├── conversation_screen.dart
    │   │   │   └── conversation_history_screen.dart
    │   │   ├── services/               # Business logic
    │   │   │   ├── audio_stream_service.dart
    │   │   │   ├── conversation_provider.dart
    │   │   │   ├── database_service.dart
    │   │   │   ├── gemini_live_service.dart
    │   │   │   └── vosk_service.dart
    │   │   ├── theme/                  # Accessibility-first design
    │   │   │   └── app_theme.dart
    │   │   └── widgets/                # Reusable components
    │   │       ├── message_bubble.dart
    │   │       ├── settings_drawer.dart
    │   │       └── waveform_visualizer.dart
    │   ├── assets/
    │   │   └── models/                 # Vosk AI models (35MB each)
    │   │       └── vosk-model-small-en-us-0.15/
    │   ├── android/                    # Android platform code
    │   ├── ios/                        # iOS platform code
    │   ├── linux/                      # Linux platform code
    │   ├── pubspec.yaml                # Dependencies
    │   └── test/                       # Unit tests
    └── ai_engine/                      # Python R&D prototypes
        ├── diarizer.py                 # Speaker diarization research
        ├── transcribe_demo.py          # Vosk testing
        ├── requirements.txt
        └── models/                     # Vosk model storage
```

---

## 🚀 Installation

### Prerequisites

- **Flutter SDK:** 3.x or later ([Install Flutter](https://flutter.dev/docs/get-started/install))
- **Git:** For cloning the repository
- **IDE:** Android Studio, VS Code, or IntelliJ IDEA
- **Platform Requirements:**
  - **Android:** Android Studio, SDK 21+ (Android 5.0+)
  - **iOS:** Xcode 14+, iOS 12+
  - **Linux:** CMake, GTK3 development libraries
  - **macOS:** Xcode command line tools
  - **Windows:** Visual Studio 2019 or later

### Quick Start (5 minutes)

```bash
# 1. Clone the repository
git clone https://github.com/your-username/SANAD.git
cd SANAD/SecondVoice_MVP/mobile_app

# 2. Install Flutter dependencies
flutter pub get

# 3. Run on your preferred platform
flutter run -d linux        # Linux desktop
flutter run -d android      # Android device/emulator
flutter run -d ios          # iOS device/simulator
flutter run -d macos        # macOS
flutter run -d windows      # Windows
```

### First-Time Platform Setup (One-time)

If you encounter platform-specific issues, regenerate platform files:

```bash
flutter create . --project-name second_voice --org com.sanad --platforms=linux,android,ios,macos,windows
```

### Using Gemini Live API (Optional)

1. Get an API key from [Google AI Studio](https://aistudio.google.com/app/apikey)
2. Open the app → **Settings** (⚙️) → **Gemini API Key**
3. Paste your key and toggle to **"Gemini (Online)"** engine
4. Start transcribing with cloud-powered accuracy

### Development Setup

```bash
# Run with hot reload for development
flutter run --debug

# Run tests
flutter test

# Build release APK (Android)
flutter build apk --release

# Build iOS app
flutter build ios --release

# Build Linux binary
flutter build linux --release
```

---

## 🎬 Demo

### Try Without Microphone (Demo Mode)

1. Launch the app
2. Tap **Settings** (⚙️ icon)
3. Enable **"Demo Mode (Simulation)"**
4. Tap the **Microphone button** to start
5. Watch a pre-scripted 3-speaker conversation unfold

### Live Transcription (Real Audio)

1. Ensure microphone permissions are granted
2. Disable **Demo Mode** in settings
3. Select your preferred engine:
   - **Vosk (Offline):** No internet required
   - **Gemini (Online):** Requires API key
4. Tap **Microphone** and start speaking
5. Watch text appear in real-time with speaker colors

---

## 🏗️ Architecture

### System Design

Second Voice employs a **3-tier modular architecture**:

```
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│  (Flutter Widgets + Provider)           │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│         Business Logic Layer            │
│  • ConversationProvider                 │
│  • Diarization Algorithm                │
│  • Message Management                   │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│         Data Layer                      │
│  • AudioStreamService                   │
│  • VoskService / GeminiLiveService      │
│  • DatabaseService                      │
│  • SettingsService                      │
└─────────────────────────────────────────┘
```

### Key Design Patterns

- **Provider Pattern:** Reactive state management
- **Service Locator:** Dependency injection for services
- **Strategy Pattern:** Swappable STT engines (Vosk ↔ Gemini)
- **Observer Pattern:** Audio stream broadcasting
- **Repository Pattern:** Data persistence abstraction

---

## 📚 Documentation

### Technical Documentation

- **[FINAL_TECHNICAL_REPORT.md](SecondVoice_MVP/FINAL_TECHNICAL_REPORT.md)** - Complete technical whitepaper (1600+ lines)
  - System architecture deep-dive
  - Hybrid transcription engine design
  - WebSocket protocol implementation
  - Speaker diarization algorithm
  - Performance benchmarks
  - Future roadmap

- **[TECHNICAL_REPORT.md](SecondVoice_MVP/TECHNICAL_REPORT.md)** - Development documentation
  - Implementation timeline
  - Technical challenges & solutions
  - Testing methodology

### Quick References

- **[Mobile App README](SecondVoice_MVP/mobile_app/README.md)** - Flutter-specific setup
- **[AI Engine README](SecondVoice_MVP/ai_engine/README.md)** - Python prototyping

---

## 🧪 Testing

### Automated Tests

```bash
# Run all unit tests
flutter test

# Run with coverage
flutter test --coverage

# Run integration tests
flutter test integration_test/
```

### Manual Testing Checklist

- [ ] **Offline Mode:** Airplane mode, verify Vosk transcription
- [ ] **Online Mode:** Enable Gemini, compare accuracy
- [ ] **Speaker Detection:** 2-3 person conversation, check color switching
- [ ] **Haptic Feedback:** Feel vibrations on speaker changes
- [ ] **Text Scaling:** Adjust font size, verify layout reflows
- [ ] **Conversation History:** Save, reload, delete sessions
- [ ] **Export:** Share conversation as text
- [ ] **Demo Mode:** Run simulation without microphone
- [ ] **Language Switch:** Toggle EN ↔ AR, verify RTL rendering

---

## 🤝 Contributing

We welcome contributions! Here's how to get started:

1. **Fork the repository**
2. **Create a feature branch:** `git checkout -b feature/amazing-feature`
3. **Commit your changes:** `git commit -m 'Add amazing feature'`
4. **Push to the branch:** `git push origin feature/amazing-feature`
5. **Open a Pull Request**

### Development Guidelines

- Follow [Flutter style guide](https://dart.dev/guides/language/effective-dart/style)
- Add unit tests for new features
- Update documentation for API changes
- Ensure accessibility compliance (WCAG 2.1)

---

## 📊 Performance Metrics

| Metric | Vosk (Offline) | Gemini (Online) |
|--------|----------------|------------------|
| **End-to-End Latency** | 171-221ms | 276-536ms |
| **Word Error Rate (Clean)** | 10-15% | 2-5% |
| **Word Error Rate (Noisy)** | 30-40% | 10-20% |
| **Memory Footprint** | 106-140 MB | 71-95 MB |
| **Battery (1hr)** | 8-12% drain | 5-8% + network |
| **Network Usage** | 0 KB | ~12 MB/hour |

---

## 🗺️ Roadmap

### Version 2.0 (Planned)

- [ ] **ML-based Speaker Recognition:** Voice biometrics for automatic identification
- [ ] **Real-time Translation:** Multi-language conversations
- [ ] **Whisper Integration:** On-device Whisper Tiny/Base models
- [ ] **Cloud Sync:** Optional encrypted backup
- [ ] **Multi-device Sync:** Collaborative transcription
- [ ] **Lip Reading:** Visual speech recognition fusion
- [ ] **Noise Cancellation:** Enhanced audio preprocessing

---

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgements

- **[Vosk Team](https://alphacephei.com/vosk/)** - Lightweight offline speech recognition
- **[Google AI](https://ai.google.dev/)** - Gemini Live API for cloud transcription
- **[Flutter Team](https://flutter.dev/)** - Exceptional cross-platform framework
- **SANAD Initiative** - For championing accessibility innovation
- **Deaf & Hard-of-Hearing Community** - For invaluable feedback and testing

---

## 📞 Contact

**Project Lead:** Skander  
**Organization:** SANAD Initiative  
**Email:** [your-email@domain.com]  
**Date:** February 10, 2026

---

<div align="center">

**Making conversations accessible, one transcription at a time. 💙**

[⬆ Back to Top](#second-voice-صوتك-الثاني)

</div>
