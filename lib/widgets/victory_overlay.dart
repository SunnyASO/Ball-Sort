import 'package:flutter/material.dart';

import '../theme/game_theme.dart';

/// Victory celebration modal matching the Orb Lab futuristic containment completion station.
///
/// Features:
/// - "Level Completed!" / "All Prototype Levels Complete!" laboratory header badge with energy aura.
/// - Tactical containment efficiency cards displaying verified move counts.
/// - Containment parameters (Energy Stability, Efficiency Rating).
/// - Clean futuristic action buttons: Replay ("play_again_button") and Next Sector ("next_level_button").
/// - Fully responsive across small (320x568) and large (412x915) mobile displays with zero RenderFlex overflow.
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
        color: GameTheme.surface.withAlpha(250),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32.0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(190),
            blurRadius: 40,
            offset: const Offset(0, -10),
          ),
          BoxShadow(
            color: GameTheme.cyanAccent.withAlpha(45),
            blurRadius: 30,
            spreadRadius: 2,
          ),
        ],
        border: Border(
          top: BorderSide(
            color: GameTheme.cyanAccent.withAlpha(140),
            width: 1.5,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Level Complete Header Badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 8.0,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [GameTheme.cyanAccent, GameTheme.blueAccent],
              ),
              borderRadius: BorderRadius.circular(24.0),
              boxShadow: [
                BoxShadow(
                  color: GameTheme.cyanAccent.withAlpha(140),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.verified_outlined,
                  color: GameTheme.background,
                  size: 19,
                ),
                const SizedBox(width: 8),
                Text(
                  hasNextLevel
                      ? 'Level Completed!'
                      : 'All Prototype Levels Complete!',
                  key: const Key('victory_title'),
                  style: const TextStyle(
                    color: GameTheme.background,
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.bolt, color: GameTheme.background, size: 19),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // 2. Futuristic Energy Stabilization Metrics
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: GameTheme.surfaceElevated.withAlpha(220),
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(
                color: GameTheme.cyanAccent.withAlpha(40),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'CONTAINMENT PROTOCOL METRICS',
                      style: TextStyle(
                        color: GameTheme.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: GameTheme.cyanAccent.withAlpha(35),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: GameTheme.cyanAccent.withAlpha(100),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.auto_awesome,
                            color: GameTheme.cyanAccent,
                            size: 11,
                          ),
                          SizedBox(width: 3),
                          Text(
                            'STABLE',
                            style: TextStyle(
                              color: GameTheme.cyanAccent,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
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
                      icon: Icons.swap_calls_rounded,
                      title: 'Moves',
                      value: '$moveCount',
                      subtitle: 'Solved in $moveCount moves',
                      highlightColor: GameTheme.cyanAccent,
                    ),
                    const SizedBox(width: 8),
                    _MetricCard(
                      icon: Icons.electric_bolt_outlined,
                      title: 'Purity',
                      value: '100%',
                      subtitle: 'Energy Purified',
                      highlightColor: GameTheme.violetAccent,
                    ),
                    const SizedBox(width: 8),
                    _MetricCard(
                      icon: Icons.track_changes_outlined,
                      title: 'Sector',
                      value: 'L$levelNumber',
                      subtitle: 'Secured',
                      highlightColor: GameTheme.blueAccent,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 3. Lab Actions: Replay & Next Sector Navigation
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
                    backgroundColor: GameTheme.surfaceElevated,
                    foregroundColor: GameTheme.textPrimary,
                    shape: CircleBorder(
                      side: BorderSide(
                        color: GameTheme.cyanAccent.withAlpha(80),
                        width: 1.0,
                      ),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: const Icon(Icons.refresh_rounded, size: 22),
                ),
              ),
              const SizedBox(width: 10),

              // Next Level or Prototype Complete Button
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    key: hasNextLevel
                        ? const Key('next_level_button')
                        : const Key('claim_button'),
                    onPressed: hasNextLevel ? onNextLevel : onPlayAgain,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GameTheme.cyanAccent,
                      foregroundColor: GameTheme.background,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                      elevation: 6,
                      shadowColor: GameTheme.cyanAccent.withAlpha(160),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          hasNextLevel ? 'NEXT SECTOR' : 'COMPLETE PROTOCOL',
                          style: const TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_forward_rounded, size: 18),
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

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final Color highlightColor;

  const _MetricCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    this.highlightColor = GameTheme.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          color: GameTheme.surface.withAlpha(180),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: highlightColor.withAlpha(40), width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: highlightColor, size: 16),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                color: highlightColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                color: GameTheme.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              subtitle,
              style: const TextStyle(
                color: GameTheme.textTertiary,
                fontSize: 8,
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
