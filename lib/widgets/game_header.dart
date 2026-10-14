import 'package:flutter/material.dart';

import '../theme/game_theme.dart';

/// Top HUD and booster action toolbar matching the Orb Lab futuristic laboratory aesthetic.
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
        // 1. Top App Bar (Icon, Title: Ball Sort / ORB LAB, Level, Status capsule)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
          decoration: BoxDecoration(
            color: GameTheme.surface.withAlpha(240),
            border: const Border(
              bottom: BorderSide(
                color: Color(0x3349DCEC), // subtle cyan horizontal divider
                width: 1.0,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(120),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo & Title: Ball Sort / ORB LAB
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const RadialGradient(
                          colors: [
                            GameTheme.cyanGlow,
                            GameTheme.cyanAccent,
                            GameTheme.blueAccent,
                          ],
                          stops: [0.0, 0.45, 1.0],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: GameTheme.cyanAccent.withAlpha(140),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.science_outlined,
                        color: GameTheme.background,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            'Ball Sort',
                            style: TextStyle(
                              color: GameTheme.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'ORB LAB',
                            style: TextStyle(
                              color: GameTheme.cyanAccent,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 6),

              // Lab Status Capsule (Sector / Chamber Code)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: GameTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: GameTheme.cyanAccent.withAlpha(60),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.bolt,
                      color: GameTheme.cyanAccent,
                      size: 12,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      'SEC $levelNumber',
                      style: const TextStyle(
                        color: GameTheme.cyanAccent,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 6),

        // 2. In-Game Sub-HUD: Level badge and Moves count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 6.0,
            ),
            decoration: BoxDecoration(
              color: GameTheme.surfaceElevated.withAlpha(220),
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(
                color: GameTheme.cyanAccent.withAlpha(40),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(90),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Level Indicator (Preserves text: "Level $levelNumber" for tests)
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: GameTheme.cyanAccent.withAlpha(35),
                        ),
                        child: const Icon(
                          Icons.track_changes,
                          color: GameTheme.cyanAccent,
                          size: 14,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Level $levelNumber',
                          style: const TextStyle(
                            color: GameTheme.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 6),

                // Moves badge (Preserves text: "Moves: $moveCount" for tests)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: GameTheme.background.withAlpha(220),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: GameTheme.blueAccent.withAlpha(80),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.swap_calls_rounded,
                        color: GameTheme.cyanAccent,
                        size: 12,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        'Moves: $moveCount',
                        style: const TextStyle(
                          color: GameTheme.cyanAccent,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
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

/// Bottom booster action toolbar styled for the Orb Lab control station.
/// Prominently features Undo and Restart with clear active/disabled visual feedback.
class BoosterToolbar extends StatelessWidget {
  final VoidCallback onRestart;
  final VoidCallback? onUndo;
  final VoidCallback? onAddTube;
  final VoidCallback? onHint;
  final bool canUndo;
  final bool canRestart;
  final bool canAddTube;
  final bool canHint;

  const BoosterToolbar({
    super.key,
    required this.onRestart,
    this.onUndo,
    this.onAddTube,
    this.onHint,
    this.canUndo = false,
    this.canRestart = true,
    this.canAddTube = true,
    this.canHint = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: GameTheme.surface.withAlpha(230),
          borderRadius: BorderRadius.circular(22.0),
          border: Border.all(
            color: GameTheme.cyanAccent.withAlpha(35),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(100),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // 1. Undo Control (Prominent laboratory action button)
            Expanded(
              child: _LabActionButton(
                key: const Key('undo_button'),
                icon: Icons.undo_rounded,
                label: 'Undo',
                iconColor: GameTheme.cyanAccent,
                isEnabled: canUndo,
                onTap: canUndo ? onUndo : null,
              ),
            ),
            const SizedBox(width: 8),

            // 2. Restart Control (Prominent laboratory reset button)
            Expanded(
              child: _LabActionButton(
                key: const Key('restart_button'),
                icon: Icons.refresh_rounded,
                label: 'Restart',
                iconColor: GameTheme.violetAccent,
                isEnabled: canRestart,
                onTap: canRestart ? onRestart : null,
              ),
            ),
            const SizedBox(width: 8),

            // 3. Technical Protocol Marker / Chamber Stabilizer
            Expanded(
              child: _LabActionButton(
                key: const Key('add_tube_button'),
                icon: Icons.add_circle_outline_rounded,
                label: '+1 Chamber',
                iconColor: GameTheme.textTertiary,
                isEnabled: canAddTube,
                onTap: canAddTube ? onAddTube : null,
              ),
            ),
            const SizedBox(width: 8),

            // 4. Lab Calibration / Guide Action
            Expanded(
              child: _LabActionButton(
                key: const Key('hint_button'),
                icon: Icons.psychology_outlined,
                label: 'Hint',
                iconColor: const Color(0xFFFFD700),
                isEnabled: canHint,
                onTap: canHint ? onHint : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LabActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final bool isEnabled;
  final VoidCallback? onTap;

  const _LabActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.isEnabled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = iconColor;
    final disabledColor = GameTheme.textDisabled;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        decoration: BoxDecoration(
          color: GameTheme.surfaceElevated.withAlpha(isEnabled ? 220 : 70),
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: isEnabled ? activeColor.withAlpha(60) : Colors.transparent,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isEnabled
                    ? activeColor.withAlpha(30)
                    : GameTheme.surfaceDim,
              ),
              child: Icon(
                icon,
                color: isEnabled ? activeColor : disabledColor,
                size: 19,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isEnabled ? GameTheme.textPrimary : disabledColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
