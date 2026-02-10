import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/conversation_provider.dart';
import '../theme/app_colors.dart';

/// Settings panel with text size slider and haptic toggle
class SettingsPanel extends StatelessWidget {
  const SettingsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ConversationProvider>(
      builder: (context, provider, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(
              bottom: BorderSide(color: AppColors.surfaceBorder),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Text size row
              Row(
                children: [
                  const Icon(Icons.text_fields, size: 20, color: AppColors.textSecondary),
                  const SizedBox(width: 12),
                  Text(
                    'Text Size',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: provider.fontSize * 0.6,
                    ),
                  ),
                  Expanded(
                    child: Slider(
                      value: provider.fontSize,
                      min: 20,
                      max: 40,
                      divisions: 4,
                      label: '${provider.fontSize.round()}pt',
                      onChanged: (value) => provider.setFontSize(value),
                    ),
                  ),
                  Text(
                    '${provider.fontSize.round()}pt',
                    style: TextStyle(
                      color: AppColors.neonBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: provider.fontSize * 0.6,
                    ),
                  ),
                ],
              ),

              // Haptic toggle row
              Row(
                children: [
                  const Icon(Icons.vibration, size: 20, color: AppColors.textSecondary),
                  const SizedBox(width: 12),
                  Text(
                    'Haptic Feedback',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: provider.fontSize * 0.6,
                    ),
                  ),
                  const Spacer(),
                  Switch(
                    value: provider.hapticEnabled,
                    onChanged: (value) => provider.setHapticEnabled(value),
                    activeTrackColor: AppColors.neonBlue.withAlpha(128),
                    activeThumbColor: AppColors.neonBlue,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
