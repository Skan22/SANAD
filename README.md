# Second Voice (صوتك الثاني)

**Second Voice** is an offline-first, accessibility-focused real-time transcription and speaker diarization tool. It is designed to empower the deaf and hard-of-hearing community by providing a clear, color-coded, and high-contrast dialogue interface that identifies different speakers in a conversation.

## 🎯 Hackathon Challenge: SANAD
**Category:** Accessibility, Inclusion, and Dignity - Hearing Impairment

---

## ✨ Key Features

### 🎙️ Real-time Transcription & Diarization
- **Offline Recognition:** Powered by **Vosk**, ensuring 100% privacy as no audio ever leaves the device.
- **Speaker Identification:** Automatically detects speaker changes based on natural pauses (Diarization).
- **Color-Coding:** Assigns unique, high-contrast colors to each participant for easy visual tracking.

### 🌍 Multi-Language Support (EN/AR)
- **Seamless Switching:** Toggle between **English (US)** and **Arabic (Modern Standard/Tunisian)** models in real-time.
- **RTL Support:** Full Right-to-Left (RTL) support for the Arabic interface and transcription.

### 📜 Conversation History
- **Local Persistence:** Uses **SQLite (sqflite)** to securely store all past transcriptions.
- **History Management:** View, reload, or delete previous sessions directly from the app.
- **Exporting:** Export any conversation as formatted text for sharing or clinical documentation.

### ⚙️ Advanced User Controls
- **Adjustable Text Size:** Dynamic font scaling (20pt to 40pt) for maximum readability.
- **Haptic Feedback:** Vibrates on speaker changes to provide tactile cues.
- **Diarization Sensitivity:** Custom slider to adjust how quickly the AI detects a change in speaker.
- **Performance Telemetry:** Floating latency overlay (ms) to monitor real-time processing speed.

### 🚀 Hackathon Demo Mode
- **Simulation Engine:** Built-in "Demo Mode" for desktop and mobile to showcase the full conversational experience without needing a live microphone or specific acoustic environment.
- **Language-Aware Scripts:** Intelligent demo scripts that switch between English and Arabic based on the selected model.

---

## 🛠️ Tech Stack

- **Framework:** [Flutter](https://flutter.dev/) (3.x)
- **AI Core:** [Vosk Flutter Plugin](https://pub.dev/packages/vosk_flutter)
- **Database:** [sqflite](https://pub.dev/packages/sqflite)
- **State Management:** [Provider](https://pub.dev/packages/provider)
- **Persistence:** [shared_preferences](https://pub.dev/packages/shared_preferences)
- **Platform:** Android / Linux / macOS / Windows / iOS

---

## 📁 Project Structure

```text
SecondVoice_MVP/
├── mobile_app/                 # Main Flutter Application
│   ├── lib/
│   │   ├── models/             # Data models (Message, SpeakerColor)
│   │   ├── screens/            # UI Layouts (Conversation, History)
│   │   ├── services/           # Logic (Audio, Database, Haptics)
│   │   ├── theme/              # Accessibility-first Styling
│   │   └── widgets/            # Reusable UI components
│   └── assets/
│       └── models/             # Vosk AI Models (EN/AR)
└── ai_engine/                  # Original Python Prototyping & AI Research
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (latest stable)
- Android Studio / VS Code
- A physical Android device (recommended for microphone testing)

### Installation
1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-repo/SANAD.git
   cd SANAD/SecondVoice_MVP/mobile_app
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the app:**
   ```bash
   flutter run
   ```

### 🧪 Running the Demo
1. Open **Settings** (Gear icon in top right).
2. Toggle **Demo Mode (Simulation)**.
3. Tap the **Microphone** button to start the pre-scripted conversation.

---

## 🤝 Acknowledgements
Special thanks to the **Vosk** team for providing lightweight, offline speech recognition that makes accessibility tools like "Second Voice" possible for everyone, everywhere.
