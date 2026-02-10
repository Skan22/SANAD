import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Animated recording button with pulsing glow effect
class RecordingButton extends StatefulWidget {
  final bool isListening;
  final VoidCallback onPressed;

  const RecordingButton({
    super.key,
    required this.isListening,
    required this.onPressed,
  });

  @override
  State<RecordingButton> createState() => _RecordingButtonState();
}

class _RecordingButtonState extends State<RecordingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(covariant RecordingButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isListening && !oldWidget.isListening) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isListening && oldWidget.isListening) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final buttonColor = widget.isListening ? AppColors.recording : primaryColor;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final pulseScale = widget.isListening ? 1.0 + _pulseAnimation.value * 0.15 : 1.0;
        final glowRadius = widget.isListening ? 15.0 + _pulseAnimation.value * 20.0 : 15.0;
        final spreadRadius = widget.isListening ? _pulseAnimation.value * 8.0 : 0.0;

        return GestureDetector(
          onTap: widget.onPressed,
          child: Transform.scale(
            scale: pulseScale,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: buttonColor,
                boxShadow: [
                  BoxShadow(
                    color: buttonColor.withAlpha((0.4 * 255).round()),
                    blurRadius: glowRadius,
                    spreadRadius: spreadRadius,
                  ),
                ],
              ),
              child: Icon(
                widget.isListening ? Icons.stop : Icons.mic,
                size: 40,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}
