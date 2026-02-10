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
import '../widgets/waveform_visualizer.dart';

import 'history_screen.dart';

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
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(child: _buildMessageList(context)),
              _buildControlPanel(context),
            ],
          ),
          _buildPerformanceOverlay(context),
        ],
      ),
    );
  }

  Widget _buildPerformanceOverlay(BuildContext context) {
    return Consumer<ConversationProvider>(
      builder: (context, provider, _) {
        if (!provider.showPerformanceOverlay) return const SizedBox();
        return Positioned(
          top: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.speed, size: 12, color: AppColors.neonBlue),
                const SizedBox(width: 4),
                Text(
                  '${provider.currentLatency}ms',
                  style: const TextStyle(
                    color: AppColors.neonBlue,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── App Bar ────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.history),
        tooltip: 'History',
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HistoryScreen()),
        ),
      ),
      title: const Text('Second Voice'),
      centerTitle: true,
      actions: [
        // New conversation
        IconButton(
          icon: const Icon(Icons.add),
          tooltip: 'New Conversation',
          onPressed: () => context.read<ConversationProvider>().newConversation(),
        ),
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
              onPressed: () => _confirmClear(context, provider),
            );
          },
        ),
        // Settings
        IconButton(
          icon: const Icon(Icons.settings),
          tooltip: 'Settings',
          onPressed: () => _showSettings(context),
        ),
      ],
    );
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => const SettingsPanel(),
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
              onLongPress: () => _showEditMessageDialog(context, provider, message.id, message.text),
              onSpeakerTap: () => _showRenameSpeakerDialog(context, provider, message.speakerId, message.speakerName),
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
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(
              top: BorderSide(color: AppColors.surfaceBorder),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (provider.isListening) const WaveformVisualizer(),
                if (provider.partialText != null && provider.partialText!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      provider.partialText!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: provider.fontSize * 0.8,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RecordingButton(
                      isListening: provider.isListening,
                      onPressed: () async {
                        if (!provider.isListening && provider.messages.isEmpty) {
                          // Show setup before first start
                          _showSetupDialog(context, provider);
                        } else {
                          await provider.toggleListening();
                          if (provider.isListening) {
                            HapticService.onListeningStart();
                          }
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Dialogs ────────────────────────────────────────────────────────

  void _showRenameSpeakerDialog(BuildContext context, ConversationProvider provider, String speakerId, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Rename Speaker'),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Enter new name',
            hintStyle: TextStyle(color: Colors.white54),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                provider.renameSpeaker(speakerId, controller.text);
              }
              Navigator.pop(context);
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _showEditMessageDialog(BuildContext context, ConversationProvider provider, String messageId, String currentText) {
    final controller = TextEditingController(text: currentText);
    String? selectedSpeakerId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: AppColors.surface,
            title: const Text('Edit Message'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   const Text('Assign to Speaker:', style: TextStyle(color: Colors.white70, fontSize: 14)),
                   const SizedBox(height: 8),
                   Wrap(
                     spacing: 8,
                     children: provider.messages
                         .map((m) => m.speakerId)
                         .toSet()
                         .map((id) {
                       final msgFromSpeaker = provider.messages.firstWhere((m) => m.speakerId == id);
                       final isSelected = selectedSpeakerId == id;
                       return ChoiceChip(
                         label: Text(msgFromSpeaker.speakerName),
                         selected: isSelected,
                         onSelected: (val) => setState(() => selectedSpeakerId = id),
                         selectedColor: Color(msgFromSpeaker.color.value),
                         labelStyle: TextStyle(
                           color: isSelected ? Colors.black : Colors.white,
                           fontWeight: FontWeight.bold,
                         ),
                       );
                     }).toList(),
                   ),
                   const SizedBox(height: 16),
                   const Text('Transcription:', style: TextStyle(color: Colors.white70, fontSize: 14)),
                   const SizedBox(height: 8),
                   TextField(
                    controller: controller,
                    autofocus: true,
                    maxLines: null,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Fix text',
                      hintStyle: TextStyle(color: Colors.white54),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (selectedSpeakerId != null) {
                    provider.reassignMessage(messageId, selectedSpeakerId!);
                  }
                  provider.editMessage(messageId, controller.text);
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmClear(BuildContext context, ConversationProvider provider) {
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
              provider.newConversation();
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

  void _showSetupDialog(BuildContext context, ConversationProvider provider) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: AppColors.surface,
            title: const Text('Session Setup'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'How many people are talking?',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [2, 3, 4, 5].map((count) {
                    final isSelected = provider.maxParticipants == count;
                    return InkWell(
                      onTap: () {
                        provider.setMaxParticipants(count);
                        setState(() {});
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.neonBlue : AppColors.surfaceBorder,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          count.toString(),
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await provider.toggleListening();
                  if (provider.isListening) {
                    HapticService.onListeningStart();
                  }
                },
                child: const Text('START SESSION', style: TextStyle(color: AppColors.neonBlue, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
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
