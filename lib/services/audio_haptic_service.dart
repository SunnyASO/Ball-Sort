import 'package:flutter/services.dart';

/// Provides sound and haptic sensory feedback for game interactions.
///
/// Designed to be lightweight and crash-resilient across mobile and web platforms.
class AudioHapticService {
  static final AudioHapticService instance = AudioHapticService._internal();

  AudioHapticService._internal();

  bool soundEnabled = true;
  bool hapticsEnabled = true;

  /// Triggered when the player selects or deselects a containment chamber.
  Future<void> playSelect() async {
    if (hapticsEnabled) {
      await HapticFeedback.selectionClick();
    }
    if (soundEnabled) {
      await SystemSound.play(SystemSoundType.click);
    }
  }

  /// Triggered when energy orbs drop into their target chamber.
  Future<void> playTransferDrop() async {
    if (hapticsEnabled) {
      await HapticFeedback.lightImpact();
    }
    if (soundEnabled) {
      await SystemSound.play(SystemSoundType.click);
    }
  }

  /// Triggered when an entire chamber is successfully sorted and stabilized.
  Future<void> playTubeComplete() async {
    if (hapticsEnabled) {
      await HapticFeedback.mediumImpact();
    }
    if (soundEnabled) {
      await SystemSound.play(SystemSoundType.click);
    }
  }

  /// Triggered when an invalid move or locked interaction is attempted.
  Future<void> playInvalid() async {
    if (hapticsEnabled) {
      await HapticFeedback.lightImpact();
      await Future<void>.delayed(const Duration(milliseconds: 60));
      await HapticFeedback.lightImpact();
    }
  }

  /// Triggered when the player rewinds a move via Undo.
  Future<void> playUndo() async {
    if (hapticsEnabled) {
      await HapticFeedback.selectionClick();
    }
  }

  /// Triggered when the sector is reset via Restart.
  Future<void> playRestart() async {
    if (hapticsEnabled) {
      await HapticFeedback.mediumImpact();
    }
  }

  /// Triggered when the final containment protocol synchronizes (Victory).
  Future<void> playVictory() async {
    if (hapticsEnabled) {
      await HapticFeedback.heavyImpact();
    }
    if (soundEnabled) {
      await SystemSound.play(SystemSoundType.click);
    }
  }
}
