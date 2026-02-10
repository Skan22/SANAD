# Second Voice - Mobile Application (Flutter)

This directory contains the source code for the Second Voice mobile application, built with Flutter.

## 📁 Folder Structure

- `lib/models`: PODO (Plain Old Dart Objects) for conversation messages and speaker configurations.
- `lib/screens`: Main UI screens (Conversation, History).
- `lib/services`:
  - `AudioStreamService`: Interface with Vosk for real-time transcription and diarization.
  - `DatabaseService`: SQLite implementation for session persistence.
  - `ConversationProvider`: State management for the transcription flow.
  - `HapticService`: Logic for accessibility vibration cues.
- `lib/theme`: High-contrast dark theme and color palettes.
- `assets/models`: Pre-bundled Vosk ZIP models for English and Arabic.

## 🛠️ Setup & Build

1. **Install Flutter:** Follow instructions at [flutter.dev](https://flutter.dev/docs/get-started/install).
2. **Fetch Packages:**
   ```bash
   flutter pub get
   ```
3. **Run on Device:**
   ```bash
   flutter run --release
   ```

## 🎙️ Note on Models
The app uses **Vosk**. Models are stored in `assets/models/`. If you wish to add more languages, download the small/mobile versions from [alphacephei.com/vosk/models](https://alphacephei.com/vosk/models) and update `AudioStreamService` and `SettingsPanel`.
