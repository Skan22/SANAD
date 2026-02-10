import 'package:flutter/foundation.dart';
import 'package:vibration/vibration.dart';

/// Centralized haptic feedback service
/// Single source of truth for all vibration patterns
class HapticService {
  HapticService._();

  static bool _enabled = true;

  static bool get enabled => _enabled;

  static void setEnabled(bool value) {
    _enabled = value;
  }

  /// Short pulse when a new speaker is detected
  static Future<void> onSpeakerChange() async {
    if (!_enabled) return;
    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        Vibration.vibrate(duration: 100, amplitude: 128);
      }
    } catch (e) {
      debugPrint('HapticService error: $e');
    }
  }

  /// Confirmation pulse when recording starts
  static Future<void> onListeningStart() async {
    if (!_enabled) return;
    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        Vibration.vibrate(duration: 50, amplitude: 200);
      }
    } catch (e) {
      debugPrint('HapticService error: $e');
    }
  }
}
