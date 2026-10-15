import 'package:flutter/material.dart';

import '../levels/level_catalog.dart';
import '../services/progression_service.dart';
import '../theme/app_theme.dart';

/// Level Map Screen matching Stitch Screen 3.
///
/// Features:
/// - Orb Lab Sector Progression Header card with progress bar.
/// - S-curve winding trail with Level Nodes for all available levels.
/// - Current Active Level glowing node with Play pulse.
/// - Bottom sticky "PLAY LEVEL" action bar.
class LevelMapScreen extends StatelessWidget {
  final int? currentLevel;
  final ValueChanged<int>? onSelectLevel;

  const LevelMapScreen({super.key, this.currentLevel, this.onSelectLevel});

  @override
  Widget build(BuildContext context) {
    final totalLevels = LevelCatalog.totalLevels;
    final activeLevel =
        (currentLevel ?? ProgressionService.instance.currentLevel)
            .clamp(1, totalLevels)
            .toInt();
    final highestUnlocked = ProgressionService.instance.highestUnlockedLevel;
    final completedCount = (highestUnlocked - 1).clamp(0, totalLevels);
    final progressFactor = totalLevels > 0
        ? (completedCount / totalLevels)
        : 0.0;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10.0,
              ),
              color: AppTheme.surface.withAlpha(220),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primaryContainer,
                        ),
                        child: const Icon(
                          Icons.bubble_chart,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Orb Lab',
                            style: TextStyle(
                              color: AppTheme.onSurface,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Sectors',
                            style: TextStyle(
                              color: AppTheme.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _StatChip(
                        icon: Icons.track_changes,
                        iconColor: AppTheme.primary,
                        text: 'LV.$activeLevel',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Sector Header Card
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainerHigh.withAlpha(220),
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(80),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryContainer
                                              .withAlpha(100),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: const Text(
                                          'ORB LAB',
                                          style: TextStyle(
                                            color: AppTheme.primary,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '✨ ${(progressFactor * 100).toInt()}% Done',
                                        style: const TextStyle(
                                          color: AppTheme.secondary,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Quantum Sectors',
                                    style: TextStyle(
                                      color: AppTheme.onSurface,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Text(
                                    'Harmonic plasma containment grid',
                                    style: TextStyle(
                                      color: AppTheme.onSurfaceVariant,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Progress Bar
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Containment Progress',
                                style: TextStyle(
                                  color: AppTheme.onSurfaceVariant,
                                  fontSize: 11,
                                ),
                              ),
                              Text(
                                '$completedCount / $totalLevels Levels',
                                style: const TextStyle(
                                  color: AppTheme.primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              height: 6,
                              color: AppTheme.surfaceContainerLowest,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: FractionallySizedBox(
                                  widthFactor: progressFactor,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppTheme.primaryContainer,
                                          AppTheme.primary,
                                          AppTheme.tertiary,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Level Path Map (Custom S-Curve Visual Layout)
                    _LevelMapTrail(
                      currentLevel: activeLevel,
                      onSelectLevel: onSelectLevel,
                    ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // Sticky bottom play bar
      bottomSheet: Container(
        color: AppTheme.surface,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () => onSelectLevel?.call(activeLevel),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.secondaryContainer,
              foregroundColor: AppTheme.onSecondaryContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26.0),
              ),
              elevation: 8,
              shadowColor: AppTheme.secondaryContainer.withAlpha(180),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.play_arrow_rounded, size: 24),
                const SizedBox(width: 8),
                Text(
                  'PLAY LEVEL $activeLevel',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData? icon;
  final Color? iconColor;
  final String text;

  const _StatChip({this.icon, this.iconColor, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerHigh.withAlpha(220),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: iconColor, size: 12),
            const SizedBox(width: 3),
          ],
          Text(
            text,
            style: const TextStyle(
              color: AppTheme.onSurface,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelMapTrail extends StatelessWidget {
  final int currentLevel;
  final ValueChanged<int>? onSelectLevel;

  const _LevelMapTrail({required this.currentLevel, this.onSelectLevel});

  static const _sectorNames = [
    'Training Protocols',
    'Intermediate Containment',
    'Advanced Plasma Routing',
    'Quantum Isolation',
    'Entropy Calibration',
    'Resonance Flux',
    'Subatomic Synthesis',
    'Magnetic Chambering',
    'Superposition Routing',
    'Singularity Isolation',
  ];

  static String _getSectorName(int sector) {
    if (sector >= 1 && sector <= _sectorNames.length) {
      return _sectorNames[sector - 1];
    }
    return 'Sector $sector';
  }

  @override
  Widget build(BuildContext context) {
    final highestUnlocked = ProgressionService.instance.highestUnlockedLevel;
    final offsets = [0.0, 50.0, -45.0, 60.0, 0.0, -55.0, 45.0, -50.0];

    return Column(
      children: [
        for (int lvl = LevelCatalog.totalLevels; lvl >= 1; lvl--) ...[
          if (lvl % 5 == 0)
            _SectorBanner(
              sectorNumber: lvl ~/ 5,
              title: _getSectorName(lvl ~/ 5),
            ),
          _MapNode(
            level: lvl,
            label: lvl == LevelCatalog.totalLevels
                ? 'SINGULARITY PINNACLE'
                : (lvl % 5 == 0 ? 'SECTOR ${lvl ~/ 5} BOSS' : null),
            isBoss: lvl % 5 == 0,
            isActive: lvl == currentLevel,
            isCompleted: lvl < highestUnlocked,
            isLocked: lvl > highestUnlocked,
            stars: ProgressionService.instance.getStars(lvl),
            offsetX: offsets[lvl % offsets.length],
            onTap: () => onSelectLevel?.call(lvl),
          ),
          const SizedBox(height: 24),
        ],
      ],
    );
  }
}

class _SectorBanner extends StatelessWidget {
  final int sectorNumber;
  final String title;

  const _SectorBanner({required this.sectorNumber, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20, bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerHigh.withAlpha(200),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primary.withAlpha(80),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(60),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.primaryContainer.withAlpha(120),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'SECTOR $sectorNumber',
              style: const TextStyle(
                color: AppTheme.primary,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.onSurface,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _MapNode extends StatelessWidget {
  final int level;
  final String? label;
  final bool isCompleted;
  final bool isActive;
  final bool isLocked;
  final bool isBoss;
  final int stars;
  final double offsetX;
  final VoidCallback? onTap;

  const _MapNode({
    required this.level,
    this.label,
    this.isCompleted = false,
    this.isActive = false,
    this.isLocked = false,
    this.isBoss = false,
    this.stars = 0,
    required this.offsetX,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(offsetX, 0),
      child: Column(
        children: [
          if (label != null)
            Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isBoss
                    ? AppTheme.errorContainer
                    : AppTheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                label!,
                style: TextStyle(
                  color: isBoss
                      ? AppTheme.onErrorContainer
                      : AppTheme.secondary,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          GestureDetector(
            onTap: isLocked ? null : onTap,
            child: Container(
              width: isActive ? 68 : 52,
              height: isActive ? 68 : 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isActive
                    ? const RadialGradient(
                        colors: [AppTheme.primary, AppTheme.primaryContainer],
                      )
                    : (isBoss
                          ? const RadialGradient(
                              colors: [AppTheme.error, AppTheme.errorContainer],
                            )
                          : null),
                color: isCompleted
                    ? AppTheme.surfaceContainerHighest
                    : (isLocked
                          ? AppTheme.surfaceContainerHigh.withAlpha(120)
                          : AppTheme.surfaceContainerHigh),
                boxShadow: [
                  if (isActive)
                    BoxShadow(
                      color: AppTheme.primaryContainer.withAlpha(160),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  if (isBoss)
                    BoxShadow(
                      color: AppTheme.errorContainer.withAlpha(150),
                      blurRadius: 16,
                    ),
                ],
                border: Border.all(
                  color: isActive
                      ? Colors.white.withAlpha(180)
                      : (isBoss ? AppTheme.error : Colors.white.withAlpha(30)),
                  width: isActive ? 2 : 1,
                ),
              ),
              child: Center(
                child: isLocked
                    ? const Icon(Icons.lock, color: AppTheme.outline, size: 20)
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$level',
                            style: TextStyle(
                              color: isLocked
                                  ? AppTheme.outline
                                  : (isActive
                                        ? Colors.white
                                        : AppTheme.onSurface),
                              fontSize: isActive ? 18 : 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (isActive)
                            const Text(
                              'PLAY',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
              ),
            ),
          ),
          if (stars > 0)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  stars,
                  (index) => const Icon(
                    Icons.star,
                    color: AppTheme.secondary,
                    size: 11,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
