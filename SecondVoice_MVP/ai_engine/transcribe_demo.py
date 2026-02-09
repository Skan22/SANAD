"""
Transcribe Demo - Offline Speech-to-Text using Vosk
====================================================
A demonstration script for transcribing audio files using the Vosk
offline speech recognition toolkit.

Requirements:
- vosk model: Download vosk-model-small-en-us-0.15 from:
  https://alphacephei.com/vosk/models
- Place model folder in ./models/

Usage:
    python transcribe_demo.py <audio_file.wav>
    python transcribe_demo.py --demo  # Run with simulated output
"""

import os
import sys
import json
import wave
from pathlib import Path
from typing import List, Optional, Generator
from dataclasses import dataclass

try:
    from vosk import Model, KaldiRecognizer, SetLogLevel
    VOSK_AVAILABLE = True
except ImportError:
    VOSK_AVAILABLE = False
    print("Warning: vosk not installed. Run: pip install vosk")

from diarizer import Diarizer, DialogueSegment


@dataclass
class TranscriptionResult:
    """Result of transcription with timing info"""
    text: str
    start_time: float
    end_time: float
    confidence: Optional[float] = None
    words: Optional[List[dict]] = None

    def to_dict(self) -> dict:
        return {
            "text": self.text,
            "start_time": self.start_time,
            "end_time": self.end_time,
            "confidence": self.confidence
        }


class VoskTranscriber:
    """
    Offline speech-to-text transcriber using Vosk.
    
    Supports:
    - WAV file transcription
    - Streaming audio transcription
    - Word-level timing information
    """

    DEFAULT_MODEL_PATH = "models/vosk-model-small-en-us-0.15"

    def __init__(self, model_path: Optional[str] = None, sample_rate: int = 16000):
        """
        Initialize the transcriber.
        
        Args:
            model_path: Path to Vosk model directory
            sample_rate: Audio sample rate (default 16000 Hz)
        """
        self.sample_rate = sample_rate
        self.model = None
        self.recognizer = None

        if not VOSK_AVAILABLE:
            print("Vosk not available - running in demo mode")
            return

        # Suppress Vosk logs
        SetLogLevel(-1)

        # Find model path
        model_path = model_path or self.DEFAULT_MODEL_PATH
        script_dir = Path(__file__).parent
        full_model_path = script_dir / model_path

        if not full_model_path.exists():
            print(f"Model not found at: {full_model_path}")
            print("Download from: https://alphacephei.com/vosk/models")
            print("Extract to: models/vosk-model-small-en-us-0.15")
            return

        # Load model
        print(f"Loading Vosk model from: {full_model_path}")
        self.model = Model(str(full_model_path))
        self._init_recognizer()

    def _init_recognizer(self):
        """Initialize or reset the recognizer"""
        if self.model:
            self.recognizer = KaldiRecognizer(self.model, self.sample_rate)
            self.recognizer.SetWords(True)  # Enable word-level timing

    def transcribe_file(self, audio_path: str) -> List[TranscriptionResult]:
        """
        Transcribe a WAV audio file.
        
        Args:
            audio_path: Path to WAV file (must be 16kHz mono)
            
        Returns:
            List of TranscriptionResult objects
        """
        if not self.model:
            return self._demo_transcription()

        results = []
        self._init_recognizer()

        with wave.open(audio_path, "rb") as wf:
            # Validate audio format
            if wf.getnchannels() != 1 or wf.getsampwidth() != 2 or wf.getframerate() != self.sample_rate:
                print(f"Warning: Audio should be {self.sample_rate}Hz mono PCM")

            # Process in chunks
            while True:
                data = wf.readframes(4000)  # ~0.25s at 16kHz
                if len(data) == 0:
                    break

                if self.recognizer.AcceptWaveform(data):
                    result = json.loads(self.recognizer.Result())
                    if result.get('text'):
                        results.append(self._parse_result(result))

            # Get final result
            final = json.loads(self.recognizer.FinalResult())
            if final.get('text'):
                results.append(self._parse_result(final))

        return results

    def process_chunk(self, audio_data: bytes) -> Optional[TranscriptionResult]:
        """
        Process a chunk of audio data for streaming transcription.
        
        Args:
            audio_data: Raw PCM audio bytes
            
        Returns:
            TranscriptionResult if a complete utterance was recognized
        """
        if not self.model:
            return None

        if self.recognizer.AcceptWaveform(audio_data):
            result = json.loads(self.recognizer.Result())
            if result.get('text'):
                return self._parse_result(result)
        return None

    def get_partial(self) -> Optional[str]:
        """Get partial transcription result"""
        if not self.recognizer:
            return None
        partial = json.loads(self.recognizer.PartialResult())
        return partial.get('partial', '')

    def _parse_result(self, result: dict) -> TranscriptionResult:
        """Parse Vosk result into TranscriptionResult"""
        words = result.get('result', [])
        
        if words:
            start_time = words[0].get('start', 0.0)
            end_time = words[-1].get('end', start_time)
            # Average confidence
            confidences = [w.get('conf', 1.0) for w in words]
            avg_confidence = sum(confidences) / len(confidences) if confidences else None
        else:
            start_time = 0.0
            end_time = 0.0
            avg_confidence = None

        return TranscriptionResult(
            text=result.get('text', ''),
            start_time=start_time,
            end_time=end_time,
            confidence=avg_confidence,
            words=words
        )

    def _demo_transcription(self) -> List[TranscriptionResult]:
        """Return demo transcription when model not available"""
        return [
            TranscriptionResult(
                text="Hello, how are you today?",
                start_time=0.0,
                end_time=1.2,
                confidence=0.95
            ),
            TranscriptionResult(
                text="I'm doing great, thanks for asking!",
                start_time=2.0,
                end_time=3.6,
                confidence=0.92
            ),
            TranscriptionResult(
                text="That's wonderful to hear.",
                start_time=4.5,
                end_time=5.5,
                confidence=0.88
            )
        ]


def transcribe_with_diarization(audio_path: str, pause_threshold: float = 0.5) -> List[dict]:
    """
    Transcribe audio file with speaker diarization.
    
    Args:
        audio_path: Path to WAV audio file
        pause_threshold: Pause duration to trigger speaker change
        
    Returns:
        List of dialogue segments with speaker info
    """
    transcriber = VoskTranscriber()
    diarizer = Diarizer(pause_threshold=pause_threshold)

    # Transcribe
    results = transcriber.transcribe_file(audio_path)

    # Add diarization
    for result in results:
        diarizer.process_result(result.text, result.start_time, result.end_time)

    return diarizer.get_all_segments()


def main():
    """CLI entry point"""
    if len(sys.argv) < 2:
        print(__doc__)
        print("\nRunning demo mode...\n")
        demo_mode = True
    else:
        demo_mode = sys.argv[1] == "--demo"
        audio_path = None if demo_mode else sys.argv[1]

    if demo_mode:
        # Run with simulated output
        transcriber = VoskTranscriber()
        diarizer = Diarizer()

        print("=== Second Voice - Transcription Demo ===\n")
        
        demo_results = transcriber._demo_transcription()
        for result in demo_results:
            segment = diarizer.process_result(result.text, result.start_time, result.end_time)
            print(f"[{segment.speaker_name}] ({segment.color}): {segment.text}")
            print(f"  Time: {segment.start_time:.2f}s - {segment.end_time:.2f}s\n")

        print("\n=== JSON Output ===")
        print(json.dumps(diarizer.get_all_segments(), indent=2))

    else:
        # Process actual audio file
        if not os.path.exists(audio_path):
            print(f"Error: File not found: {audio_path}")
            sys.exit(1)

        print(f"Transcribing: {audio_path}")
        segments = transcribe_with_diarization(audio_path)

        print("\n=== Transcription with Speaker Diarization ===\n")
        for seg in segments:
            print(f"[{seg['speaker']}] ({seg['color']}): {seg['text']}")
            print(f"  Time: {seg['start_time']:.2f}s - {seg['end_time']:.2f}s\n")

        print("\n=== JSON Output ===")
        print(json.dumps(segments, indent=2))


if __name__ == "__main__":
    main()
