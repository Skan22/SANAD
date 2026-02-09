# Second Voice MVP

An offline-first, accessibility-focused real-time transcription and speaker diarization tool for deaf/hard-of-hearing users.

## 🎯 SANAD Challenge Submission
**Category:** Accessibility, Inclusion, and Dignity - Hearing Impairment

## 📁 Project Structure

```
SecondVoice_MVP/
├── mobile_app/          # Flutter cross-platform app
│   └── lib/
│       ├── screens/     # UI screens
│       ├── widgets/     # Reusable components
│       ├── services/    # Audio & AI services
│       └── models/      # Data models
└── ai_engine/           # Python prototyping
    ├── models/          # Vosk model files
    └── *.py             # Transcription & diarization
```

## 🚀 Quick Start

### First-Time Setup (Required)

The Flutter project needs platform files generated. Run this **once**:

```bash
cd mobile_app
flutter create . --project-name second_voice --org com.sanad --platforms=linux,android,ios
```

### Then Run the App

```bash
# Linux Desktop
flutter run -d linux

# Android (with device connected)
flutter run -d android

# Get dependencies first
flutter pub get
```

### AI Engine (Python - for testing)
```bash
cd ai_engine
pip install -r requirements.txt
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
