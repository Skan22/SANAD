import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'package:vosk_flutter/vosk_flutter.dart';
import '../models/conversation_message.dart';

/// Audio stream service for real-time speech-to-text using Vosk
/// Handles microphone input, permission management, and transcription
class AudioStreamService {
  // Vosk components
  VoskFlutterPlugin? _vosk;
  Model? _model;
  Recognizer? _recognizer;
  
  // Audio recording
  final _recorder = AudioRecorder();
  StreamSubscription<Uint8List>? _audioSubscription;
  final StreamController<double> _amplitudeController =
      StreamController<double>.broadcast();
  final StreamController<int> _latencyController =
      StreamController<int>.broadcast();

  // State
  bool _isInitialized = false;
  bool _isListening = false;
  String? _currentSpeakerId;
  int _speakerCount = 0;
  DateTime? _lastWordTime;
  Timer? _demoTimer;
  String _currentModelPath = 'assets/models/vosk-model-small-en-us-0.15.zip';

  // Configuration
  double pauseThreshold; // seconds
  bool forceDemoMode = false;
  static const int sampleRate = 16000;

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
  Stream<double> get amplitudeStream => _amplitudeController.stream;
  Stream<int> get latencyStream => _latencyController.stream;
  String get currentModelPath => _currentModelPath;

  /// Check if we're running on a desktop platform or if demo mode is forced
  bool get _shouldRunDemo =>
      forceDemoMode || Platform.isLinux || Platform.isMacOS || Platform.isWindows;

  /// Request microphone permission
  Future<bool> requestMicrophonePermission() async {
    if (_shouldRunDemo) {
      debugPrint('Demo mode active - permissions bypassed');
      return true;
    }
    
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      onError?.call('Microphone permission is required');
      return false;
    }
    return true;
  }

  /// Initialize Vosk model and recognizer
  Future<bool> initialize({String? modelAssetPath}) async {
    final path = modelAssetPath ?? _currentModelPath;
    _currentModelPath = path;

    // If already initialized with the same model, skip
    if (_isInitialized) {
       await dispose();
    }

    try {
      _vosk = VoskFlutterPlugin.instance();

      debugPrint('Loading Vosk model from assets: $path');
      final modelLoader = ModelLoader();
      String loadedModelPath = await modelLoader.loadFromAssets(path);

      // Check if the model files are in a subdirectory
      loadedModelPath = _resolveModelPath(loadedModelPath);

      _model = await _vosk!.createModel(loadedModelPath);

      _recognizer = await _vosk!.createRecognizer(
        model: _model!,
        sampleRate: sampleRate,
      );

      _isInitialized = true;
      debugPrint('Vosk model ($path) initialized successfully');
      return true;
    } catch (e) {
      onError?.call('Failed to initialize Vosk model: $e');
      debugPrint('Vosk initialization error: $e');
      return false;
    }
  }

  /// Resolve the actual model directory
  String _resolveModelPath(String basePath) {
    debugPrint('Resolving model path for: $basePath');

    final baseDir = Directory(basePath);
    if (!baseDir.existsSync()) return basePath;

    try {
      if (File('$basePath/conf/model.conf').existsSync()) return basePath;

      final entities = baseDir.listSync(recursive: true);
      for (final entity in entities) {
        if (entity.path.endsWith('conf/model.conf')) {
          return File(entity.path).parent.parent.path;
        }
      }
    } catch (e) {
      debugPrint('Error while resolving model path: $e');
    }

    return basePath;
  }

  /// Start listening to microphone and transcribing
  Future<void> startListening() async {
    if (!_isInitialized) {
      final success = await initialize(modelAssetPath: _currentModelPath);
      if (!success) return;
    }

    if (_isListening) return;

    try {
      final hasPermission = await requestMicrophonePermission();
      if (!hasPermission) return;

      if (_shouldRunDemo) {
        debugPrint('Desktop detected - using demo mode');
        _isListening = true;
        onListeningStateChanged?.call(true);
        _runDemoMode();
        return;
      }

      // Start recording stream (Mobile)
      debugPrint('Starting audio stream for transcription...');
      final stream = await _recorder.startStream(const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: sampleRate,
        numChannels: 1,
      ));

      _audioSubscription = stream.listen((Uint8List data) async {
        if (_recognizer == null) return;

        final stopwatch = Stopwatch()..start();

        // 1. Process for transcription
        final resultFound = await _recognizer!.acceptWaveformBytes(data);
        
        stopwatch.stop();
        _latencyController.add(stopwatch.elapsedMilliseconds);

        if (resultFound) {
          final result = await _recognizer!.getResult();
          _handleRecognitionResult(result);
        } else {
          final partial = await _recognizer!.getPartialResult();
          onPartialResult?.call(_extractPartialText(partial));
        }

        // 2. Calculate amplitude for visualizer
        _calculateAndEmitAmplitude(data);
      });

      _isListening = true;
      onListeningStateChanged?.call(true);
      debugPrint('Started listening for speech via stream');
    } catch (e) {
      onError?.call('Failed to start listening: $e');
      debugPrint('Start listening error: $e');
      _isListening = false;
      onListeningStateChanged?.call(false);
    }
  }

  /// Stop listening
  Future<void> stopListening() async {
    if (!_isListening) return;

    try {
      _demoTimer?.cancel();
      _demoTimer = null;
      
      await _audioSubscription?.cancel();
      _audioSubscription = null;
      
      await _recorder.stop();
      
      _isListening = false;
      onListeningStateChanged?.call(false);
      debugPrint('Stopped listening');
    } catch (e) {
      debugPrint('Stop listening error: $e');
    }
  }

  /// Calculate amplitude (RMS) from PCM16 data
  void _calculateAndEmitAmplitude(Uint8List data) {
    if (data.isEmpty) return;
    
    double sum = 0;
    // PCM16 is 2 bytes per sample
    for (int i = 0; i < data.length; i += 2) {
      if (i + 1 >= data.length) break;
      
      // Convert 2 bytes to Int16
      final byte1 = data[i];
      final byte2 = data[i+1];
      int sample = (byte2 << 8) | byte1;
      if (sample >= 32768) sample -= 65536;
      
      sum += sample * sample;
    }
    
    final rms = math.sqrt(sum / (data.length / 2));
    // Normalize RMS to 0.0 - 1.0 range (approximate max for speech is around 10000-15000)
    final normalized = (rms / 15000.0).clamp(0.0, 1.0);
    _amplitudeController.add(normalized);
  }

  /// Extract partial text from Vosk JSON
  String _extractPartialText(String result) {
    try {
      final Map<String, dynamic> json = jsonDecode(result);
      return (json['partial'] as String?)?.trim() ?? '';
    } catch (_) {
      return '';
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
    final random = math.Random();
    
    _demoTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!_isListening) {
        timer.cancel();
        return;
      }

      // 1. Emit simulated amplitude
      _amplitudeController.add(0.2 + random.nextDouble() * 0.4);

      // 2. Emit messages periodically (every 2 seconds)
      if (timer.tick % 20 == 0) {
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
          _amplitudeController.add(0.0);
          onListeningStateChanged?.call(false);
          debugPrint('Demo mode completed');
        }
      }
    });
  }

  /// Dispose resources
  Future<void> dispose() async {
    await stopListening();
    await _recorder.dispose();
    _amplitudeController.close();
    _recognizer?.dispose();
    _model?.dispose();
    _isInitialized = false;
  }
}
