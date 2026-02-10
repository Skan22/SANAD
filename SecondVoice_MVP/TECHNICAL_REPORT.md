# Technical Whitepaper: Second Voice
**A Hybrid Real-Time STT and Speaker Diarization System for Accessibility**

## Abstract
Second Voice is a mobile application optimized for the deaf and hard-of-hearing community. It addresses the "Text Wall" problem in transcription by introducing a hybrid STT engine coupled with a custom diarization layer. This paper details the implementation of our real-time audio pipeline, the integration of Google Gemini’s Multimodal Live API, and the accessibility-first design principles that drive the user interface.

---

## 1. System Architecture

The application is built using the **Flutter** framework, utilizing a **Provider-based state management** pattern to ensure low-latency UI updates during high-frequency audio processing.

### 1.1 The Dual-Engine Pipeline
At the core of Second Voice is a hybrid transcription supervisor that manages two distinct engines:

1.  **Offline Engine (Vosk):** Based on the Kaldi toolkit, it handles on-device inference using small language models. This ensures high availability and privacy.
2.  **Online Engine (Gemini Realtime):** Uses the `BidiGenerateContent` WebSocket endpoint to stream raw audio to Gemini 2.0 Flash. This provides context-aware transcription and superior handling of complex vocabulary.

### 1.2 Component Stack
*   **Language:** Dart (Flutter 3.x)
*   **Audio Capture:** `record` package (PCM16, 16kHz, Mono)
*   **Offline AI:** `vosk_flutter`
*   **Cloud AI:** `web_socket_channel` (Gemini Multimodal Live)
*   **Database:** SQLite (`sqflite`) for conversation history
*   **Persistence:** `shared_preferences` for engine and UI settings

---

## 2. Audio Processing Infrastructure

### 2.1 Raw Stream Management
The application captures raw PCM16 audio bytes from the device microphone. The `AudioStreamService` acts as a data broker, branching the stream into:
*   **The Transcription Pipe:** Bytes are pushed to the active STT engine.
*   **The Visualization Pipe:** Peak amplitude calculation (`RMS` - Root Mean Square) for the real-time waveform display.

### 2.2 Latency Optimization
To ensure the user "reads" as they "hear," we minimized buffer sizes to the smallest stable unit (approx. 100ms chunks).
*   **Vosk Inference:** Runs in a dedicated background isolate (managed by the plugin) to prevent UI jank.
*   **Gemini Streaming:** Audio is base64-encoded and sent via WebSockets as `media_chunks`.

---

## 3. Gemini Multimodal Live Integration

A significant technical achievement in this project is the manual implementation of the Gemini Multimodal Live WebSocket protocol, bypassing traditional REST overhead.

### 3.1 The Handshake & Pathing
We successfully navigated the `BidiGenerateContent` requirement. The connection URI is dynamically constructed to ensure proper encoding of API keys containing special characters:
```dart
wss://generativelanguage.googleapis.com/ws/google.ai.generativelanguage.v1beta.GenerativeService.BidiGenerateContent?key=$encodedKey
```

### 3.2 System Architecture Diagram
The following diagram illustrates the high-level data flow from the microphone capture to the user interface, highlighting the parallel processing of audio for both transcription and visualization.

![alt text](image.png)


### 3.3 Real-Time Configuration
Upon connection, a `setup` message is sent to configure the model:
*   **Model:** `models/gemini-2.5-flash-native-audio-preview-12-2025`
*   **Modality:** `TEXT`
*   **System Instruction:** A specialized prompt forcing the model into "Transcription-Only" mode to prevent conversational drift and ensure exact verbal mirroring.

---

## 4. Custom Speaker Diarization Logic

Traditional diarization requires heavy on-device compute. Second Voice implements a "Constraint-Based Cycling" heuristic:

### 4.1 The Algorithm
1.  **Participant Thresholding:** The user pre-defines the number of speakers (e.g., 3 participants).
2.  **Silence Detection:** The system monitors `pauseThreshold` (adjustable via UI).
3.  **Speaker Identity Cycling:** When a silence period exceeding the threshold is followed by new speech, the diarizer assumes a potential speaker change and cycles the `speaker_id` to the next logical participant in the set.
4.  **Human-in-the-Loop:** Recognising AI limitations, we implemented a "Rename & Reassign" system where users can long-press a chat bubble to retroactively correct speaker identities, which then trains the local session state.

---

## 5. Accessibility-First Design System

### 5.1 Haptic Pacing
The application uses the device’s **Haptic Engine** to solve the "Attention Drift" problem.
*   **Speaker Change Pulse:** A distinct triple-tap vibration occurs when the active speaker changes.
*   **Listening Start/Stop:** Tactile confirmation that the microphone is active.
This allows deaf users to look away from the phone and "feel" the flow of the conversation.

### 5.2 Responsive Typography
Unlike standard apps, our font-size system is relative.
*   Users can scale text from 20pt to 40pt.
*   The entire layout, including bubble padding and icon sizing, re-calculates dynamically to prevent overflow and maintain readability for those with low vision.

### 5.3 Arabic Localization (RTL)
The system fully supports Right-To-Left (RTL) transcription. This required:
*   Customizing the Vosk model loader to recognize `ar-tn-0.1` models.
*   Implementing `Directionality` widgets in the chat view to swap bubble alignment based on the active language.

---

## 6. Data Persistence & History

We utilized a structured SQLite schema to ensure conversations survived app restarts:
*   **Conversations Table:** Stores ID, session title, and a JSON-encoded map of refined speaker names.
*   **Messages Table:** Stores raw text, speaker foreign key, and sub-second timestamps (`startTime` and `endTime`) for future playback synchronization.

---

## 7. Challenges & Pivots

*   **Recorder Disposal Bug:** Early versions crashed when switching languages because the recorder was disposed along with the STT engine. We refactored the `AudioStreamService` to separate "Service Disposal" from "Engine Cleanup."
*   **WebSocket Handshake:** The move from the `MultimodalLive` path to `BidiGenerateContent` was a critical pivot based on protocol analysis to fix the "connection not upgraded" error.

## 8. Conclusion
Second Voice demonstrates that by combining local processing (reliability) with cloud scale (intelligence), we can create accessibility tools that are both powerful and dependable. The project sets a blueprint for real-time, multi-user assistive technology on mobile devices.

---
**Technical Report - Final Submission**
**Lead Engineer: Skander**
**Date: Feb 10, 2026**