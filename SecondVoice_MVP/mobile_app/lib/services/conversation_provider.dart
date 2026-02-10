import 'package:flutter/foundation.dart';
import '../models/conversation_message.dart';
import 'audio_stream_service.dart';
import 'haptic_service.dart';

/// State management for Second Voice.
/// Manages conversation messages, listening state, and accessibility settings.
class ConversationProvider extends ChangeNotifier {
  // ── Message state ─────────────────────────────────────────────────
  final List<ConversationMessage> _messages = [];
  String? _partialText;
  String? _lastSpeakerId;
  String? _errorMessage;

  // ── Accessibility settings ────────────────────────────────────────
  double _fontSize = 24.0;

  // ── Audio service ─────────────────────────────────────────────────
  late final AudioStreamService _audioService;
  bool _isListening = false;
  bool _isInitialized = false;

  // ── Configuration ─────────────────────────────────────────────────
  double _pauseThreshold = 0.5;

  ConversationProvider() {
    _audioService = AudioStreamService(
      onNewMessage: _handleNewMessage,
      onPartialResult: _handlePartialResult,
      onError: _handleError,
      onListeningStateChanged: _handleListeningStateChanged,
      pauseThreshold: _pauseThreshold,
    );
  }

  // ── Getters ───────────────────────────────────────────────────────
  List<ConversationMessage> get messages => List.unmodifiable(_messages);
  String? get partialText => _partialText;
  double get fontSize => _fontSize;
  bool get isListening => _isListening;
  bool get isInitialized => _isInitialized;
  bool get hapticEnabled => HapticService.enabled;
  double get pauseThreshold => _pauseThreshold;
  String? get errorMessage => _errorMessage;

  /// Initialize audio service
  Future<bool> initialize() async {
    if (_isInitialized) return true;
    _isInitialized = await _audioService.initialize();
    notifyListeners();
    return _isInitialized;
  }

  /// Start listening for speech
  Future<void> startListening() async {
    if (_isListening) return;
    _errorMessage = null;
    await _audioService.startListening();
    // State is updated via onListeningStateChanged callback
  }

  /// Stop listening
  Future<void> stopListening() async {
    if (!_isListening) return;
    await _audioService.stopListening();
    _partialText = null;
    // State is updated via onListeningStateChanged callback
  }

  /// Toggle listening state
  Future<void> toggleListening() async {
    if (_isListening) {
      await stopListening();
    } else {
      await startListening();
    }
  }

  // ── Settings ──────────────────────────────────────────────────────

  /// Set font size (clamped to 20-40pt)
  void setFontSize(double size) {
    _fontSize = size.clamp(20.0, 40.0);
    notifyListeners();
  }

  /// Toggle haptic feedback
  void setHapticEnabled(bool enabled) {
    HapticService.setEnabled(enabled);
    notifyListeners();
  }

  /// Update pause threshold for speaker detection
  void setPauseThreshold(double seconds) {
    _pauseThreshold = seconds.clamp(0.2, 2.0);
    _audioService.pauseThreshold = _pauseThreshold;
    notifyListeners();
  }

  // ── Message management ────────────────────────────────────────────

  /// Add a message manually (for testing)
  void addMessage(ConversationMessage message) {
    _checkSpeakerChange(message.speakerId);
    _messages.add(message);
    notifyListeners();
  }

  /// Update the last message's text (for partial results)
  void updateLastMessage(String text) {
    if (_messages.isNotEmpty) {
      _messages[_messages.length - 1] = _messages.last.copyWith(text: text);
      notifyListeners();
    }
  }

  /// Clear all messages
  void clearMessages() {
    _messages.clear();
    _lastSpeakerId = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Dismiss the current error
  void dismissError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Export conversation as formatted text
  String exportConversation() {
    final buffer = StringBuffer();
    buffer.writeln('Second Voice — Conversation Export');
    buffer.writeln('=' * 40);
    buffer.writeln();
    for (final msg in _messages) {
      final time = msg.startTime != null
          ? '[${_formatDuration(msg.startTime!)}] '
          : '';
      buffer.writeln('$time${msg.speakerName}: ${msg.text}');
    }
    return buffer.toString();
  }

  // ── Private callbacks ──────────────────────────────────────────────

  void _handleNewMessage(ConversationMessage message) {
    _checkSpeakerChange(message.speakerId);
    _messages.add(message);
    _partialText = null;
    notifyListeners();
  }

  void _handlePartialResult(String partial) {
    _partialText = partial;
    notifyListeners();
  }

  void _handleError(String error) {
    debugPrint('Audio error: $error');
    _errorMessage = error;
    notifyListeners();
  }

  void _handleListeningStateChanged(bool listening) {
    _isListening = listening;
    notifyListeners();
  }

  void _checkSpeakerChange(String speakerId) {
    if (_lastSpeakerId != null && _lastSpeakerId != speakerId) {
      HapticService.onSpeakerChange();
    }
    _lastSpeakerId = speakerId;
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }
}
