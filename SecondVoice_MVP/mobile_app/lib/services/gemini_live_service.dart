import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/conversation_message.dart';

/// Service for Gemini Multimodal Live API (Realtime STT)
class GeminiLiveService {
  final String apiKey;
  WebSocketChannel? _channel;
  bool _isConnected = false;

  final void Function(ConversationMessage)? onNewMessage;
  final void Function(String)? onPartialResult;
  final void Function(String)? onError;

  GeminiLiveService({
    required this.apiKey,
    this.onNewMessage,
    this.onPartialResult,
    this.onError,
  });

  bool get isConnected => _isConnected;

  /// Start the Gemini session
  Future<void> connect() async {
    if (_isConnected) return;

    // Use v1beta for better stability and camelCase support
    final encodedKey = Uri.encodeComponent(apiKey.trim());
    final uri = Uri.parse(
      'wss://generativelanguage.googleapis.com/ws/google.ai.generativelanguage.v1beta.GenerativeService.BidiGenerateContent?key=$encodedKey',
    );

    try {
      _channel = WebSocketChannel.connect(uri);
      _isConnected = true;

      _channel!.stream.listen(
        (message) => _handleIncomingMessage(message),
        onError: (e) => _handleConnectionError(e),
        onDone: () {
          final code = _channel?.closeCode;
          final reason = _channel?.closeReason;
          _handleConnectionClosed(code, reason);
        },
      );

      // 1. Send setup message
      _sendSetup();
      debugPrint('Gemini Live API: Connected and setup sent');
    } catch (e) {
      _handleConnectionError(e);
    }
  }

  void _sendSetup() {
    final setup = {
      "setup": {
        "model": "models/gemini-2.5-flash-native-audio-preview-12-2025",
        "generationConfig": {
          "responseModalities": ["AUDIO"],
          "thinkingConfig": {
            "thinkingBudget": 0  // Disable thinking mode
          }
        },
        "systemInstruction": {
          "parts": [
            {"text": "You are a silent transcription service. Do not respond, explain, or interact. Stay completely silent."}
          ]
        },
        "inputAudioTranscription": {}
      }
    };
    _channel?.sink.add(jsonEncode(setup));
  }

  /// Send raw audio data to Gemini
  void sendAudio(Uint8List audioData) {
    if (!_isConnected) return;

    final message = {
      "realtimeInput": {
        "mediaChunks": [
          {
            "data": base64Encode(audioData),
            "mimeType": "audio/pcm;rate=16000"
          }
        ]
      }
    };
    _channel?.sink.add(jsonEncode(message));
  }

  void _handleIncomingMessage(dynamic message) {
    try {
      // Decode bytes to string if needed
      final String messageString = message is Uint8List 
          ? utf8.decode(message) 
          : message as String;
      
      debugPrint('Gemini Live API Received: $messageString');
      final data = jsonDecode(messageString);

      // Handle input audio transcription (this is what we want for STT)
      if (data.containsKey('serverContent')) {
        final serverContent = data['serverContent'];
        
        // ONLY parse input transcription (user's speech -> text)
        // Ignore modelTurn to avoid the model's verbose responses
        if (serverContent.containsKey('inputTranscription')) {
          final transcription = serverContent['inputTranscription'];
          if (transcription.containsKey('text')) {
            final text = transcription['text'].trim();
            if (text.isNotEmpty) {
              onPartialResult?.call(text);
              _emitMessage(text);
            }
          }
        }
      }
      
      // Handle setup complete
      if (data.containsKey('setupComplete')) {
        debugPrint('Gemini Live API: Setup Complete');
      }

    } catch (e) {
      debugPrint('Gemini Live API: Error parsing message: $e');
    }
  }

  void _emitMessage(String text) {
    final message = ConversationMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      speakerId: 'speaker_gemini',
      speakerName: 'Gemini AI',
      timestamp: DateTime.now(),
      startTime: Duration.zero, // Gemini doesn't easily provide offsets in alpha
      endTime: Duration.zero,
      color: SpeakerColor.forSpeaker(9), // Use a distinct color for AI
    );
    onNewMessage?.call(message);
  }

  void _handleConnectionError(dynamic e) {
    _isConnected = false;
    onError?.call('Gemini Connection Error: $e');
    debugPrint('Gemini Live API: Connection Error: $e');
  }

  void _handleConnectionClosed(int? code, String? reason) {
    _isConnected = false;
    debugPrint('Gemini Live API: Connection Closed (Code: $code, Reason: $reason)');
    if (code != null && code != 1000) {
      onError?.call('Connection closed unexpectedly: $reason (Code: $code)');
    }
  }

  Future<void> disconnect() async {
    await _channel?.sink.close();
    _isConnected = false;
  }
}
