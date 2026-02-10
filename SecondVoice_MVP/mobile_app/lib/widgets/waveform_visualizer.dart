import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/conversation_provider.dart';
import '../theme/app_colors.dart';

/// A simple real-time waveform visualizer that reacts to audio amplitude.
class WaveformVisualizer extends StatelessWidget {
  const WaveformVisualizer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ConversationProvider>(
      builder: (context, provider, child) {
        if (!provider.isListening) {
          return const SizedBox(height: 40);
        }

        return Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              15,
              (index) => _WaveBar(
                amplitude: provider.currentAmplitude,
                index: index,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _WaveBar extends StatelessWidget {
  final double amplitude;
  final int index;

  const _WaveBar({
    required this.amplitude,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    // Add some variation based on index
    final variation = (index - 7).abs() / 10.0;
    final scale = (amplitude - variation).clamp(0.1, 1.0);
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 50),
      margin: const EdgeInsets.symmetric(horizontal: 2),
      width: 4,
      height: 10 + (scale * 40),
      decoration: BoxDecoration(
        color: AppColors.neonBlue.withOpacity(0.5 + (scale * 0.5)),
        borderRadius: BorderRadius.circular(2),
        boxShadow: [
          if (scale > 0.5)
            BoxShadow(
              color: AppColors.neonBlue.withOpacity(0.3),
              blurRadius: 4,
              spreadRadius: 1,
            ),
        ],
      ),
    );
  }
}
