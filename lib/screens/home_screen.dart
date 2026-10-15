import 'package:flutter/material.dart';

import '../levels/level_catalog.dart';
import '../services/audio_haptic_service.dart';
import '../services/progression_service.dart';
import '../theme/game_theme.dart';
import 'game_screen.dart';
import 'level_map_screen.dart';
import 'shop_screen.dart';

/// Orb Lab Headquarters / Home Screen.
///
/// Features:
/// - Atmospheric laboratory environment with glowing radial energy blooms.
/// - Pulsing central Quantum Core with chromatic lens flares.
/// - Mission Command card with live progression metrics, sector count, and earned stars.
/// - Large "CONTINUE MISSION" CTA resuming the exact saved active sector.
/// - Direct navigation to Sector Map and Research / Wardrobe screens.
/// - Safe back navigation handling.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  int _currentLevel = 1;
  int _highestUnlocked = 1;
  int _totalStars = 0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );

    _refreshProgress();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _refreshProgress() {
    setState(() {
      _currentLevel = ProgressionService.instance.currentLevel.clamp(
        1,
        LevelCatalog.totalLevels,
      );
      _highestUnlocked = ProgressionService.instance.highestUnlockedLevel.clamp(
        1,
        LevelCatalog.totalLevels,
      );
      _totalStars = ProgressionService.instance.totalStars;
    });
  }

  Future<void> _continueMission() async {
    AudioHapticService.instance.playSelect();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GameScreen(initialLevelNumber: _currentLevel),
      ),
    );
    if (mounted) {
      _refreshProgress();
    }
  }

  Future<void> _openSectorMap() async {
    AudioHapticService.instance.playSelect();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => LevelMapScreen(
          currentLevel: _currentLevel,
          onSelectLevel: (lvl) {
            ProgressionService.instance.setCurrentLevel(lvl);
            Navigator.of(ctx).pushReplacement(
              MaterialPageRoute(
                builder: (_) => GameScreen(initialLevelNumber: lvl),
              ),
            );
          },
        ),
      ),
    );
    if (mounted) {
      _refreshProgress();
    }
  }

  Future<void> _openShop() async {
    AudioHapticService.instance.playSelect();
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ShopScreen()),
    );
    if (mounted) {
      _refreshProgress();
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalLevels = LevelCatalog.totalLevels;
    final progressFactor = totalLevels > 0
        ? ((_highestUnlocked - 1) / totalLevels).clamp(0.0, 1.0)
        : 0.0;
    final maxStars = totalLevels * 3;

    return Scaffold(
      backgroundColor: GameTheme.background,
      body: SafeArea(
        child: Stack(
          children: [
            // 1. Ambient Background Energy Blooms
            Positioned(
              top: -60,
              right: -40,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: GameTheme.cyanAccent.withAlpha(25),
                ),
              ),
            ),
            Positioned(
              bottom: 80,
              left: -50,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: GameTheme.violetAccent.withAlpha(20),
                ),
              ),
            ),

            // 2. Main Content Column
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                children: [
                  // Top Status Strip
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Lab System Status
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: GameTheme.surfaceElevated,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: GameTheme.cyanAccent.withAlpha(60),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF00E676),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFF00E676),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'LAB ONLINE',
                              style: TextStyle(
                                color: GameTheme.cyanAccent,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Star Rating Tally
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: GameTheme.surfaceElevated,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFFFD700).withAlpha(80),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Color(0xFFFFD700),
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$_totalStars / $maxStars',
                              style: const TextStyle(
                                color: GameTheme.textPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const Spacer(flex: 1),

                  // Hero Quantum Core
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      final scale = 1.0 + (_pulseAnimation.value * 0.05);
                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          key: const Key('home_core_orb'),
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const RadialGradient(
                              colors: [
                                Color(0xFFB5F5FF),
                                GameTheme.cyanGlow,
                                GameTheme.cyanAccent,
                                GameTheme.blueAccent,
                                Color(0xFF0D1733),
                              ],
                              stops: [0.0, 0.25, 0.55, 0.82, 1.0],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: GameTheme.cyanAccent.withAlpha(
                                  (120 + (50 * _pulseAnimation.value)).toInt(),
                                ),
                                blurRadius: 36,
                                spreadRadius: 4,
                              ),
                              BoxShadow(
                                color: GameTheme.violetAccent.withAlpha(80),
                                blurRadius: 48,
                                spreadRadius: 8,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              Icons.science_outlined,
                              color: GameTheme.background.withAlpha(220),
                              size: 64,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Brand Title & Subtitle
                  const Text(
                    'ORB LAB',
                    style: TextStyle(
                      color: GameTheme.textPrimary,
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'QUANTUM SORT SIMULATOR',
                    style: TextStyle(
                      color: GameTheme.cyanAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.0,
                    ),
                  ),

                  const Spacer(flex: 1),

                  // Mission Status Card
                  Container(
                    key: const Key('home_mission_card'),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: GameTheme.surfaceElevated.withAlpha(230),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: GameTheme.cyanAccent.withAlpha(60),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(120),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'CURRENT ASSIGNMENT',
                              style: TextStyle(
                                color: GameTheme.textTertiary,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: GameTheme.cyanAccent.withAlpha(30),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'SECTOR $_currentLevel',
                                style: const TextStyle(
                                  color: GameTheme.cyanAccent,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: progressFactor,
                            minHeight: 8,
                            backgroundColor: GameTheme.background,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              GameTheme.cyanAccent,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Sectors Unlocked: $_highestUnlocked / $totalLevels',
                              style: const TextStyle(
                                color: GameTheme.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '${(progressFactor * 100).toInt()}% Done',
                              style: const TextStyle(
                                color: GameTheme.cyanAccent,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Primary CTA Button: Continue Mission
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      key: const Key('continue_mission_button'),
                      onPressed: _continueMission,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GameTheme.cyanAccent,
                        foregroundColor: GameTheme.background,
                        elevation: 8,
                        shadowColor: GameTheme.cyanAccent.withAlpha(160),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.play_arrow_rounded, size: 28),
                          const SizedBox(width: 8),
                          Text(
                            _highestUnlocked == 1 && _totalStars == 0
                                ? 'INITIALIZE LAB'
                                : 'CONTINUE MISSION',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: GameTheme.background.withAlpha(60),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'SEC $_currentLevel',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Secondary Navigation Actions
                  Row(
                    children: [
                      // Sectors Map Button
                      Expanded(
                        child: OutlinedButton.icon(
                          key: const Key('sectors_map_button'),
                          onPressed: _openSectorMap,
                          icon: const Icon(
                            Icons.map_outlined,
                            size: 18,
                            color: GameTheme.cyanAccent,
                          ),
                          label: const Text(
                            'SECTORS',
                            style: TextStyle(
                              color: GameTheme.textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.6,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(
                              color: GameTheme.cyanAccent.withAlpha(80),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Wardrobe / Shop Button
                      Expanded(
                        child: OutlinedButton.icon(
                          key: const Key('wardrobe_button'),
                          onPressed: _openShop,
                          icon: const Icon(
                            Icons.checkroom_outlined,
                            size: 18,
                            color: GameTheme.violetAccent,
                          ),
                          label: const Text(
                            'RESEARCH',
                            style: TextStyle(
                              color: GameTheme.textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.6,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(
                              color: GameTheme.violetAccent.withAlpha(80),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(flex: 1),

                  // Version & Protocol Footnote
                  const Text(
                    'ORB LAB v1.0.0 • 50 VERIFIED SECTORS • OFFLINE',
                    style: TextStyle(
                      color: GameTheme.textTertiary,
                      fontSize: 10,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
