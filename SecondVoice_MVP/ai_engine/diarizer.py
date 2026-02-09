"""
Diarizer - Lightweight Speaker Diarization for Second Voice
============================================================
Assigns speaker IDs based on pause detection and timing heuristics.
No ML required - uses simple pause-based logic for offline efficiency.
"""

from dataclasses import dataclass
from typing import List, Optional
from enum import Enum


class SpeakerColor(Enum):
    """High-contrast accessibility colors for speaker identification"""
    NEON_BLUE = "#00D4FF"
    SUNSET_ORANGE = "#FF6B35"
    LIME_GREEN = "#39FF14"
    HOT_PINK = "#FF1493"
    GOLD = "#FFD700"

    @classmethod
    def for_speaker(cls, speaker_num: int) -> 'SpeakerColor':
        """Get color for speaker number (cycles for >5 speakers)"""
        colors = list(cls)
        return colors[speaker_num % len(colors)]


@dataclass
class DialogueSegment:
    """A single speaker utterance with timing and speaker info"""
    speaker_id: str
    speaker_name: str
    text: str
    start_time: float  # seconds
    end_time: float    # seconds
    color: str

    def to_dict(self) -> dict:
        """Convert to dictionary for JSON output"""
        return {
            "speaker": self.speaker_name,
            "text": self.text,
            "color": self.color,
            "start_time": self.start_time,
            "end_time": self.end_time
        }


class Diarizer:
    """
    Lightweight speaker diarization using pause-based heuristics.
    
    Logic:
    - If pause between words > pause_threshold: assume new speaker
    - Alternates between speakers when pause detected
    - No ML required - runs efficiently offline
    """

    def __init__(self, pause_threshold: float = 0.5, max_speakers: int = 5):
        """
        Initialize the diarizer.
        
        Args:
            pause_threshold: Minimum pause duration (seconds) to trigger speaker change
            max_speakers: Maximum number of distinct speakers to track
        """
        self.pause_threshold = pause_threshold
        self.max_speakers = max_speakers
        self.current_speaker = 0
        self.segments: List[DialogueSegment] = []
        self.last_end_time: Optional[float] = None

    def process_result(self, text: str, start_time: float, end_time: float) -> DialogueSegment:
        """
        Process a transcription result and assign speaker ID.
        
        Args:
            text: Transcribed text
            start_time: Start time in seconds
            end_time: End time in seconds
            
        Returns:
            DialogueSegment with assigned speaker
        """
        # Check if we should switch speakers based on pause
        if self.last_end_time is not None:
            pause_duration = start_time - self.last_end_time
            if pause_duration > self.pause_threshold:
                # Switch to next speaker (cycling through available speakers)
                self.current_speaker = (self.current_speaker + 1) % self.max_speakers

        self.last_end_time = end_time

        # Create segment with speaker info
        speaker_color = SpeakerColor.for_speaker(self.current_speaker)
        segment = DialogueSegment(
            speaker_id=f"speaker_{self.current_speaker}",
            speaker_name=f"Speaker {self.current_speaker + 1}",
            text=text,
            start_time=start_time,
            end_time=end_time,
            color=speaker_color.value
        )

        self.segments.append(segment)
        return segment

    def process_vosk_result(self, result: dict) -> Optional[DialogueSegment]:
        """
        Process a Vosk result JSON object.
        
        Args:
            result: Vosk result dict with 'text', 'result' (word timings)
            
        Returns:
            DialogueSegment if text present, None otherwise
        """
        text = result.get('text', '').strip()
        if not text:
            return None

        # Extract timing from word-level results
        words = result.get('result', [])
        if words:
            start_time = words[0].get('start', 0.0)
            end_time = words[-1].get('end', start_time)
        else:
            # Fallback: estimate from previous segment
            start_time = self.last_end_time or 0.0
            end_time = start_time + len(text) * 0.05  # ~50ms per character estimate

        return self.process_result(text, start_time, end_time)

    def get_all_segments(self) -> List[dict]:
        """Return all segments as JSON-serializable list"""
        return [seg.to_dict() for seg in self.segments]

    def reset(self):
        """Reset diarizer state for new conversation"""
        self.current_speaker = 0
        self.segments.clear()
        self.last_end_time = None


# Convenience function for quick testing
def diarize_results(results: List[dict], pause_threshold: float = 0.5) -> List[dict]:
    """
    Process a list of Vosk results with diarization.
    
    Args:
        results: List of Vosk result dicts
        pause_threshold: Pause duration to trigger speaker change
        
    Returns:
        List of dialogue segment dicts with speaker info
    """
    diarizer = Diarizer(pause_threshold=pause_threshold)
    for result in results:
        diarizer.process_vosk_result(result)
    return diarizer.get_all_segments()


if __name__ == "__main__":
    # Demo with simulated results
    demo_results = [
        {"text": "Hello, how are you today?", "result": [
            {"word": "Hello", "start": 0.0, "end": 0.3},
            {"word": "how", "start": 0.35, "end": 0.5},
            {"word": "are", "start": 0.55, "end": 0.65},
            {"word": "you", "start": 0.7, "end": 0.85},
            {"word": "today", "start": 0.9, "end": 1.2}
        ]},
        {"text": "I'm doing great, thanks for asking!", "result": [
            {"word": "I'm", "start": 2.0, "end": 2.2},  # 0.8s pause -> new speaker
            {"word": "doing", "start": 2.25, "end": 2.5},
            {"word": "great", "start": 2.55, "end": 2.8},
            {"word": "thanks", "start": 2.9, "end": 3.1},
            {"word": "for", "start": 3.15, "end": 3.25},
            {"word": "asking", "start": 3.3, "end": 3.6}
        ]},
        {"text": "That's wonderful to hear.", "result": [
            {"word": "That's", "start": 4.5, "end": 4.7},  # 0.9s pause -> new speaker
            {"word": "wonderful", "start": 4.75, "end": 5.1},
            {"word": "to", "start": 5.15, "end": 5.25},
            {"word": "hear", "start": 5.3, "end": 5.5}
        ]}
    ]

    print("=== Diarizer Demo ===\n")
    segments = diarize_results(demo_results)
    for seg in segments:
        print(f"[{seg['speaker']}] ({seg['color']}): {seg['text']}")
        print(f"  Time: {seg['start_time']:.2f}s - {seg['end_time']:.2f}s\n")
