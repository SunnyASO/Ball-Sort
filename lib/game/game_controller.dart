import 'ball_move.dart';
import 'ball_sort_board.dart';
import 'board_solver.dart';
import 'move_validator.dart';
import 'tube.dart';

/// GameController coordinates game state, user tap interactions, and move history (undo).
///
/// Keeps game logic independent of Flutter widget lifecycle and rendering.
class GameController {
  final BallSortBoard initialBoard;
  final MoveValidator validator;
  final BoardSolver solver;

  BallSortBoard _board;
  int? _selectedTubeIndex;
  int _moveCount;
  bool _inputLocked;
  final List<BallMove> _moveHistory;

  GameController({
    required this.initialBoard,
    this.validator = const MoveValidator(),
    this.solver = const BoardSolver(),
  }) : _board = initialBoard,
       _selectedTubeIndex = null,
       _moveCount = 0,
       _inputLocked = false,
       _moveHistory = [];

  /// The current state of the board.
  BallSortBoard get board => _board;

  /// Currently selected tube index, or null if none selected.
  int? get selectedTubeIndex => _selectedTubeIndex;

  /// Number of successful moves performed in this session.
  int get moveCount => _moveCount;

  /// Whether the puzzle is solved.
  bool get solved => _board.isSolved;

  /// Whether user input is currently locked.
  bool get inputLocked => _inputLocked;

  /// An unmodifiable view of the move history stack.
  List<BallMove> get moveHistory => List.unmodifiable(_moveHistory);

  /// Whether an undo operation is currently possible.
  bool get canUndo => !_inputLocked && _moveHistory.isNotEmpty;

  /// Allows locking or unlocking input externally (e.g. for animations).
  void setInputLocked(bool locked) {
    _inputLocked = locked;
  }

  /// Calculates the next optimal move towards solving the current board.
  /// Returns `null` if the input is locked, the board is already solved,
  /// or no solution is reachable.
  BallMove? getHint() {
    if (_inputLocked || solved) {
      return null;
    }
    return solver.getNextOptimalMove(_board);
  }

  /// Handles player tapping a tube at [tubeIndex].
  ///
  /// Interaction Rules:
  /// 1. If [inputLocked] is true or game is already [solved], ignore input.
  /// 2. If [tubeIndex] is out of bounds, ignore input.
  /// 3. If NO tube is currently selected:
  ///    - Tapping a non-empty tube selects it.
  ///    - Tapping an empty tube does nothing.
  /// 4. If a tube is ALREADY selected:
  ///    - Tapping the selected tube deselects it.
  ///    - Tapping another tube:
  ///      - Attempt move from selectedTube -> tapped tube.
  ///      - If move is valid:
  ///        - Board updates once.
  ///        - Move count increments once.
  ///        - Move is pushed onto undo history.
  ///        - Selection clears.
  ///        - Returns the [BallMove] performed.
  ///      - If move is invalid:
  ///        - If the tapped tube is non-empty, switch selected tube to this tapped tube.
  ///        - If the tapped tube is empty, keep current selection.
  ///
  /// Returns the [BallMove] if a move was executed, or `null` otherwise.
  BallMove? handleTubeTap(int tubeIndex) {
    if (_inputLocked || solved) {
      return null;
    }

    if (!validator.isValidIndex(_board, tubeIndex)) {
      return null;
    }

    final tappedTube = _board.tubes[tubeIndex];

    // Case 1: Nothing currently selected
    if (_selectedTubeIndex == null) {
      if (!tappedTube.isEmpty) {
        _selectedTubeIndex = tubeIndex;
      }
      return null;
    }

    // Case 2: Tapping the currently selected tube
    if (_selectedTubeIndex == tubeIndex) {
      _selectedTubeIndex = null;
      return null;
    }

    // Case 3: Attempting a move from source to destination
    final sourceIndex = _selectedTubeIndex!;
    final destinationIndex = tubeIndex;

    final moveResult = _board.tryMove(
      sourceIndex,
      destinationIndex,
      validator: validator,
    );

    if (moveResult != null) {
      final (newBoard, move) = moveResult;
      _board = newBoard;
      _moveCount++;
      _moveHistory.add(move);
      _selectedTubeIndex = null;
      return move;
    }

    // Move is invalid:
    // If tapping another non-empty tube produces an invalid destination move,
    // switch source selection to that tube.
    if (!tappedTube.isEmpty) {
      _selectedTubeIndex = tubeIndex;
    }

    return null;
  }

  /// Reverses the most recent successful move in LIFO order.
  ///
  /// Requirements:
  /// - Restores both tubes to their previous configurations.
  /// - Decrements move count by one.
  /// - Removes the corresponding history entry.
  /// - Does not count as a forward move.
  /// - Does not add another entry to history.
  /// - Clears current selection.
  /// - Blocked when [inputLocked] is true or history is empty.
  /// - If the game was in a solved state, undo restores the previous unsolved state.
  ///
  /// Returns the reversed [BallMove] if undone, or `null` if no undo occurred.
  BallMove? undo() {
    if (_inputLocked || _moveHistory.isEmpty) {
      return null;
    }

    final lastMove = _moveHistory.removeLast();
    final sourceIndex = lastMove.sourceTube;
    final destIndex = lastMove.destinationTube;
    final count = lastMove.ballsMoved;

    final destTube = _board.tubes[destIndex];
    final sourceTube = _board.tubes[sourceIndex];

    // Take the top `count` balls from destination and restore them back onto source.
    // In a grouped move, all `count` balls are contiguous and identical in color.
    // If lastMove.movedBalls is available, we preserve the exact list.
    final returningBalls = lastMove.movedBalls.isNotEmpty
        ? lastMove.movedBalls
        : destTube.balls.sublist(destTube.balls.length - count);

    final updatedDestBalls = destTube.balls.sublist(
      0,
      destTube.balls.length - count,
    );
    final updatedDest = destTube.copyWith(balls: updatedDestBalls);

    final updatedSourceBalls = [...sourceTube.balls, ...returningBalls];
    final updatedSource = sourceTube.copyWith(balls: updatedSourceBalls);

    final updatedTubes = List<Tube>.of(_board.tubes);
    updatedTubes[sourceIndex] = updatedSource;
    updatedTubes[destIndex] = updatedDest;

    _board = BallSortBoard(updatedTubes);
    _moveCount--;
    _selectedTubeIndex = null;

    return lastMove;
  }

  /// Restores the exact original board, clears selection, resets move count,
  /// clears move history, and unlocks input.
  void restart() {
    _board = initialBoard;
    _selectedTubeIndex = null;
    _moveCount = 0;
    _moveHistory.clear();
    _inputLocked = false;
  }

  /// Adds a new empty helper containment chamber to the board if under maximum limit (8).
  /// Returns `true` if added successfully.
  bool addEmptyTube({int capacity = 4}) {
    if (_inputLocked || solved || _board.tubeCount >= 8) {
      return false;
    }
    final newTubes = List<Tube>.from(_board.tubes)
      ..add(Tube(capacity: capacity));
    _board = BallSortBoard(newTubes);
    _selectedTubeIndex = null;
    return true;
  }
}
