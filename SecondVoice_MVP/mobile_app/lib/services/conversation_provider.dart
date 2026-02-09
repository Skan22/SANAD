/// ConversationProvider - State management for Second Voice
/// Manages conversation messages, listening state, and accessibility settings

import 'package:flutter/foundation.dart';
import 'package:vibration/vibration.dart';
import '../models/conversation_message.dart';
import 'audio_stream_service.dart';

class ConversationProvider extends ChangeNotifier {
  // Message state
  final List<ConversationMessage> _messages = [];
  String? _partialText;
  String? _lastSpeakerId;

  // Accessibility settings
  double _fontSize = 24.0;
  bool _hapticEnabled = true;

  // Audio service
  late final AudioStreamService _audioService;
  bool _isListening = false;
  bool _isInitialized = false;

  ConversationProvider() {
    _audioService = AudioStreamService(
      onNewMessage: _handleNewMessage,
      onPartialResult: _handlePartialResult,
      onError: _handleError,
    );
  }

  // Getters
  List<ConversationMessage> get messages => List.unmodifiable(_messages);
  String? get partialText => _partialText;
  double get fontSize => _fontSize;
  bool get isListening => _isListening;
  bool get isInitialized => _isInitialized;
  bool get hapticEnabled => _hapticEnabled;

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

    await _audioService.startListening();
    _isListening = _audioService.isListening;
    notifyListeners();
  }

  /// Stop listening
  Future<void> stopListening() async {
    if (!_isListening) return;

    await _audioService.stopListening();
    _isListening = false;
    _partialText = null;
    notifyListeners();
  }

  /// Toggle listening state
  Future<void> toggleListening() async {
    if (_isListening) {
      await stopListening();
    } else {
      await startListening();
    }
  }

  /// Handle new message from audio service
  void _handleNewMessage(ConversationMessage message) {
    // Check for speaker change and trigger haptic
    if (_lastSpeakerId != null && _lastSpeakerId != message.speakerId) {
      _triggerHapticFeedback();
    }
    _lastSpeakerId = message.speakerId;

    _messages.add(message);
    _partialText = null;
    notifyListeners();
  }

  /// Handle partial result from audio service
  void _handlePartialResult(String partial) {
    _partialText = partial;
    notifyListeners();
  }

  /// Handle error from audio service
  void _handleError(String error) {
    debugPrint('Audio error: $error');
    // Could show a snackbar or dialog here
  }

  /// Trigger haptic feedback for speaker change
  Future<void> _triggerHapticFeedback() async {
    if (!_hapticEnabled) return;
    
    final hasVibrator = await Vibration.hasVibrator() ?? false;
    if (hasVibrator) {
      Vibration.vibrate(duration: 100, amplitude: 128);
    }
  }

  /// Add a message manually (for testing)
  void addMessage(ConversationMessage message) {
    if (_lastSpeakerId != null && _lastSpeakerId != message.speakerId) {
      _triggerHapticFeedback();
    }
    _lastSpeakerId = message.speakerId;
    
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

  /// Set font size (clamped to 20-40pt)
  void setFontSize(double size) {
    _fontSize = size.clamp(20.0, 40.0);
    notifyListeners();
  }

  /// Toggle haptic feedback
  void setHapticEnabled(bool enabled) {
    _hapticEnabled = enabled;
    notifyListeners();
  }

  /// Set listening state manually (for UI without audio)
  void setListening(bool listening) {
    _isListening = listening;
    notifyListeners();
  }

  /// Clear all messages
  void clearMessages() {
    _messages.clear();
    _lastSpeakerId = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }
}
