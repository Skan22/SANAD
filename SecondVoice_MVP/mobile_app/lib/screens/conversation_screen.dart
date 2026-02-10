import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/conversation_provider.dart';
import '../services/haptic_service.dart';
import '../theme/app_colors.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/empty_state.dart';
import '../widgets/recording_button.dart';
import '../widgets/settings_panel.dart';

/// Main conversation screen with live transcription display
/// Designed for maximum accessibility with high contrast and adjustable text
class ConversationScreen extends StatefulWidget {
  const ConversationScreen({super.key});

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
          const SettingsPanel(),
          Expanded(child: _buildMessageList(context)),
          _buildControlPanel(context),
        ],
      ),
    );
  }

  // ── App Bar ────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.hearing, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          const Text('Second Voice'),
        ],
      ),
      centerTitle: true,
      actions: [
        // Export conversation
        Consumer<ConversationProvider>(
          builder: (context, provider, _) {
            if (provider.messages.isEmpty) return const SizedBox();
            return IconButton(
              icon: const Icon(Icons.share),
              tooltip: 'Export conversation',
              onPressed: () => _exportConversation(context, provider),
            );
          },
        ),
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

  // ── Message List ───────────────────────────────────────────────────

  Widget _buildMessageList(BuildContext context) {
    return Consumer<ConversationProvider>(
      builder: (context, provider, _) {
        // Show error as SnackBar
        if (provider.errorMessage != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(provider.errorMessage!),
                backgroundColor: AppColors.error,
                action: SnackBarAction(
                  label: 'Dismiss',
                  textColor: Colors.white,
                  onPressed: () => provider.dismissError(),
                ),
              ),
            );
            provider.dismissError();
          });
        }

        if (provider.messages.isNotEmpty) {
          _scrollToBottom();
        }

        if (provider.messages.isEmpty) {
          return const EmptyState();
        }

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemCount: provider.messages.length,
          itemBuilder: (context, index) {
            final message = provider.messages[index];
            final isCurrentSpeaker =
                index == provider.messages.length - 1 && provider.isListening;

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

  // ── Control Panel ──────────────────────────────────────────────────

  Widget _buildControlPanel(BuildContext context) {
    return Consumer<ConversationProvider>(
      builder: (context, provider, _) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(
              top: BorderSide(color: AppColors.surfaceBorder),
            ),
          ),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RecordingButton(
                  isListening: provider.isListening,
                  onPressed: () async {
                    await provider.toggleListening();
                    if (provider.isListening) {
                      HapticService.onListeningStart();
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Dialogs ────────────────────────────────────────────────────────

  void _showClearDialog(BuildContext context, ConversationProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
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

  void _exportConversation(
      BuildContext context, ConversationProvider provider) {
    final text = provider.exportConversation();
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Conversation copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
