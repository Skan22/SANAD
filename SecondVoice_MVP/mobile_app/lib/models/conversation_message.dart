/// Conversation message model for Second Voice
/// Represents a single speaker utterance with timing and speaker info

class ConversationMessage {
  final String id;
  final String speakerId;
  final String speakerName;
  final String text;
  final DateTime timestamp;
  final Duration? startTime;
  final Duration? endTime;
  final SpeakerColor color;

  ConversationMessage({
    required this.id,
    required this.speakerId,
    required this.speakerName,
    required this.text,
    required this.timestamp,
    this.startTime,
    this.endTime,
    required this.color,
  });

  /// Create a copy with updated text (for partial results)
  ConversationMessage copyWith({String? text, Duration? endTime}) {
    return ConversationMessage(
      id: id,
      speakerId: speakerId,
      speakerName: speakerName,
      text: text ?? this.text,
      timestamp: timestamp,
      startTime: startTime,
      endTime: endTime ?? this.endTime,
      color: color,
    );
  }

  /// Convert to JSON for storage/debugging
  Map<String, dynamic> toJson() => {
        'speaker': speakerName,
        'text': text,
        'color': color.name,
        'start_time': startTime?.inMilliseconds,
        'end_time': endTime?.inMilliseconds,
      };
}

/// Speaker color enum with high-contrast accessibility colors
enum SpeakerColor {
  neonBlue(0xFF00D4FF),   // Speaker 1 - Cyan/Neon Blue
  sunsetOrange(0xFFFF6B35), // Speaker 2 - Orange
  limeGreen(0xFF39FF14),    // Speaker 3 - Lime
  hotPink(0xFFFF1493),      // Speaker 4 - Pink
  gold(0xFFFFD700);         // Speaker 5 - Gold

  final int value;
  const SpeakerColor(this.value);

  /// Get color for a speaker number (cycles for >5 speakers)
  static SpeakerColor forSpeaker(int speakerNumber) {
    return SpeakerColor.values[speakerNumber % SpeakerColor.values.length];
  }
}
