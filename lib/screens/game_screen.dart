import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../game/ball_move.dart';
import '../game/game_controller.dart';
import '../levels/level_catalog.dart';
import '../services/audio_haptic_service.dart';
import '../services/progression_service.dart';
import '../theme/app_theme.dart';
import '../theme/game_theme.dart';
import '../widgets/celebration_particles.dart';
import '../widgets/game_header.dart';
import '../widgets/move_animation_layer.dart';
import '../widgets/tube_widget.dart';
import '../widgets/victory_overlay.dart';
import '../widgets/settings_sheet.dart';
import 'level_map_screen.dart';
import 'shop_screen.dart';

/// Cosmic Ball Sort Game Screen integrating Stitch design system,
/// gameplay HUD, glass tubes, single-ball transfer kinematics, victory modal,
/// and bottom navigation (Play, Levels, Shop).
class GameScreen extends StatefulWidget {
  final GameController? controller;
  final int initialLevelNumber;
  final Duration transferDuration;
  final int? maxLevels;

  const GameScreen({
    super.key,
    this.controller,
    this.initialLevelNumber = 1,
    this.transferDuration = const Duration(milliseconds: 400),
    this.maxLevels,
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

  int? _hintSourceTube;
  int? _hintDestTube;
  bool _isHintLoading = false;
  int _hintRequestId = 0;

  final GlobalKey _playAreaKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();

  int get _effectiveMaxLevels =>
      widget.maxLevels ??
      (widget.controller != null && widget.initialLevelNumber == 6
          ? 6
          : LevelCatalog.totalLevels);

  @override
  void initState() {
    super.initState();
    _currentLevelNumber = widget.initialLevelNumber;
    _controller =
        widget.controller ??
        GameController(
          initialBoard: LevelCatalog.getLevel(_currentLevelNumber),
        );
    _animationController = AnimationController(
      vsync: this,
      duration: widget.transferDuration,
    )..addStatusListener(_onAnimationStatus);
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (!mounted) return;
    if (status == AnimationStatus.completed) {
      final destIndex = _animatingDestTube;
      setState(() {
        _isAnimating = false;
        _activeAnimationData = null;
        _animatingDestTube = null;
        _animatingDestSlots = null;
        _controller.setInputLocked(false);
      });

      // Synchronize touchdown impact sensory feedback at the exact moment of landing
      AudioHapticService.instance.playTransferDrop();

      if (destIndex != null && _controller.board.tubes[destIndex].isComplete) {
        AudioHapticService.instance.playTubeComplete();
      }

      if (_controller.solved) {
        AudioHapticService.instance.playVictory();
        ProgressionService.instance.recordLevelCompletion(
          level: _currentLevelNumber,
          moves: _controller.moveCount,
        );
        ProgressionService.instance.setCurrentLevel(_currentLevelNumber + 1);
      }
    }
  }

  @override
  void didUpdateWidget(GameScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialLevelNumber != oldWidget.initialLevelNumber &&
        widget.controller == null) {
      _cancelAnimation();
      _invalidateHint();
      _currentLevelNumber = widget.initialLevelNumber;
      _controller = GameController(
        initialBoard: LevelCatalog.getLevel(_currentLevelNumber),
      );
    }
    if (widget.transferDuration != oldWidget.transferDuration) {
      _animationController.duration = widget.transferDuration;
    }
  }

  @override
  void dispose() {
    _invalidateHint();
    _animationController.removeStatusListener(_onAnimationStatus);
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _invalidateHint() {
    _hintRequestId++;
    _isHintLoading = false;
    _hintSourceTube = null;
    _hintDestTube = null;
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
    _invalidateHint();
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

    _hintSourceTube = null;
    _hintDestTube = null;
    AudioHapticService.instance.playSelect();

    final move = _controller.handleTubeTap(index);
    if (move != null) {
      _invalidateHint();
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
    final sourceTubeIndex = move.sourceTube;

    final tubeDistance = (sourceTubeIndex - destTubeIndex).abs();
    final adaptiveDuration = Duration(
      milliseconds: (320 + (tubeDistance * 20)).clamp(320, 440),
    );
    _animationController.duration = adaptiveDuration;

    final destTube = _controller.board.tubes[destTubeIndex];
    final totalDestBalls = destTube.balls.length;

    // The newly arrived k balls occupy slot indices from (totalDestBalls - k) to (totalDestBalls - 1)
    final hiddenSlots = <int>{};
    for (int i = 0; i < k; i++) {
      hiddenSlots.add(totalDestBalls - k + i);
    }
    _animatingDestTube = destTubeIndex;
    _animatingDestSlots = hiddenSlots;

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
    if (_isAnimating || _controller.inputLocked) return;

    if (_controller.moveCount > 0 && !_controller.solved) {
      _showRestartConfirmationDialog();
    } else {
      _performRestart();
    }
  }

  void _showRestartConfirmationDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withAlpha(180),
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: GameTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: GameTheme.violetAccent.withAlpha(80),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(160),
                  blurRadius: 24,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: GameTheme.violetAccent.withAlpha(30),
                    border: Border.all(
                      color: GameTheme.violetAccent.withAlpha(80),
                    ),
                  ),
                  child: const Icon(
                    Icons.refresh_rounded,
                    color: GameTheme.violetAccent,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Restart this level?',
                  style: TextStyle(
                    color: GameTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Current moves in Sector $_currentLevelNumber will be lost.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: GameTheme.textSecondary,
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    // Cancel Action
                    Expanded(
                      child: OutlinedButton(
                        key: const Key('restart_cancel_button'),
                        onPressed: () => Navigator.of(ctx).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(
                            color: GameTheme.textTertiary.withAlpha(80),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: GameTheme.textSecondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Restart Action
                    Expanded(
                      child: ElevatedButton(
                        key: const Key('restart_confirm_button'),
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          _performRestart();
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: GameTheme.violetAccent,
                          foregroundColor: GameTheme.textPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Restart Level',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
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

  void _performRestart() {
    _cancelAnimation();
    _invalidateHint();
    AudioHapticService.instance.playRestart();
    setState(() {
      _controller.restart();
    });
  }

  void _onUndo() {
    if (_isAnimating || _controller.inputLocked) return;
    _invalidateHint();
    AudioHapticService.instance.playUndo();
    setState(() {
      _controller.undo();
    });
  }

  Future<void> _onHint() async {
    if (_isAnimating ||
        _isHintLoading ||
        _controller.inputLocked ||
        _controller.solved) {
      return;
    }

    final requestId = ++_hintRequestId;
    final boardSnapshot = _controller.board;

    setState(() {
      _isHintLoading = true;
    });

    try {
      final result = await _controller.getHintAsync();

      if (!mounted ||
          _hintRequestId != requestId ||
          _controller.board != boardSnapshot) {
        // Discard stale result if user moved, undid, restarted, navigated, or screen disposed
        return;
      }

      setState(() {
        _isHintLoading = false;
      });

      if (result.isSolved && result.solution!.isNotEmpty) {
        final hint = result.solution!.first;
        AudioHapticService.instance.playSelect();
        setState(() {
          _hintSourceTube = hint.sourceTube;
          _hintDestTube = hint.destinationTube;
        });
      } else if (result.exceededBudget) {
        AudioHapticService.instance.playInvalid();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Search limit reached for this complex configuration!',
            ),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        AudioHapticService.instance.playInvalid();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No further moves or already solved!'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (_) {
      if (mounted && _hintRequestId == requestId) {
        setState(() {
          _isHintLoading = false;
        });
      }
    } finally {
      if (mounted && _hintRequestId == requestId && _isHintLoading) {
        setState(() {
          _isHintLoading = false;
        });
      }
    }
  }

  void _onAddTube() {
    if (_isAnimating || _controller.inputLocked || _controller.solved) return;
    _invalidateHint();
    final added = _controller.addEmptyTube();
    if (added) {
      AudioHapticService.instance.playSelect();
      setState(() {});
    } else {
      AudioHapticService.instance.playInvalid();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum chamber capacity reached (8)!'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void _onNextLevel() {
    _cancelAnimation();
    _invalidateHint();
    if (_currentLevelNumber < _effectiveMaxLevels) {
      setState(() {
        _currentLevelNumber++;
        _controller = GameController(
          initialBoard: LevelCatalog.getLevel(_currentLevelNumber),
        );
      });
      ProgressionService.instance.setCurrentLevel(_currentLevelNumber);
    }
  }

  void _onSelectLevelFromMap(int level) {
    _cancelAnimation();
    _invalidateHint();
    setState(() {
      _currentLevelNumber = level;
      _controller = GameController(
        initialBoard: LevelCatalog.getLevel(_currentLevelNumber),
      );
      _currentNavIndex = 0; // Return to Play screen
    });
    ProgressionService.instance.setCurrentLevel(_currentLevelNumber);
  }

  void _handleBackNavigation() {
    // 1. If currently viewing Map (1) or Shop (2), back returns to Play (0)
    if (_currentNavIndex != 0) {
      setState(() => _currentNavIndex = 0);
      return;
    }

    // 2. If in active play and moves have been made and not yet solved:
    if (_controller.moveCount > 0 && !_controller.solved) {
      _showPauseModal();
      return;
    }

    // 3. Otherwise, if Navigator can pop, pop back to HomeScreen
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  void _showPauseModal() {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withAlpha(180),
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: GameTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: GameTheme.cyanAccent.withAlpha(80),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: GameTheme.cyanAccent.withAlpha(40),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: GameTheme.cyanAccent.withAlpha(30),
                    border: Border.all(
                      color: GameTheme.cyanAccent.withAlpha(80),
                    ),
                  ),
                  child: const Icon(
                    Icons.pause_rounded,
                    color: GameTheme.cyanAccent,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'MISSION PAUSED',
                  style: TextStyle(
                    color: GameTheme.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sector $_currentLevelNumber containment in progress.\nMoves made: ${_controller.moveCount}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: GameTheme.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                // Resume Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    key: const Key('pause_resume_button'),
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GameTheme.cyanAccent,
                      foregroundColor: GameTheme.background,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'RESUME MISSION',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Restart Level
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton(
                    key: const Key('pause_restart_button'),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _onRestart();
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: GameTheme.violetAccent.withAlpha(90),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'RESTART CHAMBER',
                      style: TextStyle(
                        color: GameTheme.violetAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Lab Settings
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton.icon(
                    key: const Key('pause_settings_button'),
                    icon: const Icon(
                      Icons.settings_outlined,
                      size: 16,
                      color: GameTheme.cyanAccent,
                    ),
                    label: const Text(
                      'LAB SETTINGS',
                      style: TextStyle(
                        color: GameTheme.cyanAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        letterSpacing: 0.8,
                      ),
                    ),
                    onPressed: () {
                      AudioHapticService.instance.playSelect();
                      SettingsSheet.show(context);
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: GameTheme.cyanAccent.withAlpha(90),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Exit to Menu
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: TextButton(
                    key: const Key('pause_exit_button'),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text(
                      'EXIT TO HEADQUARTERS',
                      style: TextStyle(
                        color: GameTheme.textTertiary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    // If Levels or Shop tab is active, render their screens
    if (_currentNavIndex == 1) {
      content = Stack(
        children: [
          LevelMapScreen(
            currentLevel: _currentLevelNumber,
            onSelectLevel: _onSelectLevelFromMap,
          ),
          _buildBottomNavBar(),
        ],
      );
    } else if (_currentNavIndex == 2) {
      content = Stack(children: [const ShopScreen(), _buildBottomNavBar()]);
    } else {
      final board = _controller.board;
      final isSolved = _controller.solved && !_isAnimating;
      final hasNextLevel = _currentLevelNumber < _effectiveMaxLevels;

      content = Scaffold(
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
                    onHome: _handleBackNavigation,
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
                            _hintSourceTube != null && _hintDestTube != null
                                ? 'Hint: Transfer Chamber ${_hintSourceTube! + 1} -> ${_hintDestTube! + 1}'
                                : (_controller.selectedTubeIndex != null
                                      ? 'Select target containment chamber'
                                      : (_currentLevelNumber == 1 &&
                                                _controller.moveCount == 0
                                            ? 'MISSION INIT: Tap chamber to extract orbs'
                                            : (_currentLevelNumber == 2 &&
                                                      _controller.moveCount == 0
                                                  ? 'QUANTUM TIP: Matching adjacent orbs move together'
                                                  : (_currentLevelNumber == 3 &&
                                                            _controller.moveCount == 0
                                                        ? 'GOAL: Group identical energy orbs to stabilize'
                                                        : 'Select chamber to transfer energy orb')))),
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

                      // Height based ball size: tube total vertical space is (4 * ballSize + 56) + 28 (text+platform+paddings)
                      final double targetBallSizeHeight =
                          (availableHeight - 88) / 4.25;

                      final double computedBallSize = math
                          .min(targetBallSizeWidth, targetBallSizeHeight)
                          .clamp(18.0, 52.0);
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
                                              isHinted:
                                                  _hintSourceTube == i ||
                                                  _hintDestTube == i,
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
                                  const SizedBox(height: 6),
                                  // Orb Lab Containment Docking Deck Platform
                                  Container(
                                    width: math.min(
                                      availableWidth - 32,
                                      (board.tubeCount *
                                          (computedBallSize + 22.0)),
                                    ),
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1B2A4B),
                                      borderRadius: BorderRadius.circular(2),
                                      border: Border.all(
                                        color: const Color(0xFF49DCEC)
                                            .withAlpha(50),
                                        width: 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF49DCEC)
                                              .withAlpha(30),
                                          blurRadius: 8,
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
                  onAddTube: _onAddTube,
                  onHint: _onHint,
                  canUndo: _controller.canUndo && !_isAnimating,
                  canRestart: !_isAnimating,
                  canAddTube: _controller.board.tubeCount < 8 && !_isAnimating,
                  canHint: !_isAnimating && !_isHintLoading,
                  isHintLoading: _isHintLoading,
                ),

                const SizedBox(height: 8),

                // Reserve space for Bottom Navigation Bar
                const SizedBox(height: 54),
              ],
            ),

            // Celebration Particles
            if (isSolved) const Positioned.fill(child: CelebrationParticles()),

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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        _handleBackNavigation();
      },
      child: content,
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
              onTap: () {
                if (_currentNavIndex != 0) {
                  setState(() => _currentNavIndex = 0);
                }
              },
            ),
            _NavItem(
              icon: Icons.map,
              label: 'Levels',
              isActive: _currentNavIndex == 1,
              onTap: () {
                _cancelAnimation();
                _invalidateHint();
                setState(() => _currentNavIndex = 1);
              },
            ),
            _NavItem(
              icon: Icons.shopping_bag,
              label: 'Shop',
              isActive: _currentNavIndex == 2,
              onTap: () {
                _cancelAnimation();
                _invalidateHint();
                setState(() => _currentNavIndex = 2);
              },
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
