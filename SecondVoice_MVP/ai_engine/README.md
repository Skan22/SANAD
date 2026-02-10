# Second Voice - AI Engine (Prototyping)

This directory contains the original Python prototyping and research for the Second Voice AI engine. While the final application uses a Flutter-integrated Vosk implementation for performance and privacy, these scripts served as the foundation for the diarization logic and model validation.

## 📁 Key Components

- `diarizer.py`: Contains the logic for detecting speaker changes based on timing and voice activity.
- `transcribe_demo.py`: A CLI tool for testing Vosk transcription and diarization on `.wav` files.
- `models/`: Original model files used during research.

## 🛠️ Usage (Prototyping Only)

1. **Install Dependencies:**
   ```bash
   pip install -r requirements.txt
   ```
2. **Run Transcription Demo:**
   ```bash
   python transcribe_demo.py path/to/your/audio.wav
   ```

## 🧪 Requirements
- Python 3.8+
- [Vosk](https://github.com/alphacep/vosk-api)
- SoundFile / NumPy
