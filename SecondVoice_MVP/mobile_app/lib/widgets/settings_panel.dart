import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/conversation_provider.dart';
import '../theme/app_colors.dart';

/// Settings panel with text size slider and haptic toggle
class SettingsPanel extends StatefulWidget {
  const SettingsPanel({super.key});

  @override
  State<SettingsPanel> createState() => _SettingsPanelState();
}

class _SettingsPanelState extends State<SettingsPanel> {
  late TextEditingController _apiKeyController;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<ConversationProvider>(context, listen: false);
    _apiKeyController = TextEditingController(text: provider.geminiApiKey);
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ConversationProvider>(
      builder: (context, provider, _) {
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: SingleChildScrollView(
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

                const SizedBox(height: 16),

                // Speaker Count Row
                Row(
                  children: [
                    const Icon(Icons.groups, size: 20, color: AppColors.textSecondary),
                    const SizedBox(width: 12),
                    Text(
                      'Participants',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: provider.fontSize * 0.6,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceBorder,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [2, 3, 4, 5].map((count) {
                          final isSelected = provider.maxParticipants == count;
                          return GestureDetector(
                            onTap: () => provider.setMaxParticipants(count),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.neonBlue : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                count.toString(),
                                style: TextStyle(
                                  color: isSelected ? Colors.black : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
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

                // Gemini AI toggle
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, size: 20, color: AppColors.neonBlue),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gemini AI (Cloud)',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: provider.fontSize * 0.6,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Higher accuracy, requires internet',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: provider.fontSize * 0.45,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Switch(
                      value: provider.isGeminiEnabled,
                      onChanged: (value) {
                        provider.setEngine(value ? TranscriptionEngine.gemini : TranscriptionEngine.vosk);
                      },
                      activeTrackColor: AppColors.neonBlue.withAlpha(128),
                      activeThumbColor: AppColors.neonBlue,
                    ),
                  ],
                ),

                if (provider.isGeminiEnabled) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: _apiKeyController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Enter Google AI API Key',
                      hintStyle: const TextStyle(color: AppColors.textTertiary),
                      filled: true,
                      fillColor: AppColors.surfaceBorder.withOpacity(0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.surfaceBorder),
                      ),
                      prefixIcon: const Icon(Icons.key, size: 18, color: AppColors.textSecondary),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onChanged: (val) => provider.setGeminiApiKey(val),
                  ),
                ],

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
          ),
        );
      },
    );
  }
}

