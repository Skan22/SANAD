import 'package:flutter/material.dart';
import '../models/conversation_message.dart';

/// High-contrast chat bubble widget for accessibility
/// Aligns left/right based on speaker and uses vibrant colors
class ChatBubble extends StatelessWidget {
  final ConversationMessage message;
  final double fontSize;
  final bool isCurrentSpeaker;
  final VoidCallback? onLongPress;
  final VoidCallback? onSpeakerTap;

  const ChatBubble({
    super.key,
    required this.message,
    required this.fontSize,
    this.isCurrentSpeaker = false,
    this.onLongPress,
    this.onSpeakerTap,
  });

  @override
  Widget build(BuildContext context) {
    final isRightAligned = message.speakerId == 'speaker_1';
    final alignment =
        isRightAligned ? Alignment.centerRight : Alignment.centerLeft;

    final bubbleColor = Color(message.color.value);
    final textColor = _getContrastColor(bubbleColor);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Align(
        alignment: alignment,
        child: Column(
          crossAxisAlignment:
              isRightAligned ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Speaker label
            GestureDetector(
              onTap: onSpeakerTap,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 4, left: 4, right: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      message.speakerName,
                      style: TextStyle(
                        color: bubbleColor,
                        fontSize: fontSize * 0.6,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (onSpeakerTap != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Icon(Icons.edit, size: fontSize * 0.4, color: bubbleColor.withOpacity(0.5)),
                      ),
                  ],
                ),
              ),
            ),

            // Message bubble
            GestureDetector(
              onLongPress: onLongPress,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                decoration: BoxDecoration(
                  color: bubbleColor.withAlpha(38), // 15% opacity
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: Radius.circular(isRightAligned ? 20 : 4),
                    bottomRight: Radius.circular(isRightAligned ? 4 : 20),
                  ),
                  border: Border.all(
                    color: bubbleColor.withAlpha(128), // 50% opacity
                    width: 2,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.text,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: fontSize,
                        height: 1.3,
                      ),
                    ),
                    if (message.startTime != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          _formatDuration(message.startTime!),
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: fontSize * 0.5,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Current speaker indicator
            if (isCurrentSpeaker)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'SPEAKING',
                    style: TextStyle(
                      color: textColor,
                      fontSize: fontSize * 0.4,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Get contrasting text color for accessibility
  Color _getContrastColor(Color background) {
    final luminance = background.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  /// Format duration as MM:SS
  String _formatDuration(Duration duration) {
    final minutes =
        duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds =
        duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
