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
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              const Text(
                'Settings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
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

              const Divider(color: AppColors.surfaceBorder, height: 24),

              // Language & Sensitivity Section
              Row(
                children: [
                   const Icon(Icons.language, size: 20, color: AppColors.textSecondary),
                   const SizedBox(width: 12),
                   Expanded(
                     child: DropdownButton<String>(
                        value: provider.currentModelPath,
                        isExpanded: true,
                        dropdownColor: AppColors.surface,
                        underline: const SizedBox(),
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        items: const [
                          DropdownMenuItem(
                            value: 'assets/models/vosk-model-small-en-us-0.15.zip',
                            child: Text('English (US)'),
                          ),
                          DropdownMenuItem(
                            value: 'assets/models/vosk-model-small-ar-tn-0.1-linto.zip',
                            child: Text('Arabic (TN)'),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) provider.setModel(val);
                        },
                     ),
                   ),
                ],
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  const Icon(Icons.speed, size: 20, color: AppColors.textSecondary),
                  const SizedBox(width: 12),
                  Text(
                    'Sensitivity',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: provider.fontSize * 0.6,
                    ),
                  ),
                  Expanded(
                    child: Slider(
                      value: provider.pauseThreshold,
                      min: 0.2,
                      max: 2.0,
                      divisions: 9,
                      onChanged: (val) => provider.setPauseThreshold(val),
                    ),
                  ),
                ],
              ),

              const Divider(color: AppColors.surfaceBorder, height: 24),

              // Performance Overlay toggle
              Row(
                children: [
                  const Icon(Icons.analytics_outlined, size: 20, color: AppColors.textSecondary),
                  const SizedBox(width: 12),
                  Text(
                    'Performance Overlay',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: provider.fontSize * 0.6,
                    ),
                  ),
                  const Spacer(),
                  Switch(
                    value: provider.showPerformanceOverlay,
                    onChanged: (value) => provider.setPerformanceOverlayEnabled(value),
                    activeTrackColor: AppColors.neonBlue.withAlpha(128),
                    activeThumbColor: AppColors.neonBlue,
                  ),
                ],
              ),

              const Divider(color: AppColors.surfaceBorder, height: 24),

              // Demo Mode toggle
              Row(
                children: [
                   const Icon(Icons.bug_report_outlined, size: 20, color: AppColors.textSecondary),
                   const SizedBox(width: 12),
                   Text(
                    'Demo Mode (Simulation)',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: provider.fontSize * 0.6,
                    ),
                  ),
                  const Spacer(),
                  Switch(
                    value: provider.demoMode,
                    onChanged: (value) => provider.setDemoMode(value),
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
