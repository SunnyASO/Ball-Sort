import 'package:shared_preferences/shared_preferences.dart';

import 'audio_haptic_service.dart';

/// Manages level unlock progression, star ratings, best moves, and user preferences.
///
/// Implements dual-layer storage: synchronous memory cache for instantaneous UI access
/// backed by persistent [SharedPreferences].
class ProgressionService {
  static final ProgressionService instance = ProgressionService._internal();

  ProgressionService._internal();

  SharedPreferences? _prefs;

  int _highestUnlockedLevel = 1;
  int _currentLevel = 1;
  final Map<int, int> _stars = {};
  final Map<int, int> _bestMoves = {};
  bool _soundEnabled = true;
  bool _hapticsEnabled = true;

  int get highestUnlockedLevel => _highestUnlockedLevel;
  int get currentLevel => _currentLevel;
  bool get soundEnabled => _soundEnabled;
  bool get hapticsEnabled => _hapticsEnabled;

  /// Total stars earned across all levels.
  int get totalStars => _stars.values.fold(0, (sum, s) => sum + s);

  /// Initializes the service from persistent storage.
  Future<void> initialize({SharedPreferences? mockPrefs}) async {
    _prefs = mockPrefs ?? await SharedPreferences.getInstance();

    _highestUnlockedLevel = _prefs?.getInt('highestUnlockedLevel') ?? 1;
    _currentLevel = _prefs?.getInt('currentLevel') ?? 1;
    _soundEnabled = _prefs?.getBool('soundEnabled') ?? true;
    _hapticsEnabled = _prefs?.getBool('hapticsEnabled') ?? true;
    AudioHapticService.instance.soundEnabled = _soundEnabled;
    AudioHapticService.instance.hapticsEnabled = _hapticsEnabled;

    // Load stars and best moves
    for (int i = 1; i <= 50; i++) {
      final star = _prefs?.getInt('stars_level_$i');
      if (star != null) {
        _stars[i] = star;
      }
      final best = _prefs?.getInt('best_moves_level_$i');
      if (best != null) {
        _bestMoves[i] = best;
      }
    }
  }

  /// Sets the currently active level.
  Future<void> setCurrentLevel(int level) async {
    _currentLevel = level;
    await _prefs?.setInt('currentLevel', level);
  }

  /// Retrieves the star rating for [level] (0 to 3).
  int getStars(int level) {
    return _stars[level] ?? 0;
  }

  /// Retrieves the best move count achieved for [level], or `null` if unplayed.
  int? getBestMoves(int level) {
    return _bestMoves[level];
  }

  /// Checks if a level is unlocked.
  bool isLevelUnlocked(int level) {
    return level <= _highestUnlockedLevel;
  }

  /// Records a level completion.
  ///
  /// Computes stars based on [moves] vs [parMoves]:
  /// - 3 stars: moves <= parMoves
  /// - 2 stars: moves <= parMoves + 4
  /// - 1 star: completed
  Future<int> recordLevelCompletion({
    required int level,
    required int moves,
    int parMoves = 10,
  }) async {
    int earnedStars = 1;
    if (moves <= parMoves) {
      earnedStars = 3;
    } else if (moves <= parMoves + 4) {
      earnedStars = 2;
    }

    final currentStars = _stars[level] ?? 0;
    if (earnedStars > currentStars) {
      _stars[level] = earnedStars;
      await _prefs?.setInt('stars_level_$level', earnedStars);
    }

    final currentBest = _bestMoves[level];
    if (currentBest == null || moves < currentBest) {
      _bestMoves[level] = moves;
      await _prefs?.setInt('best_moves_level_$level', moves);
    }

    // Unlock next level
    if (level >= _highestUnlockedLevel) {
      _highestUnlockedLevel = level + 1;
      await _prefs?.setInt('highestUnlockedLevel', _highestUnlockedLevel);
    }

    return earnedStars;
  }

  /// Toggles sound effects.
  Future<void> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    AudioHapticService.instance.soundEnabled = enabled;
    await _prefs?.setBool('soundEnabled', enabled);
  }

  /// Toggles haptic feedback.
  Future<void> setHapticsEnabled(bool enabled) async {
    _hapticsEnabled = enabled;
    AudioHapticService.instance.hapticsEnabled = enabled;
    await _prefs?.setBool('hapticsEnabled', enabled);
  }

  /// Resets progression data for testing or player reset.
  Future<void> resetAll() async {
    _highestUnlockedLevel = 1;
    _currentLevel = 1;
    _stars.clear();
    _bestMoves.clear();
    _soundEnabled = true;
    _hapticsEnabled = true;
    AudioHapticService.instance.soundEnabled = true;
    AudioHapticService.instance.hapticsEnabled = true;
    await _prefs?.clear();
  }
}
