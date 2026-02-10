import 'dart:async';
import 'dart:convert';
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
  Timer? _demoTimer;

  // Configuration
  double pauseThreshold; // seconds
  static const int sampleRate = 16000;
  static const String modelPath =
      'assets/models/vosk-model-small-en-us-0.15.zip';

  // Callbacks
  final void Function(ConversationMessage)? onNewMessage;
  final void Function(String)? onPartialResult;
  final void Function(String)? onError;
  final void Function(bool)? onListeningStateChanged;

  AudioStreamService({
    this.onNewMessage,
    this.onPartialResult,
    this.onError,
    this.onListeningStateChanged,
    this.pauseThreshold = 0.5,
  });

  bool get isInitialized => _isInitialized;
  bool get isListening => _isListening;

  /// Check if we're running on a desktop platform
  bool get _isDesktop =>
      Platform.isLinux || Platform.isMacOS || Platform.isWindows;

  /// Request microphone permission (vosk_flutter handles this internally on mobile)
  Future<bool> requestMicrophonePermission() async {
    if (_isDesktop) {
      debugPrint('Desktop platform - permissions handled at system level');
      return true;
    }
    debugPrint(
        'Mobile platform - vosk_flutter will handle microphone permissions');
    return true;
  }

  /// Initialize Vosk model and recognizer (does not start speech service)
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      _vosk = VoskFlutterPlugin.instance();

      debugPrint('Loading Vosk model from assets: $modelPath');
      final modelLoader = ModelLoader();
      String loadedModelPath = await modelLoader.loadFromAssets(modelPath);

      // Check if the model files are in a subdirectory (common with zips)
      loadedModelPath = _resolveModelPath(loadedModelPath);

      _model = await _vosk!.createModel(loadedModelPath);

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

  /// Resolve the actual model directory (may be nested inside zip extraction)
  String _resolveModelPath(String basePath) {
    debugPrint('Resolving model path for: $basePath');

    final baseDir = Directory(basePath);
    if (!baseDir.existsSync()) {
      debugPrint('Error: Base model directory does not exist: $basePath');
      return basePath;
    }

    try {
      // 1. Check if model.conf is at the root
      if (File('$basePath/conf/model.conf').existsSync()) {
        debugPrint('Found model.conf at root: $basePath');
        return basePath;
      }

      // 2. Recursive search for conf/model.conf
      final entities = baseDir.listSync(recursive: true);
      debugPrint('Found ${entities.length} entities in model directory');

      for (final entity in entities) {
        if (entity.path.endsWith('conf/model.conf')) {
          // The model directory is the parent of the 'conf' directory
          final modelDir = File(entity.path).parent.parent.path;
          debugPrint('Found model.conf via recursive search: ${entity.path}');
          debugPrint('Resolved model directory: $modelDir');
          return modelDir;
        }
      }

      // 3. Fallback to listing immediate children if recursive search missed it (unlikely)
      debugPrint('Recursive search failed, checking immediate subdirectories...');
      for (final child in baseDir.listSync()) {
        if (child is Directory) {
          final subConf = File('${child.path}/conf/model.conf');
          if (subConf.existsSync()) {
            debugPrint('Found model in immediate subdirectory: ${child.path}');
            return child.path;
          }
        }
      }
    } catch (e) {
      debugPrint('Error while resolving model path: $e');
    }

    debugPrint('Warning: Could not find conf/model.conf, returning base path: $basePath');
    return basePath;
  }

  /// Start listening to microphone and transcribing
  Future<void> startListening() async {
    if (!_isInitialized) {
      final success = await initialize();
      if (!success) return;
    }

    if (_isListening) return;

    try {
      final hasPermission = await requestMicrophonePermission();
      if (!hasPermission) return;

      if (_isDesktop) {
        debugPrint('Desktop detected - using demo mode');
        _isListening = true;
        onListeningStateChanged?.call(true);
        _runDemoMode();
        return;
      }

      // Initialize speech service if not already done (mobile only)
      if (_speechService == null) {
        debugPrint('Initializing speech service...');
        _speechService = await _vosk!.initSpeechService(_recognizer!);
      }

      _speechService!.onResult().listen((result) {
        _handleRecognitionResult(result);
      });

      await _speechService!.start();
      _isListening = true;
      onListeningStateChanged?.call(true);
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
      _demoTimer?.cancel();
      _demoTimer = null;
      await _speechService?.stop();
      _isListening = false;
      onListeningStateChanged?.call(false);
      debugPrint('Stopped listening');
    } catch (e) {
      debugPrint('Stop listening error: $e');
    }
  }

  // ── Private helpers ───────────────────────────────────────────────

  /// Handle recognition result from Vosk
  void _handleRecognitionResult(String result) {
    try {
      final text = _extractText(result);
      if (text.isEmpty) return;
      _emitMessage(text, DateTime.now());
    } catch (e) {
      debugPrint('Error handling result: $e');
    }
  }

  /// Core message creation — single source of truth for speaker assignment
  void _emitMessage(String text, DateTime timestamp) {
    final shouldChangeSpeaker = _lastWordTime != null &&
        timestamp.difference(_lastWordTime!).inMilliseconds >
            (pauseThreshold * 1000);

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

  /// Extract text from Vosk JSON result using dart:convert
  String _extractText(String result) {
    try {
      final Map<String, dynamic> json = jsonDecode(result);
      return (json['text'] as String?)?.trim() ?? '';
    } catch (_) {
      return '';
    }
  }

  /// Demo mode for desktop platforms — simulates transcription
  void _runDemoMode() {
    debugPrint('Running in demo mode - simulating conversation');

    const demoMessages = [
      'Hello, how are you today?',
      'I am doing well, thank you for asking!',
      'This is really great.',
      'The Second Voice app is working perfectly.',
      'The speaker diarization feature looks amazing!',
    ];

    var messageIndex = 0;
    _demoTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!_isListening) {
        timer.cancel();
        return;
      }

      if (messageIndex < demoMessages.length) {
        final now = DateTime.now();
        if (messageIndex > 0) {
          _lastWordTime = now.subtract(const Duration(milliseconds: 600));
        }

        _emitMessage(demoMessages[messageIndex], now);
        messageIndex++;
      } else {
        timer.cancel();
        _isListening = false;
        onListeningStateChanged?.call(false);
        debugPrint('Demo mode completed');
      }
    });
  }

  /// Dispose resources
  Future<void> dispose() async {
    await stopListening();
    _recognizer?.dispose();
    _model?.dispose();
    _isInitialized = false;
  }
}
