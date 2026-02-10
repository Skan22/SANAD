"""
Second Voice AI Engine
======================
Offline speech-to-text transcription and speaker diarization.
"""

from .diarizer import Diarizer, DialogueSegment, SpeakerColor, diarize_results

__all__ = [
    "Diarizer",
    "DialogueSegment",
    "SpeakerColor",
    "diarize_results",
]
