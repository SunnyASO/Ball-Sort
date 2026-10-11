import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../game/ball_move.dart';
import '../game/game_controller.dart';
import '../levels/prototype_levels.dart';
import '../theme/app_theme.dart';
import '../widgets/game_header.dart';
import '../widgets/move_animation_layer.dart';
import '../widgets/tube_widget.dart';
import '../widgets/victory_overlay.dart';
import 'level_map_screen.dart';
import 'shop_screen.dart';

/// Cosmic Ball Sort Game Screen integrating Stitch design system,
/// gameplay HUD, glass tubes, single-ball transfer kinematics, victory modal,
/// and bottom navigation (Play, Levels, Shop).
class GameScreen extends StatefulWidget {
  final GameController? controller;
  final int initialLevelNumber;
  final Duration transferDuration;

  const GameScreen({
    super.key,
    this.controller,
    this.initialLevelNumber = 1,
    this.transferDuration = const Duration(milliseconds: 400),
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late GameController _controller;
  late int _currentLevelNumber;
  late AnimationController _animationController;

  int _currentNavIndex = 0; // 0: Play, 1: Levels, 2: Shop

  bool _isAnimating = false;
  TransferAnimationData? _activeAnimationData;
  int? _animatingDestTube;
  Set<int>? _animatingDestSlots;
  double _currentBallSize = 48.0;

  final GlobalKey _playAreaKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _currentLevelNumber = widget.initialLevelNumber;
    _controller =
        widget.controller ??
        GameController(
          initialBoard: PrototypeLevels.getLevel(_currentLevelNumber),
        );
    _animationController = AnimationController(
      vsync: this,
      duration: widget.transferDuration,
    )..addStatusListener(_onAnimationStatus);
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (!mounted) return;
    if (status == AnimationStatus.completed) {
      setState(() {
        _isAnimating = false;
        _activeAnimationData = null;
        _animatingDestTube = null;
        _animatingDestSlots = null;
        _controller.setInputLocked(false);
      });
    }
  }

  @override
  void didUpdateWidget(GameScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialLevelNumber != oldWidget.initialLevelNumber &&
        widget.controller == null) {
      _cancelAnimation();
      _currentLevelNumber = widget.initialLevelNumber;
      _controller = GameController(
        initialBoard: PrototypeLevels.getLevel(_currentLevelNumber),
      );
    }
    if (widget.transferDuration != oldWidget.transferDuration) {
      _animationController.duration = widget.transferDuration;
    }
  }

  @override
  void dispose() {
    _animationController.removeStatusListener(_onAnimationStatus);
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _cancelAnimation() {
    if (_isAnimating) {
      _animationController.stop();
      _isAnimating = false;
      _activeAnimationData = null;
      _animatingDestTube = null;
      _animatingDestSlots = null;
      _controller.setInputLocked(false);
    }
  }

  RenderBox? _findTubeRenderBox(int index) {
    final targetKey = ValueKey('tube_$index');
    RenderBox? result;
    void visitor(Element element) {
      if (element.widget.key == targetKey) {
        result = element.renderObject as RenderBox?;
        return;
      }
      element.visitChildren(visitor);
    }

    context.visitChildElements(visitor);
    return result;
  }

  void _onTubeTapped(int index) {
    if (_isAnimating || _controller.inputLocked || _controller.solved) {
      return;
    }

    final move = _controller.handleTubeTap(index);
    if (move != null) {
      _startTransferAnimation(move);
    } else {
      setState(() {});
    }
  }

  void _startTransferAnimation(BallMove move) {
    _controller.setInputLocked(true);
    _isAnimating = true;

    final k = move.ballsMoved;
    final destTubeIndex = move.destinationTube;
    final destTube = _controller.board.tubes[destTubeIndex];
    final totalDestBalls = destTube.balls.length;

    // The newly arrived k balls occupy slot indices from (totalDestBalls - k) to (totalDestBalls - 1)
    final hiddenSlots = <int>{};
    for (int i = 0; i < k; i++) {
      hiddenSlots.add(totalDestBalls - k + i);
    }
    _animatingDestTube = destTubeIndex;
    _animatingDestSlots = hiddenSlots;

    final sourceTubeIndex = move.sourceTube;
    final sourceTube = _controller.board.tubes[sourceTubeIndex];
    final currentSourceBalls = sourceTube.balls.length;

    final sourceBox = _findTubeRenderBox(sourceTubeIndex);
    final destBox = _findTubeRenderBox(destTubeIndex);
    final playAreaBox =
        _playAreaKey.currentContext?.findRenderObject() as RenderBox?;

    if (sourceBox == null || destBox == null || playAreaBox == null) {
      _isAnimating = false;
      _animatingDestTube = null;
      _animatingDestSlots = null;
      _controller.setInputLocked(false);
      setState(() {});
      return;
    }

    final sourceOffset = playAreaBox.globalToLocal(
      sourceBox.localToGlobal(Offset.zero),
    );
    final destOffset = playAreaBox.globalToLocal(
      destBox.localToGlobal(Offset.zero),
    );

    final sourceBallCenterX = sourceOffset.dx + (sourceBox.size.width / 2);
    final destBallCenterX = destOffset.dx + (destBox.size.width / 2);

    final sourceBallCenters = <Offset>[];
    final destBallCenters = <Offset>[];

    for (int i = 0; i < k; i++) {
      // Source slot for ball i in the group:
      // Ball 0 (bottom-most in the moving group) was at slot currentSourceBalls + i
      final srcSlot = currentSourceBalls + i;
      final srcY = TubeWidget.ballCenterY(
        tubeTop: sourceOffset.dy,
        tubeHeight: sourceBox.size.height,
        ballSize: _currentBallSize,
        slotIndex: srcSlot,
      );
      sourceBallCenters.add(Offset(sourceBallCenterX, srcY));

      // Dest slot for ball i in the group:
      // Ball 0 lands at (totalDestBalls - k), Ball (k-1) lands at (totalDestBalls - 1)
      final dstSlot = (totalDestBalls - k) + i;
      final dstY = TubeWidget.ballCenterY(
        tubeTop: destOffset.dy,
        tubeHeight: destBox.size.height,
        ballSize: _currentBallSize,
        slotIndex: dstSlot,
      );
      destBallCenters.add(Offset(destBallCenterX, dstY));
    }

    final clearanceY =
        math.min(sourceOffset.dy, destOffset.dy) -
        (_currentBallSize / 2) -
        16.0;

    _activeAnimationData = TransferAnimationData(
      sourceBallCenters: sourceBallCenters,
      destBallCenters: destBallCenters,
      clearanceY: clearanceY,
      ballType: move.movedBall!,
      ballTypes: move.movedBalls,
      ballSize: _currentBallSize,
      totalDuration: widget.transferDuration,
    );

    setState(() {});
    _animationController.forward(from: 0.0);
  }

  void _onRestart() {
    _cancelAnimation();
    setState(() {
      _controller.restart();
    });
  }

  void _onUndo() {
    if (_isAnimating || _controller.inputLocked) return;
    setState(() {
      _controller.undo();
    });
  }

  void _onNextLevel() {
    _cancelAnimation();
    if (_currentLevelNumber < PrototypeLevels.totalLevels) {
      setState(() {
        _currentLevelNumber++;
        _controller = GameController(
          initialBoard: PrototypeLevels.getLevel(_currentLevelNumber),
        );
      });
    }
  }

  void _onSelectLevelFromMap(int level) {
    _cancelAnimation();
    setState(() {
      _currentLevelNumber = level;
      _controller = GameController(
        initialBoard: PrototypeLevels.getLevel(_currentLevelNumber),
      );
      _currentNavIndex = 0; // Return to Play screen
    });
  }

  @override
  Widget build(BuildContext context) {
    // If Levels or Shop tab is active, render their screens
    if (_currentNavIndex == 1) {
      return Stack(
        children: [
          LevelMapScreen(
            currentLevel: _currentLevelNumber,
            onSelectLevel: _onSelectLevelFromMap,
          ),
          _buildBottomNavBar(),
        ],
      );
    } else if (_currentNavIndex == 2) {
      return Stack(children: [const ShopScreen(), _buildBottomNavBar()]);
    }

    final board = _controller.board;
    final isSolved = _controller.solved && !_isAnimating;
    final hasNextLevel = _currentLevelNumber < PrototypeLevels.totalLevels;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Stack(
          children: [
            // Ambient Orb Lab Background Atmosphere Glows
            Positioned(
              top: 20,
              left: -30,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF49DCEC).withAlpha(16),
                ),
              ),
            ),
            Positioned(
              top: 180,
              right: -40,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFA178FF).withAlpha(14),
                ),
              ),
            ),
            Positioned(
              bottom: 100,
              left: 40,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF5A8DFF).withAlpha(16),
                ),
              ),
            ),

            // Main Play Column
            Column(
              children: [
                // Top Cosmic HUD
                GameHeader(
                  levelNumber: _currentLevelNumber,
                  moveCount: _controller.moveCount,
                  onRestart: _onRestart,
                  onUndo: _onUndo,
                  canUndo: _controller.canUndo && !_isAnimating,
                  canRestart: !_isAnimating,
                ),

                const SizedBox(height: 8),

                // Interactive Containment Protocol Hint Pill
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.sizeOf(context).width - 32,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 4.5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF121D38).withAlpha(220),
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(
                      color: const Color(0xFF49DCEC).withAlpha(45),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.track_changes_outlined,
                        color: Color(0xFF49DCEC),
                        size: 13,
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          _controller.selectedTubeIndex != null
                              ? 'Select target containment chamber'
                              : 'Select chamber to transfer energy orb',
                          style: const TextStyle(
                            color: Color(0xFF9DADCA),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                // Tubes Playfield
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final availableWidth = constraints.maxWidth;
                      final availableHeight = constraints.maxHeight;
                      final tubeCount = board.tubeCount;
                      const double minSpacing = 6.0;
                      const double maxSpacing = 14.0;
                      const double sidePadding = 12.0;

                      final double targetBallSizeWidth =
                          ((availableWidth -
                                  (sidePadding * 2) -
                                  ((tubeCount - 1) * minSpacing)) /
                              tubeCount) -
                          16.0;

                      // Height based ball size: tube total vertical space is (4 * ballSize + 54) + 24 (text+shelf)
                      final double targetBallSizeHeight =
                          (availableHeight - 85) / 4.2;

                      final double computedBallSize = math
                          .min(targetBallSizeWidth, targetBallSizeHeight)
                          .clamp(18.0, 46.0);
                      _currentBallSize = computedBallSize;

                      final double tubeWidth = computedBallSize + 16.0;
                      final double totalTubesWidth = tubeCount * tubeWidth;
                      final double remainingSpace =
                          availableWidth - (sidePadding * 2) - totalTubesWidth;
                      final double computedSpacing = tubeCount > 1
                          ? (remainingSpace / (tubeCount - 1)).clamp(
                              minSpacing,
                              maxSpacing,
                            )
                          : minSpacing;

                      final bool needsScroll =
                          (totalTubesWidth +
                              ((tubeCount - 1) * minSpacing) +
                              (sidePadding * 2)) >
                          availableWidth;

                      return Stack(
                        key: _playAreaKey,
                        alignment: Alignment.center,
                        children: [
                          SingleChildScrollView(
                            controller: _scrollController,
                            scrollDirection: Axis.horizontal,
                            physics: needsScroll
                                ? const BouncingScrollPhysics()
                                : const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(
                              horizontal: sidePadding,
                            ),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minWidth: availableWidth - (sidePadding * 2),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      for (
                                        int i = 0;
                                        i < board.tubeCount;
                                        i++
                                      ) ...[
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            TubeWidget(
                                              key: ValueKey('tube_$i'),
                                              tube: board.tubes[i],
                                              isSelected:
                                                  _controller
                                                      .selectedTubeIndex ==
                                                  i,
                                              ballSize: computedBallSize,
                                              hiddenBallSlots:
                                                  _animatingDestTube == i
                                                  ? _animatingDestSlots
                                                  : null,
                                              isDropTarget:
                                                  _controller
                                                          .selectedTubeIndex !=
                                                      null &&
                                                  _controller
                                                          .selectedTubeIndex !=
                                                      i &&
                                                  !board.tubes[i].isFull,
                                              onTap: () => _onTubeTapped(i),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              board.tubes[i].isEmpty
                                                  ? 'Free'
                                                  : '${i + 1}',
                                              style: TextStyle(
                                                color: board.tubes[i].isEmpty
                                                    ? AppTheme.tertiary
                                                    : AppTheme.outline,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (i < board.tubeCount - 1)
                                          SizedBox(width: computedSpacing),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  // Orb Lab Containment Docking Deck Platform
                                  Container(
                                    width: math.min(
                                      availableWidth - 32,
                                      (board.tubeCount *
                                          (computedBallSize + 22.0)),
                                    ),
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1B2A4B),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: const Color(0xFF49DCEC)
                                            .withAlpha(60),
                                        width: 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF49DCEC)
                                              .withAlpha(35),
                                          blurRadius: 10,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (_activeAnimationData != null)
                            MoveAnimationLayer(
                              animation: _animationController,
                              data: _activeAnimationData!,
                            ),
                        ],
                      );
                    },
                  ),
                ),

                // Booster Toolbar (Undo, Restart, +1 Tube, Hint)
                BoosterToolbar(
                  onUndo: _onUndo,
                  onRestart: _onRestart,
                  canUndo: _controller.canUndo && !_isAnimating,
                  canRestart: !_isAnimating,
                ),

                const SizedBox(height: 12),

                // Reserve space for Bottom Navigation Bar
                const SizedBox(height: 64),
              ],
            ),

            // Victory Modal Sheet
            if (isSolved)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: VictoryOverlay(
                  levelNumber: _currentLevelNumber,
                  moveCount: _controller.moveCount,
                  hasNextLevel: hasNextLevel,
                  onPlayAgain: _onRestart,
                  onNextLevel: _onNextLevel,
                ),
              ),

            // Persistent Floating Bottom Navigation Bar (Play, Levels, Shop)
            if (!isSolved) _buildBottomNavBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Positioned(
      left: 20,
      right: 20,
      bottom: 12,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLow.withAlpha(235),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(140),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: Icons.sports_esports,
              label: 'Play',
              isActive: _currentNavIndex == 0,
              onTap: () => setState(() => _currentNavIndex = 0),
            ),
            _NavItem(
              icon: Icons.map,
              label: 'Levels',
              isActive: _currentNavIndex == 1,
              onTap: () => setState(() => _currentNavIndex = 1),
            ),
            _NavItem(
              icon: Icons.shopping_bag,
              label: 'Shop',
              isActive: _currentNavIndex == 2,
              onTap: () => setState(() => _currentNavIndex = 2),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive
                  ? AppTheme.onPrimaryContainer
                  : AppTheme.onSurfaceVariant,
              size: 20,
            ),
            if (isActive) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.onPrimaryContainer,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
