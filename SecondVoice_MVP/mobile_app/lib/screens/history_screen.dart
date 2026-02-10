import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/conversation_provider.dart';
import '../theme/app_colors.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversation History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'New Conversation',
            onPressed: () {
              context.read<ConversationProvider>().newConversation();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Consumer<ConversationProvider>(
        builder: (context, provider, _) {
          if (provider.history.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.white24),
                  SizedBox(height: 16),
                  Text(
                    'No saved conversations yet',
                    style: TextStyle(color: Colors.white54),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: provider.history.length,
            itemBuilder: (context, index) {
              final item = provider.history[index];
              final date = DateTime.fromMillisecondsSinceEpoch(item['timestamp']);
              final formattedDate = DateFormat('MMM d, yyyy • HH:mm').format(date);

              return _HistoryCard(
                title: item['title'],
                subtitle: formattedDate,
                onTap: () async {
                  await provider.loadSession(item['id']);
                  if (context.mounted) Navigator.pop(context);
                },
                onDelete: () => _confirmDelete(context, provider, item['id']),
              );
            },
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, ConversationProvider provider, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete Session?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteSession(id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _HistoryCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.surfaceBorder),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.white38),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
