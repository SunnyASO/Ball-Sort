import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Level Map Screen matching Stitch Screen 3.
///
/// Features:
/// - Realm 3: "Neon Nebula" Header card with 70% progress bar and Mystery Box timer.
/// - S-curve winding trail with Level Nodes (38, 39, 40, 41, 42 PLAY, 45 HARD PUZZLE, 46, 50 Chapter Pinnacle).
/// - Current Active Level 42 glowing node with Play pulse.
/// - Bottom sticky "Level 42 PLAY" action bar.
class LevelMapScreen extends StatelessWidget {
  final int currentLevel;
  final ValueChanged<int>? onSelectLevel;

  const LevelMapScreen({super.key, this.currentLevel = 42, this.onSelectLevel});

  @override
  Widget build(BuildContext context) {
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
                            'Ball Sort',
                            style: TextStyle(
                              color: AppTheme.onSurface,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Levels',
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
                        icon: Icons.favorite,
                        iconColor: AppTheme.error,
                        text: '5/5 Full',
                      ),
                      const SizedBox(width: 6),
                      _StatChip(
                        icon: Icons.monetization_on,
                        iconColor: AppTheme.secondary,
                        text: '2,450',
                      ),
                      const SizedBox(width: 6),
                      _StatChip(text: 'LV.42', textColor: AppTheme.tertiary),
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
                    // Realm 3 Header Card
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
                                          'REALM 3',
                                          style: TextStyle(
                                            color: AppTheme.primary,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Text(
                                        '✨ 70% Done',
                                        style: TextStyle(
                                          color: AppTheme.secondary,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Neon Nebula',
                                    style: TextStyle(
                                      color: AppTheme.onSurface,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Text(
                                    'Liquid crystal vortexes',
                                    style: TextStyle(
                                      color: AppTheme.onSurfaceVariant,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              // Mystery Box Badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceContainerLowest,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: const [
                                    Icon(
                                      Icons.card_giftcard,
                                      color: AppTheme.secondary,
                                      size: 20,
                                    ),
                                    Text(
                                      'Mystery Box',
                                      style: TextStyle(
                                        color: AppTheme.onSurface,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '03:42:10',
                                      style: TextStyle(
                                        color: AppTheme.tertiary,
                                        fontSize: 9,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Progress Bar
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                'Current Progress',
                                style: TextStyle(
                                  color: AppTheme.onSurfaceVariant,
                                  fontSize: 11,
                                ),
                              ),
                              Text(
                                '35 / 50 Levels',
                                style: TextStyle(
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
                                  widthFactor: 0.70,
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
                      currentLevel: currentLevel,
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
            onPressed: () => onSelectLevel?.call(1),
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
              children: const [
                Icon(Icons.play_arrow_rounded, size: 24),
                SizedBox(width: 8),
                Text(
                  'PLAY LEVEL 1',
                  style: TextStyle(
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
  final Color? textColor;

  const _StatChip({
    this.icon,
    this.iconColor,
    required this.text,
    this.textColor,
  });

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
            style: TextStyle(
              color: textColor ?? AppTheme.onSurface,
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Level 50: Chapter Pinnacle
        _MapNode(
          level: 50,
          label: 'Chapter Pinnacle',
          isLocked: true,
          offsetX: 0,
        ),
        const SizedBox(height: 24),

        // Level 46: Locked
        _MapNode(level: 46, isLocked: true, offsetX: -60),
        const SizedBox(height: 24),

        // Level 45: Hard Puzzle Boss Node
        _MapNode(level: 45, label: 'HARD PUZZLE', isBoss: true, offsetX: 60),
        const SizedBox(height: 24),

        // Level 44: Locked
        _MapNode(level: 44, isLocked: true, offsetX: 0),
        const SizedBox(height: 24),

        // Level 42: Active Level (Glow pulse)
        _MapNode(
          level: 42,
          isActive: true,
          offsetX: -40,
          onTap: () => onSelectLevel?.call(1),
        ),
        const SizedBox(height: 24),

        // Level 41: Completed (3 stars)
        _MapNode(
          level: 41,
          isCompleted: true,
          stars: 3,
          offsetX: 50,
          onTap: () => onSelectLevel?.call(1),
        ),
        const SizedBox(height: 24),

        // Level 40: Completed (3 stars)
        _MapNode(
          level: 40,
          isCompleted: true,
          stars: 3,
          offsetX: 0,
          onTap: () => onSelectLevel?.call(1),
        ),
      ],
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
