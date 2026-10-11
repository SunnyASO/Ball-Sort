import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Victory celebration modal matching Stitch Screen 1 (Level Complete).
///
/// Features:
/// - "Level Complete!" header banner with stars.
/// - 3-Star Mastery rating (Skill, Mastery, Speed) with golden specular glow.
/// - Tactical Efficiency stats cards (Moves, Time, Score).
/// - Spoils Earned (Coins +150, Bonus Crystals +1).
/// - Action buttons: Golden "CLAIM 2X", Replay ("play_again_button"), and Next Level ("next_level_button").
class VictoryOverlay extends StatelessWidget {
  final int levelNumber;
  final int moveCount;
  final bool hasNextLevel;
  final VoidCallback onPlayAgain;
  final VoidCallback onNextLevel;

  const VictoryOverlay({
    super.key,
    required this.levelNumber,
    required this.moveCount,
    required this.hasNextLevel,
    required this.onPlayAgain,
    required this.onNextLevel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('victory_banner'),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer.withAlpha(245),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32.0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(180),
            blurRadius: 40,
            offset: const Offset(0, -10),
          ),
          BoxShadow(
            color: AppTheme.secondary.withAlpha(50),
            blurRadius: 30,
            spreadRadius: 2,
          ),
        ],
        border: Border(
          top: BorderSide(color: AppTheme.secondary.withAlpha(120), width: 1.5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Level Complete Header Pill
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 8.0,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.secondaryContainer, AppTheme.secondary],
              ),
              borderRadius: BorderRadius.circular(24.0),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.secondaryContainer.withAlpha(120),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.military_tech,
                  color: AppTheme.onSecondaryContainer,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  hasNextLevel
                      ? 'Level Completed!'
                      : 'All Prototype Levels Complete!',
                  key: const Key('victory_title'),
                  style: const TextStyle(
                    color: AppTheme.onSecondaryContainer,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.military_tech,
                  color: AppTheme.onSecondaryContainer,
                  size: 20,
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // 2. Three Golden Stars (Skill, Mastery, Speed)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Star 1: Skill
              _StarBadge(
                iconSize: 34,
                label: 'Skill',
                isEarned: true,
                offsetY: 8,
              ),
              const SizedBox(width: 16),
              // Star 2: Mastery (Elevated Center Star)
              _StarBadge(
                iconSize: 48,
                label: 'Mastery',
                isEarned: true,
                isCenter: true,
                offsetY: 0,
              ),
              const SizedBox(width: 16),
              // Star 3: Speed
              _StarBadge(
                iconSize: 34,
                label: 'Speed',
                isEarned: true,
                offsetY: 8,
              ),
            ],
          ),

          const SizedBox(height: 14),

          // 3. Tactical Efficiency Card
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLow.withAlpha(220),
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'TACTICAL EFFICIENCY',
                      style: TextStyle(
                        color: AppTheme.onSurfaceVariant,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.6,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.auto_awesome,
                            color: AppTheme.onPrimaryContainer,
                            size: 11,
                          ),
                          SizedBox(width: 3),
                          Text(
                            'PERFECT',
                            style: TextStyle(
                              color: AppTheme.onPrimaryContainer,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _MetricCard(
                      icon: Icons.swap_horiz,
                      title: 'Moves',
                      value: '$moveCount',
                      subtitle: 'Solved in $moveCount moves',
                    ),
                    const SizedBox(width: 8),
                    _MetricCard(
                      icon: Icons.timer,
                      title: 'Time',
                      value: '00:48',
                      subtitle: '+12s Fast',
                      highlightColor: AppTheme.secondary,
                    ),
                    const SizedBox(width: 8),
                    _MetricCard(
                      icon: Icons.insights,
                      title: 'Score',
                      value: '+1,250',
                      subtitle: 'Total PTS',
                      highlightColor: AppTheme.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 4. Spoils Earned (Coins + Crystals)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerHigh.withAlpha(160),
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.secondaryContainer.withAlpha(50),
                        ),
                        child: const Icon(
                          Icons.monetization_on,
                          color: AppTheme.secondary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            '+150',
                            style: TextStyle(
                              color: AppTheme.secondaryFixed,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Gold Coins',
                            style: TextStyle(
                              color: AppTheme.onSurfaceVariant,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.tertiaryContainer.withAlpha(60),
                        ),
                        child: const Icon(
                          Icons.diamond,
                          color: AppTheme.tertiaryFixed,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            '+1',
                            style: TextStyle(
                              color: AppTheme.tertiaryFixed,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Bonus Crystal',
                            style: TextStyle(
                              color: AppTheme.onSurfaceVariant,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 5. Actions: Golden CLAIM 2X & Navigation Row
          Row(
            children: [
              // Replay / Play Again
              SizedBox(
                height: 48,
                width: 48,
                child: ElevatedButton(
                  key: const Key('play_again_button'),
                  onPressed: onPlayAgain,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.surfaceContainerHigh,
                    foregroundColor: AppTheme.onSurface,
                    shape: const CircleBorder(),
                    padding: EdgeInsets.zero,
                  ),
                  child: const Icon(Icons.replay, size: 22),
                ),
              ),
              const SizedBox(width: 10),

              // Next Level or Claim
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    key: hasNextLevel
                        ? const Key('next_level_button')
                        : const Key('claim_button'),
                    onPressed: hasNextLevel ? onNextLevel : onPlayAgain,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.secondaryContainer,
                      foregroundColor: AppTheme.onSecondaryContainer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                      elevation: 6,
                      shadowColor: AppTheme.secondaryContainer.withAlpha(160),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          hasNextLevel ? 'NEXT LEVEL' : 'CLAIM REWARDS',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          hasNextLevel
                              ? Icons.arrow_forward
                              : Icons.check_circle,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StarBadge extends StatelessWidget {
  final double iconSize;
  final String label;
  final bool isEarned;
  final bool isCenter;
  final double offsetY;

  const _StarBadge({
    required this.iconSize,
    required this.label,
    required this.isEarned,
    this.isCenter = false,
    this.offsetY = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, offsetY),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isCenter ? 68 : 52,
            height: isCenter ? 68 : 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCenter
                  ? AppTheme.surfaceContainerHighest
                  : AppTheme.surfaceContainerHigh.withAlpha(180),
              boxShadow: [
                BoxShadow(
                  color: isCenter
                      ? AppTheme.secondaryContainer.withAlpha(150)
                      : AppTheme.secondary.withAlpha(90),
                  blurRadius: isCenter ? 20 : 12,
                  spreadRadius: isCenter ? 1 : 0,
                ),
              ],
            ),
            child: Icon(
              Icons.star,
              color: isCenter ? AppTheme.secondaryFixed : AppTheme.secondary,
              size: iconSize,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isCenter ? 10 : 6,
              vertical: 2,
            ),
            decoration: isCenter
                ? BoxDecoration(
                    color: AppTheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  )
                : null,
            child: Text(
              label,
              style: TextStyle(
                color: isCenter
                    ? AppTheme.onSecondaryContainer
                    : AppTheme.secondaryFixed,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final Color? highlightColor;

  const _MetricCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerHigh.withAlpha(160),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: AppTheme.outline, size: 12),
                const SizedBox(width: 3),
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.outline,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              value,
              style: TextStyle(
                color: highlightColor ?? AppTheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              subtitle,
              style: TextStyle(
                color:
                    highlightColor?.withAlpha(200) ?? AppTheme.onSurfaceVariant,
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
