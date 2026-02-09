import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
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
  static const String modelPath = 'assets/models/vosk-model-small-en-us-0.15.zip';

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

  /// Check if we're running on a desktop platform
  bool get _isDesktop => Platform.isLinux || Platform.isMacOS || Platform.isWindows;

  /// Request microphone permission (vosk_flutter handles this internally on mobile)
  Future<bool> requestMicrophonePermission() async {
    // Desktop platforms handle permissions at the system level
    if (_isDesktop) {
      debugPrint('Desktop platform - permissions handled at system level');
      return true;
    }
    
    // On mobile, vosk_flutter's SpeechService handles permission requests
    debugPrint('Mobile platform - vosk_flutter will handle microphone permissions');
    return true;
  }

  /// Initialize Vosk model and recognizer (does not start speech service)
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Initialize Vosk plugin
      _vosk = VoskFlutterPlugin.instance();

      // Load model from assets
      debugPrint('Loading Vosk model from assets: $modelPath');
      final modelLoader = ModelLoader();
      String loadedModelPath = await modelLoader.loadFromAssets(modelPath);

      // Check if the model files are in a subdirectory (common with zips)
      if (!File('$loadedModelPath/conf/model.conf').existsSync()) {
        final dir = Directory(loadedModelPath);
        if (dir.existsSync()) {
          final children = dir.listSync();
          for (final child in children) {
            if (child is Directory && File('${child.path}/conf/model.conf').existsSync()) {
              loadedModelPath = child.path;
              debugPrint('Found model in subdirectory: $loadedModelPath');
              break;
            }
          }
        }
      }

      _model = await _vosk!.createModel(loadedModelPath);
      
      // Create recognizer
      _recognizer = await _vosk!.createRecognizer(
        model: _model!,
        sampleRate: sampleRate,
      );

      _isInitialized = true;
      debugPrint('Vosk model and recognizer initialized successfully');
      return true;
    } catch (e) {
      onError?.call('Failed to initialize Vosk model: $e');
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
      // Request permission if needed (skipped on desktop)
      final hasPermission = await requestMicrophonePermission();
      if (!hasPermission) return;

      // On Linux desktop, vosk_flutter's SpeechService doesn't work
      // Use demo mode instead to show UI functionality
      if (_isDesktop) {
        debugPrint('Desktop detected - using demo mode');
        _isListening = true;
        _runDemoMode();
        return;
      }

      // Initialize speech service if not already done (mobile only)
      if (_speechService == null) {
        debugPrint('Initializing speech service...');
        _speechService = await _vosk!.initSpeechService(_recognizer!);
      }

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

  /// Demo mode for desktop platforms - simulates transcription
  void _runDemoMode() {
    debugPrint('Running in demo mode - simulating conversation');
    
    final demoMessages = [
      'Hello, how are you today?',
      'I am doing great, thanks for asking!',
      'That is wonderful to hear.',
      'Second Voice is working perfectly.',
      'The speaker diarization looks amazing!',
    ];

    var messageIndex = 0;
    Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!_isListening) {
        timer.cancel();
        return;
      }

      if (messageIndex < demoMessages.length) {
        // Simulate speaker changes
        final now = DateTime.now();
        if (messageIndex > 0) {
          // Simulate pause for speaker change
          _lastWordTime = now.subtract(const Duration(milliseconds: 600));
        }
        
        final text = demoMessages[messageIndex];
        _handleDemoResult(text, now);
        messageIndex++;
      } else {
        timer.cancel();
        _isListening = false;
        debugPrint('Demo mode completed');
      }
    });
  }

  /// Handle demo result (same logic as real results)
  void _handleDemoResult(String text, DateTime timestamp) {
    final shouldChangeSpeaker = _lastWordTime != null &&
        timestamp.difference(_lastWordTime!).inMilliseconds > (pauseThreshold * 1000);

    if (shouldChangeSpeaker || _currentSpeakerId == null) {
      _speakerCount = (_speakerCount + 1) % 5;
      _currentSpeakerId = 'speaker_$_speakerCount';
    }

    _lastWordTime = timestamp;

    final message = ConversationMessage(
      id: timestamp.millisecondsSinceEpoch.toString(),
      speakerId: _currentSpeakerId!,
      speakerName: 'Speaker ${_speakerCount + 1}',
      text: text,
      timestamp: timestamp,
      startTime: Duration(milliseconds: timestamp.millisecondsSinceEpoch),
      color: SpeakerColor.forSpeaker(_speakerCount),
    );

    onNewMessage?.call(message);
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
