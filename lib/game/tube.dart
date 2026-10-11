import 'package:flutter/foundation.dart';

import 'ball_type.dart';

/// Represents a single tube in the Ball Sort puzzle.
/// Balls are ordered bottom to top:
/// - index 0 is the bottom ball
/// - last index is the top ball
@immutable
class Tube {
  /// Default tube capacity according to game specifications.
  static const int defaultCapacity = 4;

  final int capacity;
  final List<BallType> _balls;

  /// Creates a [Tube] with a specified [capacity] and initial [balls].
  ///
  /// Throws [ArgumentError] if [capacity] is less than or equal to 0,
  /// or if initial balls count exceeds [capacity].
  Tube({this.capacity = defaultCapacity, Iterable<BallType> balls = const []})
    : _balls = List.unmodifiable(balls) {
    if (capacity <= 0) {
      throw ArgumentError.value(
        capacity,
        'capacity',
        'Tube capacity must be greater than 0',
      );
    }
    if (_balls.length > capacity) {
      throw ArgumentError(
        'Initial balls count (${_balls.length}) exceeds tube capacity ($capacity)',
      );
    }
  }

  /// An unmodifiable view or list of balls from bottom (index 0) to top.
  List<BallType> get balls => _balls;

  /// Number of balls currently in the tube.
  int get count => _balls.length;

  /// Whether the tube has no balls.
  bool get isEmpty => _balls.isEmpty;

  /// Whether the tube has reached its maximum capacity.
  bool get isFull => _balls.length >= capacity;

  /// Returns the top ball (last index), or `null` if the tube is empty.
  BallType? get topBall => _balls.isEmpty ? null : _balls.last;

  /// Remaining space in the tube.
  int get availableSpace => capacity - _balls.length;

  /// Number of contiguous balls matching the top ball at the top of the tube.
  /// Returns 0 if tube is empty.
  int get topMatchingCount {
    if (_balls.isEmpty) return 0;
    final target = _balls.last;
    int count = 0;
    for (int i = _balls.length - 1; i >= 0; i--) {
      if (_balls[i] == target) {
        count++;
      } else {
        break;
      }
    }
    return count;
  }

  /// Whether the tube is considered complete for victory evaluation:
  /// - An empty tube is complete.
  /// - A non-empty tube is complete ONLY when it is full and all balls have the same type.
  /// Partially filled monochrome tubes are NOT complete.
  bool get isComplete {
    if (isEmpty) return true;
    if (!isFull) return false;
    final first = _balls.first;
    for (var i = 1; i < _balls.length; i++) {
      if (_balls[i] != first) return false;
    }
    return true;
  }

  /// Creates a copy of this tube with optional overrides.
  Tube copyWith({int? capacity, Iterable<BallType>? balls}) {
    return Tube(capacity: capacity ?? this.capacity, balls: balls ?? _balls);
  }

  /// Returns a new Tube with [ball] added to the top.
  /// Throws [StateError] if the tube is already full.
  Tube push(BallType ball) {
    if (isFull) {
      throw StateError('Cannot push ball into a full tube');
    }
    return Tube(capacity: capacity, balls: [..._balls, ball]);
  }

  /// Returns a new Tube with the top ball removed.
  /// Throws [StateError] if the tube is empty.
  Tube pop() {
    if (isEmpty) {
      throw StateError('Cannot pop ball from an empty tube');
    }
    return Tube(
      capacity: capacity,
      balls: _balls.sublist(0, _balls.length - 1),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Tube) return false;
    if (capacity != other.capacity || _balls.length != other._balls.length) {
      return false;
    }
    for (var i = 0; i < _balls.length; i++) {
      if (_balls[i] != other._balls[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(capacity, Object.hashAll(_balls));

  @override
  String toString() => 'Tube(capacity: $capacity, balls: $_balls)';
}
