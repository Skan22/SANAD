import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/conversation_message.dart';
import 'audio_stream_service.dart';
import 'haptic_service.dart';
import 'database_service.dart';

/// State management for Second Voice.
/// Manages conversation messages, listening state, and accessibility settings.
class ConversationProvider extends ChangeNotifier {
  // ── Message state ─────────────────────────────────────────────────
  List<ConversationMessage> _messages = [];
  final Map<String, String> _speakerNames = {}; // speakerId -> name
  String? _partialText;
  String? _lastSpeakerId;
  String? _errorMessage;
  double _currentAmplitude = 0.0;
  SharedPreferences? _prefs;
  
  // ── History state ─────────────────────────────────────────────────
  List<Map<String, dynamic>> _history = [];
  String? _currentConversationId;

  // ── Accessibility settings ────────────────────────────────────────
  double _fontSize = 24.0;
  String _currentModelPath = 'assets/models/vosk-model-small-en-us-0.15.zip';

  // ── Audio service ─────────────────────────────────────────────────
  late final AudioStreamService _audioService;
  StreamSubscription<double>? _amplitudeSubscription;
  StreamSubscription<int>? _latencySubscription;
  bool _isListening = false;
  bool _isInitialized = false;
  int _currentLatency = 0;
  bool _showPerformanceOverlay = false;

  // ── Configuration ─────────────────────────────────────────────────
  double _pauseThreshold = 0.5;
  int _maxParticipants = 2; // Default to 2 for Phase 4 focus


  ConversationProvider() {
    _audioService = AudioStreamService(
      onNewMessage: _handleNewMessage,
      onPartialResult: _handlePartialResult,
      onError: _handleError,
      onListeningStateChanged: _handleListeningStateChanged,
      pauseThreshold: _pauseThreshold,
      maxParticipants: _maxParticipants,
    );

    _amplitudeSubscription = _audioService.amplitudeStream.listen((amplitude) {
      _currentAmplitude = amplitude;
      notifyListeners();
    });

    _latencySubscription = _audioService.latencyStream.listen((latency) {
      _currentLatency = latency;
      notifyListeners();
    });
    
    _initProvider();
  }

  Future<void> _initProvider() async {
    _prefs = await SharedPreferences.getInstance();
    
    // Load preferences
    _fontSize = _prefs!.getDouble('font_size') ?? 24.0;
    _pauseThreshold = _prefs!.getDouble('pause_threshold') ?? 0.5;
    _maxParticipants = _prefs!.getInt('max_participants') ?? 2;
    _audioService.pauseThreshold = _pauseThreshold;
    _audioService.maxParticipants = _maxParticipants;
    _currentModelPath = _prefs!.getString('current_model_path') ?? 'assets/models/vosk-model-small-en-us-0.15.zip';
    _showPerformanceOverlay = _prefs!.getBool('show_performance_overlay') ?? false;
    _audioService.forceDemoMode = _prefs!.getBool('demo_mode') ?? false;
    
    _loadSpeakerNames();
    await loadHistory();
  }

  void _loadSpeakerNames() {
    if (_prefs == null) return;
    final keys = _prefs!.getKeys();
    for (final key in keys) {
      if (key.startsWith('speaker_name_')) {
        final id = key.replaceFirst('speaker_name_', '');
        _speakerNames[id] = _prefs!.getString(key) ?? '';
      }
    }
    notifyListeners();
  }

  Future<void> _saveSpeakerName(String id, String name) async {
    await _prefs?.setString('speaker_name_$id', name);
  }

  // ── Getters ───────────────────────────────────────────────────────
  List<ConversationMessage> get messages => List.unmodifiable(_messages);
  List<Map<String, dynamic>> get history => List.unmodifiable(_history);
  String? get partialText => _partialText;
  double get fontSize => _fontSize;
  bool get isListening => _isListening;
  bool get isInitialized => _isInitialized;
  bool get hapticEnabled => HapticService.enabled;
  double get pauseThreshold => _pauseThreshold;
  int get maxParticipants => _maxParticipants;
  String? get errorMessage => _errorMessage;
  double get currentAmplitude => _currentAmplitude;
  String get currentModelPath => _currentModelPath;
  int get currentLatency => _currentLatency;
  bool get showPerformanceOverlay => _showPerformanceOverlay;
  bool get demoMode => _audioService.forceDemoMode;

  /// Update max participants
  void setMaxParticipants(int count) {
    _maxParticipants = count;
    _audioService.maxParticipants = count;
    _prefs?.setInt('max_participants', count);
    notifyListeners();
  }

  /// Initialize audio service
  Future<bool> initialize() async {
    if (_isInitialized) return true;
    _isInitialized = await _audioService.initialize(modelAssetPath: _currentModelPath);
    notifyListeners();
    return _isInitialized;
  }

  /// Toggle demo mode
  void setDemoMode(bool enabled) {
    _audioService.forceDemoMode = enabled;
    _prefs?.setBool('demo_mode', enabled);
    notifyListeners();
  }

  /// Toggle performance overlay
  void setPerformanceOverlayEnabled(bool enabled) {
    _showPerformanceOverlay = enabled;
    _prefs?.setBool('show_performance_overlay', enabled);
    notifyListeners();
  }

  /// Change transcription model (language)
  Future<void> setModel(String path) async {
    if (_currentModelPath == path) return;
    
    final wasListening = _isListening;
    if (wasListening) await stopListening();
    
    _currentModelPath = path;
    await _prefs?.setString('current_model_path', path);
    
    _isInitialized = false;
    await initialize();
    
    if (wasListening) await startListening();
    notifyListeners();
  }

  /// Start listening for speech
  Future<void> startListening() async {
    if (_isListening) return;
    _errorMessage = null;
    
    // Start a new conversation if we don't have one active
    if (_currentConversationId == null || _messages.isEmpty) {
      _currentConversationId = DateTime.now().millisecondsSinceEpoch.toString();
    }
    
    await _audioService.startListening();
  }

  /// Stop listening
  Future<void> stopListening() async {
    if (!_isListening) return;
    await _audioService.stopListening();
    _partialText = null;
    _currentAmplitude = 0.0;
    
    // Auto-save on stop if we have messages
    if (_messages.isNotEmpty && _currentConversationId != null) {
      await saveCurrentSession(title: 'Conversation ${_formatDate(DateTime.now())}');
    }
    
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

  // ── Settings ──────────────────────────────────────────────────────

  /// Set font size (clamped to 20-40pt)
  void setFontSize(double size) {
    _fontSize = size.clamp(20.0, 40.0);
    _prefs?.setDouble('font_size', _fontSize);
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
    _prefs?.setDouble('pause_threshold', _pauseThreshold);
    _audioService.pauseThreshold = _pauseThreshold;
    notifyListeners();
  }

  // ── Message management ────────────────────────────────────────────

  /// Rename a speaker and update all their messages
  void renameSpeaker(String speakerId, String newName) {
    _speakerNames[speakerId] = newName;
    _saveSpeakerName(speakerId, newName);
    
    // Update existing messages
    for (int i = 0; i < _messages.length; i++) {
      if (_messages[i].speakerId == speakerId) {
        _messages[i] = _messages[i].copyWith(speakerName: newName);
      }
    }
    
    // Sync to DB if active
    if (_currentConversationId != null) {
       saveCurrentSession();
    }
    
    notifyListeners();
  }

  /// Edit text of a specific message
  void editMessage(String messageId, String newText) {
    final index = _messages.indexWhere((m) => m.id == messageId);
    if (index != -1) {
      _messages[index] = _messages[index].copyWith(text: newText);
      saveCurrentSession();
      notifyListeners();
    }
  }

  /// Reassign a message to a different speaker
  void reassignMessage(String messageId, String targetSpeakerId) {
    final index = _messages.indexWhere((m) => m.id == messageId);
    if (index != -1) {
      // Find name and color for the target speaker
      String? targetName = _speakerNames[targetSpeakerId];
      SpeakerColor? targetColor;
      
      for (final msg in _messages) {
        if (msg.speakerId == targetSpeakerId) {
          targetName ??= msg.speakerName;
          targetColor = msg.color;
          break;
        }
      }
      
      if (targetColor == null && targetSpeakerId.startsWith('speaker_')) {
        final lastDigit = int.tryParse(targetSpeakerId.split('_').last) ?? 0;
        targetColor = SpeakerColor.forSpeaker(lastDigit);
        targetName ??= 'Speaker ${lastDigit + 1}';
      }

      if (targetName != null && targetColor != null) {
        _messages[index] = _messages[index].copyWith(
          speakerId: targetSpeakerId,
          speakerName: targetName,
          color: targetColor,
        );
        saveCurrentSession();
        notifyListeners();
      }
    }
  }

  // ── History & Persistence ─────────────────────────────────────────

  Future<void> loadHistory() async {
    _history = await DatabaseService.instance.getConversations();
    notifyListeners();
  }

  Future<void> saveCurrentSession({String? title}) async {
    if (_currentConversationId == null || _messages.isEmpty) return;
    
    // Update title if provided, otherwise keep existing
    String sessionTitle = title ?? 'Active Session';
    if (title == null && _history.any((h) => h['id'] == _currentConversationId)) {
        sessionTitle = _history.firstWhere((h) => h['id'] == _currentConversationId)['title'];
    }

    await DatabaseService.instance.saveConversation(
      id: _currentConversationId!,
      title: sessionTitle,
      timestamp: DateTime.now(),
      speakerNames: _speakerNames,
      messages: _messages,
    );
    
    await loadHistory();
  }

  Future<void> loadSession(String conversationId) async {
    if (_isListening) await stopListening();
    
    final session = _history.firstWhere((h) => h['id'] == conversationId);
    final msgs = await DatabaseService.instance.getMessages(conversationId);
    
    _currentConversationId = conversationId;
    _messages = msgs;
    
    // Load saved speaker names for this session if any (merging with current)
    final savedNames = jsonDecode(session['speaker_names_json'] as String) as Map<String, dynamic>;
    savedNames.forEach((key, value) {
      _speakerNames[key] = value.toString();
    });
    
    notifyListeners();
  }

  Future<void> deleteSession(String conversationId) async {
    await DatabaseService.instance.deleteConversation(conversationId);
    if (_currentConversationId == conversationId) {
      _currentConversationId = null;
      _messages = [];
    }
    await loadHistory();
  }

  /// Create a fresh new conversation session
  void newConversation() {
    _currentConversationId = null;
    _messages = [];
    _partialText = null;
    notifyListeners();
  }

  // ── Message management (Internal) ─────────────────────────────────

  void _handleNewMessage(ConversationMessage message) {
    _checkSpeakerChange(message.speakerId);
    
    ConversationMessage msg = message;
    if (_speakerNames.containsKey(message.speakerId)) {
      msg = message.copyWith(speakerName: _speakerNames[message.speakerId]);
    } else {
      _speakerNames[message.speakerId] = message.speakerName;
    }
    
    _messages.add(msg);
    _partialText = null;
    saveCurrentSession(); // Background save
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
    if (!listening) _currentAmplitude = 0.0;
    notifyListeners();
  }

  void _checkSpeakerChange(String speakerId) {
    if (_lastSpeakerId != null && _lastSpeakerId != speakerId) {
      HapticService.onSpeakerChange();
    }
    _lastSpeakerId = speakerId;
  }

  /// Clear all messages
  void clearMessages() {
    _messages.clear();
    _lastSpeakerId = null;
    _errorMessage = null;
    notifyListeners();
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour}:${dt.minute}';
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
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

  /// Dismiss the current error
  void dismissError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _amplitudeSubscription?.cancel();
    _audioService.dispose();
    super.dispose();
  }
}
