import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Top HUD and booster action toolbar matching the Stitch gameplay design.
class GameHeader extends StatelessWidget {
  final int levelNumber;
  final int moveCount;
  final VoidCallback onRestart;
  final VoidCallback? onUndo;
  final bool canUndo;
  final bool canRestart;

  const GameHeader({
    super.key,
    required this.levelNumber,
    required this.moveCount,
    required this.onRestart,
    this.onUndo,
    this.canUndo = false,
    this.canRestart = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Top App Bar (Icon, Title, Hearts, Coins, Level, Settings, Avatar)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
          decoration: BoxDecoration(
            color: AppTheme.surface.withAlpha(220),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(80),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo & Title
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [AppTheme.primary, AppTheme.primaryContainer],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withAlpha(100),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.bubble_chart,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        'Ball Sort',
                        style: TextStyle(
                          color: AppTheme.onSurface,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                      Text(
                        'Play',
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Status Capsules (Coins, Level)
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainerHigh.withAlpha(220),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.monetization_on,
                            color: AppTheme.secondary,
                            size: 11,
                          ),
                          const SizedBox(width: 2),
                          const Text(
                            '2.4k',
                            style: TextStyle(
                              color: AppTheme.secondaryFixed,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'L$levelNumber',
                            style: const TextStyle(
                              color: AppTheme.tertiary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Avatar
              Container(
                width: 26,
                height: 26,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primary,
                ),
                child: const Icon(
                  Icons.person,
                  color: AppTheme.onPrimary,
                  size: 16,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 6),

        // 2. In-Game Sub-HUD: Level badge, 3-Star target bar, and Moves count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 6.0,
            ),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerHigh.withAlpha(200),
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(80),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Level Indicator (Preserves text: "Level $levelNumber" for tests)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.primaryContainer,
                      ),
                      child: const Icon(
                        Icons.military_tech,
                        color: AppTheme.primary,
                        size: 14,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Level $levelNumber',
                          style: const TextStyle(
                            color: AppTheme.onSurface,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Standard',
                          style: TextStyle(
                            color: AppTheme.onSurfaceVariant,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Moves badge (Preserves text: "Moves: $moveCount" for tests)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerLowest.withAlpha(200),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.touch_app,
                        color: AppTheme.tertiary,
                        size: 12,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        'Moves: $moveCount',
                        style: const TextStyle(
                          color: AppTheme.onSurface,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Booster Action Toolbar matching Stitch Screen 2.
class BoosterToolbar extends StatelessWidget {
  final VoidCallback? onUndo;
  final VoidCallback onRestart;
  final bool canUndo;
  final bool canRestart;

  const BoosterToolbar({
    super.key,
    required this.onUndo,
    required this.onRestart,
    required this.canUndo,
    required this.canRestart,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerHigh.withAlpha(220),
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(110),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            // 1. Undo Booster
            Expanded(
              child: _BoosterButton(
                key: const Key('undo_button'),
                icon: Icons.undo,
                label: 'Undo',
                badgeText: '3',
                badgeColor: AppTheme.secondary,
                iconColor: AppTheme.primary,
                isEnabled: canUndo,
                onTap: canUndo ? onUndo : null,
              ),
            ),
            const SizedBox(width: 6),

            // 2. Restart Booster
            Expanded(
              child: _BoosterButton(
                key: const Key('restart_button'),
                icon: Icons.replay,
                label: 'Restart',
                iconColor: AppTheme.onSurface,
                isEnabled: canRestart,
                onTap: canRestart ? onRestart : null,
              ),
            ),
            const SizedBox(width: 6),

            // 3. +1 Tube Booster
            Expanded(
              child: _BoosterButton(
                key: const Key('add_tube_button'),
                icon: Icons.add_circle,
                label: '+1 Tube',
                badgeText: '500',
                badgeIcon: Icons.monetization_on,
                badgeColor: AppTheme.secondaryContainer,
                iconColor: AppTheme.secondary,
                isEnabled: true,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Extra Tube Booster unlocked!'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 6),

            // 4. Hint Booster
            Expanded(
              child: _BoosterButton(
                key: const Key('hint_button'),
                icon: Icons.auto_fix_high,
                label: 'Hint',
                badgeText: '2',
                badgeColor: AppTheme.tertiary,
                iconColor: AppTheme.tertiary,
                isEnabled: true,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Hint: Look for matching colors!'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BoosterButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? badgeText;
  final IconData? badgeIcon;
  final Color? badgeColor;
  final Color iconColor;
  final bool isEnabled;
  final VoidCallback? onTap;

  const _BoosterButton({
    super.key,
    required this.icon,
    required this.label,
    this.badgeText,
    this.badgeIcon,
    this.badgeColor,
    required this.iconColor,
    required this.isEnabled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainer.withAlpha(isEnabled ? 200 : 80),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: iconColor.withAlpha(isEnabled ? 35 : 15),
                  ),
                  child: Icon(
                    icon,
                    color: isEnabled ? iconColor : AppTheme.outlineVariant,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: isEnabled
                        ? AppTheme.onSurface
                        : AppTheme.outlineVariant,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (badgeText != null)
              Positioned(
                top: -6,
                right: -2,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 1.5,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor ?? AppTheme.secondary,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(90),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (badgeIcon != null) ...[
                        Icon(badgeIcon, color: Colors.white, size: 9),
                        const SizedBox(width: 1),
                      ],
                      Text(
                        badgeText!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
