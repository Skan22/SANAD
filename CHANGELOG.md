# Changelog

All notable changes to Second Voice will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-02-10

### 🎉 Initial Release - SANAD Challenge Submission

#### Added

**Core Features**
- Real-time speech-to-text transcription with speaker diarization
- Hybrid dual-engine architecture:
  - Offline mode using Vosk (Kaldi-based, 100% on-device)
  - Online mode using Google Gemini 2.5 Flash Live API
- Constraint-based speaker cycling algorithm
- Visual speaker identification with 8 high-contrast colors
- Configurable pause threshold for speaker detection (1.0s - 3.0s)
- Manual speaker correction via long-press gesture

**Accessibility**
- WCAG 2.1 Level AA compliance
- Dynamic text scaling (20pt to 40pt)
- Minimum 4.5:1 color contrast ratio
- Haptic feedback patterns:
  - Triple-tap for speaker changes
  - Single pulse for recording start
  - Short pulse for recording stop
- Responsive typography with automatic layout reflow
- Full RTL (Right-to-Left) support for Arabic

**Language Support**
- English (US) - Vosk model: vosk-model-small-en-us-0.15
- Arabic (Modern Standard / Tunisian) - Vosk model: vosk-model-ar-tn-0.1
- Language-aware UI switching
- Seamless model hot-swapping

**Data Management**
- SQLite database for conversation persistence
- Conversation history with search and filtering
- Export conversations as formatted text
- SharedPreferences for user settings
- Conversation metadata (title, timestamps, speaker names)

**User Experience**
- Demo mode with pre-scripted conversations
- Real-time audio waveform visualization
- Performance telemetry (latency overlay)
- Settings panel with:
  - Engine selection (Vosk/Gemini)
  - Gemini API key input
  - Font size slider
  - Number of speakers configuration
  - Pause threshold adjustment
  - Demo mode toggle
  - Language selection

**Technical**
- Cross-platform support: Android, iOS, Linux, macOS, Windows
- WebSocket implementation for Gemini Live API
- Audio streaming with PCM16 format (16kHz, Mono)
- Broadcast stream pattern for audio pipeline
- Provider pattern for state management
- Background isolate for Vosk processing

**Documentation**
- Comprehensive technical whitepaper (1600+ lines)
- Development timeline and challenges
- API integration guides
- Architecture diagrams
- Performance benchmarks
- Setup and installation instructions

#### Performance Metrics

**Vosk (Offline Mode)**
- End-to-end latency: 171-221ms
- Memory footprint: 106-140 MB
- Word error rate (clean): 10-15%
- Word error rate (noisy): 30-40%
- Battery drain (1hr): 8-12%
- Network usage: 0 KB

**Gemini (Online Mode)**
- End-to-end latency: 276-536ms
- Memory footprint: 71-95 MB
- Word error rate (clean): 2-5%
- Word error rate (noisy): 10-20%
- Battery drain (1hr): 5-8%
- Network usage: ~12 MB/hour

#### Known Issues

- Vosk model switching requires app restart on iOS
- Gemini API requires internet connectivity (fallback to Vosk recommended)
- Speaker diarization accuracy degrades with overlapping speech
- Arabic model size not optimized (future enhancement needed)

---

## [Unreleased]

### Planned for v2.0

#### High Priority
- [ ] ML-based speaker recognition using voice biometrics
- [ ] Whisper Tiny/Base model integration for improved offline accuracy
- [ ] Real-time language translation for multi-language conversations
- [ ] Cloud sync with end-to-end encryption
- [ ] Advanced noise cancellation preprocessing

#### Medium Priority
- [ ] Multi-device collaborative transcription
- [ ] Lip reading fusion for noisy environments
- [ ] Custom vocabulary/domain adaptation
- [ ] Export to PDF, DOCX, and SRT formats
- [ ] Conversation analytics (word clouds, sentiment analysis)

#### Low Priority
- [ ] Wear OS integration for wrist-based controls
- [ ] Smart glasses integration (AR/VR)
- [ ] Voice cloning for speaker profiles
- [ ] Integration with assistive listening devices
- [ ] API for third-party developers

---

## Version History

### Legend
- 🎉 **Added** - New features
- 🔧 **Changed** - Changes in existing functionality
- 🗑️ **Deprecated** - Soon-to-be removed features
- 🐛 **Fixed** - Bug fixes
- 🔒 **Security** - Vulnerability patches
- 📚 **Documentation** - Documentation updates

---

### Contributing to Changelog

When making changes, please update this file following this format:

```markdown
## [Version] - YYYY-MM-DD

### Added
- New feature description

### Changed
- Modified feature description

### Fixed
- Bug fix description
```

---

**For full details on any release, see the corresponding GitHub release notes and git tags.**
