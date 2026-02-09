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

### Mobile App (Flutter)
```bash
cd mobile_app
flutter pub get
flutter run
```

### AI Engine (Python - for testing)
```bash
cd ai_engine
pip install -r requirements.txt
python transcribe_demo.py sample.wav
```

## ✨ Features

- **Offline-First**: Runs entirely on-device using Vosk
- **Speaker Diarization**: Color-coded speaker identification
- **High Accessibility**: Dark mode, adjustable text, haptic feedback
- **Privacy**: No data leaves the device

## 📋 Requirements

- Flutter 3.x
- Python 3.8+
- Vosk model: `vosk-model-small-en-us-0.15`
