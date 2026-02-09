import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vosk_flutter/vosk_flutter.dart';
import '../models/conversation_message.dart';

/// Audio stream service for real-time speech-to-text using Vosk
/// Handles microphone input, permission management, and transcription
class AudioStreamService {
  // Vosk components
  VoskFlutterPlugin? _vosk;
  Model? _model;
  Recognizer? _recognizer;
  SpeechService? _speechService;

  // State
  bool _isInitialized = false;
  bool _isListening = false;
  String? _currentSpeakerId;
  int _speakerCount = 0;
  DateTime? _lastWordTime;

  // Configuration
  static const double pauseThreshold = 0.5; // seconds
  static const int sampleRate = 16000;
  static const String modelPath = 'assets/models/vosk-model-small-en-us-0.15';

  // Callbacks
  final void Function(ConversationMessage)? onNewMessage;
  final void Function(String)? onPartialResult;
  final void Function(String)? onError;

  AudioStreamService({
    this.onNewMessage,
    this.onPartialResult,
    this.onError,
  });

  bool get isInitialized => _isInitialized;
  bool get isListening => _isListening;

  /// Request microphone permission
  Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      onError?.call('Microphone permission is required for transcription');
      return false;
    }
    return status.isGranted;
  }

  /// Initialize Vosk model and recognizer
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Initialize Vosk plugin
      _vosk = VoskFlutterPlugin.instance();

      // Load model from assets
      debugPrint('Loading Vosk model from: $modelPath');
      _model = await _vosk!.createModel(modelPath);
      
      // Create recognizer
      _recognizer = await _vosk!.createRecognizer(
        model: _model!,
        sampleRate: sampleRate,
      );

      // Initialize speech service for microphone input
      _speechService = await _vosk!.initSpeechService(_recognizer!);

      _isInitialized = true;
      debugPrint('Vosk initialized successfully');
      return true;
    } catch (e) {
      onError?.call('Failed to initialize Vosk: $e');
      debugPrint('Vosk initialization error: $e');
      return false;
    }
  }

  /// Start listening to microphone and transcribing
  Future<void> startListening() async {
    if (!_isInitialized) {
      final success = await initialize();
      if (!success) return;
    }

    if (_isListening) return;

    try {
      // Request permission if needed
      final hasPermission = await requestMicrophonePermission();
      if (!hasPermission) return;

      // Set up result listener
      _speechService!.onResult().listen((result) {
        _handleRecognitionResult(result);
      });

      // Start speech service
      await _speechService!.start();
      _isListening = true;
      debugPrint('Started listening for speech');
    } catch (e) {
      onError?.call('Failed to start listening: $e');
      debugPrint('Start listening error: $e');
    }
  }

  /// Stop listening
  Future<void> stopListening() async {
    if (!_isListening) return;

    try {
      await _speechService?.stop();
      _isListening = false;
      debugPrint('Stopped listening');
    } catch (e) {
      debugPrint('Stop listening error: $e');
    }
  }

  /// Handle recognition result from Vosk
  void _handleRecognitionResult(String result) {
    try {
      // Parse the JSON result
      final text = _extractText(result);
      if (text.isEmpty) return;

      // Determine if speaker changed (pause-based heuristic)
      final now = DateTime.now();
      final shouldChangeSpeaker = _lastWordTime != null &&
          now.difference(_lastWordTime!).inMilliseconds > (pauseThreshold * 1000);

      if (shouldChangeSpeaker || _currentSpeakerId == null) {
        _speakerCount = (_speakerCount + 1) % 5; // Cycle through 5 speakers
        _currentSpeakerId = 'speaker_$_speakerCount';
      }

      _lastWordTime = now;

      // Create conversation message
      final message = ConversationMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        speakerId: _currentSpeakerId!,
        speakerName: 'Speaker ${_speakerCount + 1}',
        text: text,
        timestamp: now,
        startTime: Duration(milliseconds: now.millisecondsSinceEpoch),
        color: SpeakerColor.forSpeaker(_speakerCount),
      );

      onNewMessage?.call(message);
    } catch (e) {
      debugPrint('Error handling result: $e');
    }
  }

  /// Extract text from Vosk JSON result
  String _extractText(String result) {
    // Vosk returns JSON like: {"text": "hello world"}
    // Simple extraction without full JSON parsing
    final textMatch = RegExp(r'"text"\s*:\s*"([^"]*)"').firstMatch(result);
    return textMatch?.group(1)?.trim() ?? '';
  }

  /// Dispose resources
  Future<void> dispose() async {
    await stopListening();
    _recognizer?.dispose();
    _model?.dispose();
    _isInitialized = false;
  }
}
