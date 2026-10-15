import 'package:flutter/material.dart';

import '../services/audio_haptic_service.dart';
import '../services/progression_service.dart';
import '../theme/game_theme.dart';

/// Reusable Orb Lab Settings Sheet / Modal.
///
/// Features:
/// - Persistent Sound FX & Haptic Vibration toggles.
/// - Clear, honest documentation of auditory click system.
/// - Reserved, non-misleading vision & accessibility preview.
/// - Diagnostic build & version specs.
/// - Accessible touch targets with min 48dp hitboxes.
class SettingsSheet extends StatefulWidget {
  const SettingsSheet({super.key});

  /// Displays the settings sheet as a modal bottom sheet.
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SettingsSheet(),
    );
  }

  @override
  State<SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<SettingsSheet> {
  late bool _soundEnabled;
  late bool _hapticsEnabled;

  @override
  void initState() {
    super.initState();
    _soundEnabled = ProgressionService.instance.soundEnabled;
    _hapticsEnabled = ProgressionService.instance.hapticsEnabled;
  }

  Future<void> _toggleSound(bool value) async {
    setState(() => _soundEnabled = value);
    await ProgressionService.instance.setSoundEnabled(value);
    if (value) {
      AudioHapticService.instance.playSelect();
    }
  }

  Future<void> _toggleHaptics(bool value) async {
    setState(() => _hapticsEnabled = value);
    await ProgressionService.instance.setHapticsEnabled(value);
    if (value) {
      AudioHapticService.instance.playSelect();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      decoration: BoxDecoration(
        color: GameTheme.surfaceElevated,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: GameTheme.cyanAccent.withAlpha(80),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(180),
            blurRadius: 32,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Drag Pill
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: GameTheme.textTertiary.withAlpha(100),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Title Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: GameTheme.cyanAccent.withAlpha(35),
                          border: Border.all(
                            color: GameTheme.cyanAccent.withAlpha(90),
                          ),
                        ),
                        child: const Icon(
                          Icons.settings_outlined,
                          color: GameTheme.cyanAccent,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'LAB SETTINGS',
                            style: TextStyle(
                              color: GameTheme.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Text(
                            'PREFERENCES & CALIBRATION',
                            style: TextStyle(
                              color: GameTheme.cyanAccent,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    key: const Key('settings_close_button'),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: GameTheme.textSecondary,
                      size: 22,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),

              const SizedBox(height: 18),
              const Divider(color: Color(0x2249DCEC), height: 1),
              const SizedBox(height: 16),

              // 1. Sensory Controls Section
              _buildSectionHeader('SENSORY FEEDBACK'),
              const SizedBox(height: 10),

              // Sound Toggle Card
              _buildSettingCard(
                icon: _soundEnabled
                    ? Icons.volume_up_rounded
                    : Icons.volume_off_rounded,
                iconColor: GameTheme.cyanAccent,
                title: 'Auditory Clicks (Sound FX)',
                subtitle:
                    'System click sounds on orb transfers & completion (requires device touch sound enabled)',
                trailing: Switch(
                  key: const Key('sound_toggle_switch'),
                  value: _soundEnabled,
                  onChanged: _toggleSound,
                  activeThumbColor: GameTheme.cyanAccent,
                  activeTrackColor: GameTheme.cyanAccent.withAlpha(100),
                  inactiveThumbColor: GameTheme.textTertiary,
                  inactiveTrackColor: GameTheme.background,
                ),
              ),

              const SizedBox(height: 10),

              // Haptic Toggle Card
              _buildSettingCard(
                icon: _hapticsEnabled
                    ? Icons.vibration_rounded
                    : Icons.mobile_off_rounded,
                iconColor: GameTheme.violetAccent,
                title: 'Haptic Feedback (Vibration)',
                subtitle:
                    'Tactile pulse on selection, transfer landings & chamber stabilization',
                trailing: Switch(
                  key: const Key('haptic_toggle_switch'),
                  value: _hapticsEnabled,
                  onChanged: _toggleHaptics,
                  activeThumbColor: GameTheme.violetAccent,
                  activeTrackColor: GameTheme.violetAccent.withAlpha(100),
                  inactiveThumbColor: GameTheme.textTertiary,
                  inactiveTrackColor: GameTheme.background,
                ),
              ),

              const SizedBox(height: 20),

              // 2. Vision & Accessibility Area (Prepared for M3D)
              _buildSectionHeader('VISION & ACCESSIBILITY'),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: GameTheme.surfaceDim.withAlpha(200),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: GameTheme.cyanAccent.withAlpha(40),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: GameTheme.cyanAccent.withAlpha(25),
                      ),
                      child: const Icon(
                        Icons.remove_red_eye_outlined,
                        color: GameTheme.cyanAccent,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Color-Blind Glyphs',
                                style: TextStyle(
                                  color: GameTheme.textPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: GameTheme.cyanAccent.withAlpha(30),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'PLANNED: M3D',
                                  style: TextStyle(
                                    color: GameTheme.cyanAccent,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Geometric runes on orbs and high-contrast accessibility modes are scheduled for Milestone 3D.',
                            style: TextStyle(
                              color: GameTheme.textTertiary,
                              fontSize: 11,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 3. System Information / About
              _buildSectionHeader('ABOUT ORB LAB'),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: GameTheme.surfaceDim.withAlpha(200),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: GameTheme.textTertiary.withAlpha(40),
                  ),
                ),
                child: Column(
                  children: [
                    _buildInfoRow('Game Title', 'Orb Lab: Quantum Sort'),
                    const SizedBox(height: 6),
                    _buildInfoRow('Version', '1.0.0+1'),
                    const SizedBox(height: 6),
                    _buildInfoRow('Campaign Scope', '50 Solver-Verified Sectors'),
                    const SizedBox(height: 6),
                    _buildInfoRow('Solver Architecture', 'Multi-Isolate Bounded Search'),
                    const SizedBox(height: 6),
                    _buildInfoRow('Monetization Model', '100% Free • Pure Offline Casual'),
                  ],
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: GameTheme.textTertiary,
        fontSize: 10,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: GameTheme.surfaceDim.withAlpha(200),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: iconColor.withAlpha(50),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconColor.withAlpha(25),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: GameTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: GameTheme.textSecondary,
                    fontSize: 11,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          trailing,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: GameTheme.textTertiary,
            fontSize: 11,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: GameTheme.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
