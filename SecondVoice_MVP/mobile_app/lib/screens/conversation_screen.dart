import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';
import '../services/conversation_provider.dart';
import '../widgets/chat_bubble.dart';

/// Main conversation screen with live transcription display
/// Designed for maximum accessibility with high contrast and adjustable text
class ConversationScreen extends StatefulWidget {
  const ConversationScreen({super.key});

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final ScrollController _scrollController = ScrollController();
  String? _lastSpeakerId;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Trigger haptic feedback when speaker changes
  Future<void> _triggerVibration() async {
    final hasVibrator = await Vibration.hasVibrator() ?? false;
    if (hasVibrator) {
      // Short vibration pattern for speaker change
      Vibration.vibrate(duration: 100, amplitude: 128);
    }
  }

  /// Auto-scroll to bottom when new messages arrive
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          // Settings panel (font size slider)
          _buildSettingsPanel(context),
          
          // Conversation messages
          Expanded(
            child: _buildMessageList(context),
          ),
          
          // Recording controls
          _buildControlPanel(context),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.hearing,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          const Text('Second Voice'),
        ],
      ),
      centerTitle: true,
      actions: [
        // Clear conversation
        Consumer<ConversationProvider>(
          builder: (context, provider, _) {
            if (provider.messages.isEmpty) return const SizedBox();
            return IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Clear conversation',
              onPressed: () => _showClearDialog(context, provider),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSettingsPanel(BuildContext context) {
    return Consumer<ConversationProvider>(
      builder: (context, provider, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.text_fields, size: 20, color: Colors.white54),
              const SizedBox(width: 12),
              Text(
                'Text Size',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: provider.fontSize * 0.6,
                ),
              ),
              Expanded(
                child: Slider(
                  value: provider.fontSize,
                  min: 20,
                  max: 40,
                  divisions: 4,
                  label: '${provider.fontSize.round()}pt',
                  onChanged: (value) => provider.setFontSize(value),
                ),
              ),
              Text(
                '${provider.fontSize.round()}pt',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: provider.fontSize * 0.6,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageList(BuildContext context) {
    return Consumer<ConversationProvider>(
      builder: (context, provider, _) {
        // Check for speaker change and trigger haptic
        if (provider.messages.isNotEmpty) {
          final currentSpeaker = provider.messages.last.speakerId;
          if (_lastSpeakerId != null && _lastSpeakerId != currentSpeaker) {
            _triggerVibration();
          }
          _lastSpeakerId = currentSpeaker;
          _scrollToBottom();
        }

        if (provider.messages.isEmpty) {
          return _buildEmptyState(context);
        }

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemCount: provider.messages.length,
          itemBuilder: (context, index) {
            final message = provider.messages[index];
            final isCurrentSpeaker = index == provider.messages.length - 1 && provider.isListening;
            
            return ChatBubble(
              message: message,
              fontSize: provider.fontSize,
              isCurrentSpeaker: isCurrentSpeaker,
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.mic_none,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Tap the microphone to start',
              style: TextStyle(
                fontSize: 24,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Your conversation will appear here\nwith color-coded speakers',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white38,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlPanel(BuildContext context) {
    return Consumer<ConversationProvider>(
      builder: (context, provider, _) {
        final isListening = provider.isListening;
        final primaryColor = Theme.of(context).colorScheme.primary;

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Main record button
                GestureDetector(
                  onTap: () async {
                    // Connect to actual audio service via provider
                    await provider.toggleListening();
                    if (provider.isListening) {
                      _triggerVibration();
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isListening ? Colors.red : primaryColor,
                      boxShadow: [
                        BoxShadow(
                          color: (isListening ? Colors.red : primaryColor).withOpacity(0.4),
                          blurRadius: isListening ? 30 : 15,
                          spreadRadius: isListening ? 5 : 0,
                        ),
                      ],
                    ),
                    child: Icon(
                      isListening ? Icons.stop : Icons.mic,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showClearDialog(BuildContext context, ConversationProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text('Clear Conversation?'),
        content: const Text('This will remove all messages.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.clearMessages();
              Navigator.pop(context);
            },
            child: Text(
              'Clear',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
