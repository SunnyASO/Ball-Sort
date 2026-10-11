# BALL SORT — MASTER DEVELOPMENT PLAN

**Project Type:** Hypercasual / Puzzle  
**Primary Framework:** Flutter  
**Target Platform:** Android first, iOS second  
**Rendering Approach:** Pure Flutter initially  
**Backend:** None for V1  
**Game Engine:** None required for V1  
**Primary Input:** Tap source tube → tap destination tube  
**Core Principle:** Deterministic puzzle state, simple legal-move rules, reliable animation/state separation

---

# 1. Executive Summary

This project is an original Ball Sort-style puzzle game built in Flutter.

The game will study existing repositories to understand mechanics, controls, state modeling, legal move validation, solving strategies, level generation ideas, and Flutter architecture. It will **not** copy branding, artwork, UI, levels, sound, app identity, or commercial presentation from those repositories.

The player sees multiple containers holding colored balls or themed objects. Each container has a fixed capacity. The goal is to reorganize the pieces until every non-empty container contains only one color/type.

The first playable version should remain intentionally small and technically safe:

- 6 handcrafted levels
- 2–5 colors
- fixed tube capacity
- 2 helper/empty tubes where appropriate
- tap source → tap destination controls
- legal move validation
- restart
- undo
- win detection
- simple ball transfer animation
- no backend
- no ads
- no complex level generator initially
- no drag-and-drop initially

The main engineering risk is not the puzzle logic. The main risk is **animation and game-state synchronization**. Therefore, the architecture must strictly separate logical state from rendering and animation.

---

# 2. Project Objectives

## 2.1 Primary Goal

Create a polished, reliable, low-risk Ball Sort puzzle game in Flutter with clean game-state logic and simple mobile controls.

## 2.2 Secondary Goals

- Keep the codebase small and understandable.
- Make all move validation deterministic.
- Ensure puzzle logic is unit-testable without UI.
- Separate logical ball state from animation state.
- Support handcrafted levels first.
- Support solver-verified generated levels later.
- Make the visual theme original rather than using generic glass tubes.
- Keep the project suitable for future hints, progression, ads, themes, and level generation.

## 2.3 Non-Goals for V1

Do not build initially:

- drag-and-drop
- physics
- realistic ball collisions
- backend accounts
- cloud saves
- leaderboards
- multiplayer
- ads
- shops
- currencies
- daily rewards
- procedural level generation
- advanced AI systems
- 3D rendering
- complex state management frameworks
- hundreds of levels before core gameplay is proven

---

# 3. Reference Repository Strategy

The repositories below are learning references only unless the license clearly permits reuse.

## 3.1 Primary Solver Reference — `tjwood100/ball-sort-puzzle-solver`

**Repository:**  
https://github.com/tjwood100/ball-sort-puzzle-solver

**License:** MIT

**Use for:**
- board representation
- tube-array representation
- legal state reasoning
- depth-first backtracking
- visited-state handling
- solver design
- solvability validation
- future level generation validation

The MIT license makes this the safest logic reference.

## 3.2 Flutter Logic Reference — `SarahAlghadir/ball-sort`

**Repository:**  
https://github.com/SarahAlghadir/ball-sort

**License Status:** No clear LICENSE file found during review.

**Use for reference only:**
- Dart model separation
- `Tube`
- `Board`
- `Move`
- search strategies
- user move handling
- Flutter UI organization

**Do not copy source into the commercial project unless licensing is later verified.**

## 3.3 Modern Flutter Product Reference — `M-danish05/Ball-Sort-Nix`

**Repository:**  
https://github.com/M-danish05/Ball-Sort-Nix

**License Status:** No permissive LICENSE found; README states all rights reserved.

**Use for reference only:**
- product feature ideas
- progress saving
- themes
- undo/restart
- sound
- generated level concept
- mobile UX
- offline-first product structure

**Do not copy source, art, levels, or commercial presentation.**

---

# 4. Licensing Rules

For every third-party reference:

1. Verify the license before reusing code.
2. MIT/Apache/BSD code may be reused only under their license terms.
3. Any reused or adapted licensed code must be documented in `THIRD_PARTY_NOTICES.md`.
4. Repositories without a clear license are **study-only**.
5. Do not reuse artwork, tube designs, ball art, UI layouts, audio, branding, levels, app icons, or screenshots.
6. Our game must have original theme, visuals, UI, levels, branding, sounds, and progression.

---

# 5. Core Game Concept

The board contains multiple tubes or containers.

Each tube:
- has a fixed capacity
- contains an ordered stack of ball types/colors
- may be empty
- may be partially filled
- may be complete when full and monochrome

The player chooses a source tube, then a destination tube.

If the move is legal, the top ball or top same-color group transfers.

The puzzle is solved when every non-empty tube is complete.

---

# 6. Core Interaction Model

## 6.1 Primary Control

Recommended V1:

```text
tap source tube
→ source becomes selected
→ top ball lifts slightly

tap destination tube
→ validate move
```

If valid:

```text
animate transfer
→ update board
→ check victory
```

If invalid:

```text
shake destination or selected ball
→ no board change
```

## 6.2 Deselect

If the selected source tube is tapped again, deselect it.

## 6.3 Change Selection

If a player taps another non-empty source before choosing a destination, selection changes to the new source.

## 6.4 Restart

Restores the original level state.

## 6.5 Undo

Undo should be added early because the move model is simple and deterministic.

---

# 7. Why We Should Avoid Drag-and-Drop Initially

Drag-and-drop adds gesture tracking, hit testing, global coordinates, drag cancellation, overlapping touch states, invalid drop handling, animation conflicts, and state desynchronization risk.

Tap-to-select is safer and easier for Antigravity to implement correctly.

Drag may be added later as an optional alternate input only after the game is stable.

---

# 8. Core Data Model

The puzzle state must not depend on Flutter widgets.

## 8.1 Ball Type

For logic, balls only need a type/color ID.

```dart
enum BallType {
  red,
  blue,
  yellow,
  green,
  purple,
}
```

The logical state should not store absolute screen coordinates.

## 8.2 Tube

```dart
class Tube {
  final int capacity;
  final List<BallType> balls;
}
```

Convention:

```text
index 0 = bottom
last index = top
```

This must remain consistent throughout the codebase.

## 8.3 Board

```dart
class BallSortBoard {
  final List<Tube> tubes;
}
```

## 8.4 Move

```dart
class BallMove {
  final int sourceTube;
  final int destinationTube;
  final List<BallType> ballsMoved;
}
```

For single-ball V1, `ballsMoved.length == 1`.

---

# 9. Basic Legal Move Rules

A move is legal only if:

```text
source is not empty
AND destination is not full
AND
(
  destination is empty
  OR destination top type == source top type
)
```

Reject a move if:

```text
source == destination
source empty
destination full
destination top color differs
input locked
game already solved
```

---

# 10. Single-Ball vs Grouped Transfer

## 10.1 Single-Ball Transfer

Move one top ball at a time.

Advantages:
- simplest
- easiest to test
- easiest animation
- easiest undo

Recommended for Phase 0/1.

## 10.2 Grouped Transfer

If the top several balls have the same color, transfer as many as will fit.

This generally feels better commercially and should be added only after the single-ball system is stable.

---

# 11. Group Detection Logic

For grouped movement:

1. Read top ball type.
2. Count contiguous top balls with same type.
3. Determine destination free slots.
4. Transfer the minimum of matching top count and free capacity.

Only perform if destination is empty or its top matches the same type.

---

# 12. Victory Condition

A tube is complete if:

```text
tube is empty
OR
(
  tube.length == capacity
  AND all balls have same type
)
```

The board is solved when every tube satisfies this rule.

---

# 13. Game State Separation

Critical rule:

> The board model owns truth. Animations only visualize already-approved moves.

Recommended flow:

```text
player input
↓
GameController validates
↓
input locked
↓
move recorded
↓
logical state updated
↓
animation plays
↓
input unlocked
↓
victory checked
```

---

# 14. Input Locking

During transfer animation:

```text
inputLocked = true
```

After animation:

```text
inputLocked = false
```

unless the game is solved.

---

# 15. Animation Architecture

Use one central animation coordinator.

Do not let each tube independently decide where balls should move.

Recommended concept:

```text
GameController
    ↓
MoveAnimationCoordinator
    ↓
render temporary moving ball
    ↓
complete
```

A moved ball may visually travel up from source, horizontally toward destination, then down into destination.

---

# 16. Recommended Flutter Animation Tools

Possible options:
- `AnimatedPositioned`
- `TweenAnimationBuilder`
- `AnimationController`
- `Overlay`
- `Stack`

Recommended V1:

```text
Stack + AnimationController
```

Do not introduce a game engine.

---

# 17. Tube Rendering

The visual tube/container should be separate from the logical tube.

Recommended structure:

```text
TubeWidget
├── container shell
├── stacked ball visuals
└── selection highlight
```

---

# 18. Original Visual Direction

Do not make another generic glass-tube clone.

Possible themes:
- Orb Lab
- Creature Sort
- Candy Jars
- Planet Sort
- Fruit Cups

Recommended direction:

**Orb Lab**

Reason:
- original enough to differentiate
- easy vector shapes
- easy glow effects
- works well in Flutter
- can share visual philosophy with Circuit Flow if both projects are developed later

---

# 19. Selection Feedback

When a source tube is selected:
- top ball lifts slightly
- selected tube border highlights
- optional glow/pulse

Represent selection separately:

```dart
int? selectedTubeIndex;
```

---

# 20. Invalid Move Feedback

If destination is invalid:
- small shake
- brief error highlight
- no board-state mutation

Sound and haptics come later.

---

# 21. Undo System

Recommended history:

```dart
List<BallMove> moveHistory;
```

Undo:
- pop last move
- reverse source/destination
- restore `ballsMoved`
- update board

Grouped transfer should still undo as one move.

---

# 22. Restart System

Each level preserves an immutable starting configuration.

Restart should:
- restore starting tubes
- clear selection
- clear move history
- reset move count
- clear solved state
- cancel animation
- unlock input

---

# 23. Level Data Model

```dart
class BallSortLevel {
  final int tubeCapacity;
  final List<List<BallType>> startingTubes;
}
```

Optional later:
- level number
- par moves
- difficulty
- theme

---

# 24. Prototype Level Plan

## Level 1
- 2 colors
- capacity 4
- 4 tubes total
- 2 empty helper tubes
- tutorial/easy

## Level 2
- 3 colors
- 5 tubes
- 2 empty tubes
- simple mixing

## Level 3
- 3 colors
- 5 tubes
- more fragmented arrangement

## Level 4
- 4 colors
- 6 tubes

## Level 5
- 5 colors
- 7 tubes

## Level 6
- 5 colors
- 7 tubes
- full prototype challenge

All prototype levels should be handcrafted and manually verified.

---

# 25. Level Integrity Rules

Every level must satisfy:

```text
all tubes <= capacity
all colors appear exactly capacity times
at least one valid move at start
level is not already solved
level is solvable
```

For classic configuration:

```text
number of colors = number of filled tubes
helper tubes = usually 2
```

---

# 26. Level Generation Strategy — Later

Do not randomly scatter balls without verification.

Recommended future approach:

```text
start from solved state
↓
apply controlled reverse-mixing operations
↓
create scrambled state
↓
run solver
↓
accept only if solvable
↓
measure difficulty
```

---

# 27. Solver Strategy — Later

Use a search-based solver.

The MIT reference uses recursive depth-first backtracking with visited-state detection.

Potential future improvements:
- canonical state signatures
- prune immediate reversals
- avoid useless complete-tube moves
- prioritize useful color merges

Do not build the full solver in the first milestone.

---

# 28. Difficulty Metrics — Later

Potential factors:
- number of colors
- number of helper tubes
- color fragmentation
- minimum solution length
- branching factor
- number of tempting wrong moves
- solver search depth
- solver node count

---

# 29. Suggested File Structure

```text
lib/
├── main.dart
├── game/
│   ├── ball_type.dart
│   ├── tube.dart
│   ├── ball_move.dart
│   ├── ball_sort_board.dart
│   ├── move_validator.dart
│   ├── game_controller.dart
│   └── board_solver.dart          # later
├── levels/
│   └── prototype_levels.dart
├── screens/
│   └── game_screen.dart
├── widgets/
│   ├── tube_widget.dart
│   ├── ball_widget.dart
│   ├── move_animation_layer.dart
│   └── game_header.dart
├── theme/
│   └── game_theme.dart
└── utils/
    └── game_constants.dart
```

---

# 30. State Management

Keep V1 simple.

Recommended:
- `ChangeNotifier`
- `ValueNotifier`
- small controller + `StatefulWidget`

Avoid initially:
- BLoC
- Riverpod
- Redux
- service locators
- heavy dependency injection

---

# 31. Unit Testing Plan

## Move Validation

```text
cannot move from empty tube
cannot move to full tube
can move to empty tube
can move onto matching color
cannot move onto different color
cannot move to same tube
```

## State Mutation

```text
valid move removes correct top ball
valid move adds ball to destination
invalid move changes nothing
```

## Victory

```text
fully sorted board = solved
partially sorted board = not solved
mixed full tube = not solved
empty helper tube allowed
```

## Undo

```text
undo restores previous state
undo restores move count
grouped undo restores all moved balls
```

## Restart

```text
restart restores initial tubes
restart clears history
restart clears selection
restart clears solved state
```

## Level Integrity

```text
correct color counts
capacity respected
not solved at start
solvable
```

---

# 32. Runtime Edge Cases

Handle explicitly:
- tapping empty tube first
- tapping selected tube again
- selecting another source
- destination full
- destination wrong color
- very fast repeated taps
- tap during animation
- restart during animation
- undo during animation
- victory during transfer
- final level complete
- app resume during animation

---

# 33. Move Counting

Recommended:

```text
each successful transfer = 1 move
invalid taps = 0 moves
selection changes = 0 moves
undo does not count as a forward move
```

Grouped transfer counts as one move.

---

# 34. Animation Timing

Initial recommendation:

```text
lift: 80–120 ms
horizontal transfer: 140–220 ms
drop: 100–150 ms
```

Total: roughly 300–450 ms.

Keep it responsive.

---

# 35. Game Feel — Later

After mechanics are stable:
- ball squash on landing
- tube selection glow
- valid destination highlight
- invalid shake
- soft haptics
- satisfying drop sounds
- win confetti
- subtle particles
- tube completion pulse

---

# 36. Audio and Haptics — Later Phase

Potential sounds:
- select
- pickup
- drop
- invalid
- undo
- restart
- tube completed
- victory

Potential haptics:
- light on select
- light on drop
- medium on win

Do not add in Phase 0.

---

# 37. Progression — Later

Potential systems:
- level unlocks
- level packs
- stars
- best moves
- daily puzzle
- streaks
- themes
- cosmetic ball skins
- special containers

Keep progression outside the core board model.

---

# 38. Monetization — Deferred

Do not add monetization until:
- core game feels good
- at least 20–30 levels exist
- undo/hint systems are stable
- visual identity is polished
- progression is implemented
- crash/state issues are resolved

Possible later monetization:

```text
rewarded:
hint
extra empty tube
skip level

interstitial:
between level groups

IAP:
remove ads
theme packs
```

---

# 39. Persistence — Later

Use `shared_preferences` initially.

Potential saved data:
- highest unlocked level
- current level
- sound enabled
- haptics enabled
- theme
- best moves
- stars

No database required for V1.

---

# 40. Performance Principles

Flutter should handle this game easily.

Rules:
- avoid rebuilding unrelated widgets
- use const widgets where possible
- keep tube count reasonable
- avoid excessive blur
- avoid large images
- centralize transfer animation
- do not animate every ball continuously
- use `RepaintBoundary` where useful
- keep state immutable where practical

---

# 41. Prototype Acceptance Criteria

The first playable prototype is approved only when:
- app launches cleanly
- one handcrafted level loads
- source tube selection works
- destination selection works
- valid moves transfer correctly
- invalid moves are rejected
- logical state and visual state remain synchronized
- input locks during transfer
- victory triggers exactly once
- restart works
- undo works
- no duplicate balls appear
- no balls disappear incorrectly
- no drag system exists
- no backend exists
- unit tests pass
- zero red/runtime errors

---

# 42. Development Phases

## Phase 0 — Core Logic
Build:
- BallType
- Tube
- Board
- Move
- move validation
- single-ball transfer
- victory detection
- unit tests

## Phase 1 — Playable Screen
Add:
- Flutter GameScreen
- TubeWidget
- tap source
- tap destination
- selection state
- one handcrafted level
- restart

## Phase 2 — Undo + Six Levels
Add:
- move history
- undo
- six handcrafted levels
- next-level flow

## Phase 3 — Transfer Animation
Add:
- central animation coordinator
- input locking
- lift / move / drop animation
- invalid move feedback

## Phase 4 — Grouped Movement
Add:
- contiguous same-color detection
- multi-ball transfer
- grouped undo
- tests

## Phase 5 — Original Visual Identity
Build original presentation.

Recommended direction: **Orb Lab**

## Phase 6 — Audio, Haptics, Celebration
Add:
- sound
- haptics
- tube completion effect
- win animation

## Phase 7 — Progression
Add:
- saved progress
- larger level set
- best moves
- difficulty tiers

## Phase 8 — Solver / Generator
Add:
- solver
- solvability validation
- reverse-generation pipeline
- hints

## Phase 9 — Monetization
Only after product quality is proven.

---

# 43. Antigravity Development Discipline

## 43.1 Small Milestones

Never ask Antigravity to build the whole game in one prompt.

Use tasks like:

```text
Task 1:
Build Tube, Board, Move, validator, tests.

Task 2:
Build one playable screen.

Task 3:
Add restart and undo.

Task 4:
Add transfer animation.

Task 5:
Add grouped movement.
```

## 43.2 Verification Requirements

Every milestone should report:
- files created
- files modified
- architecture
- tests added
- test results
- manual verification steps
- known risks

## 43.3 Git Discipline

Suggested commits:

```text
feat(core): add ball sort board and move rules
feat(game): add first playable ball sort level
feat(game): add undo and restart
feat(ui): add ball transfer animation
feat(levels): add prototype level set
```

## 43.4 Freeze Stable Logic

Once stable, avoid casual changes to:
- tube indexing convention
- move validation
- board mutation
- win detection
- undo reversal

Only change them for verified regressions.

---

# 44. First Antigravity Milestone

The first milestone should be intentionally small.

## Scope

Build:
- Flutter app
- one handcrafted level
- `BallType`
- `Tube`
- `BallMove`
- `BallSortBoard`
- move validator
- single-ball moves
- victory detection
- tap source / tap destination
- restart
- basic selection feedback
- tests

Do not build:
- drag/drop
- grouped movement
- solver
- level generator
- ads
- audio
- haptics
- shop
- coins
- daily rewards
- themes
- advanced progression

---

# 45. First Milestone Verification Checklist

```text
[ ] level visible
[ ] correct tube capacity
[ ] top ball selection works
[ ] valid move accepted
[ ] invalid move rejected
[ ] source cannot be empty
[ ] destination cannot be full
[ ] color rule enforced
[ ] state updates exactly once
[ ] no duplicate balls
[ ] no missing balls
[ ] restart works
[ ] solved board detected
[ ] move count correct
[ ] unit tests green
```

---

# 46. Recommended First Technical Prompt for Antigravity

```text
PROJECT:
Ball Sort

FRAMEWORK:
Flutter

GOAL:
Build only the deterministic technical foundation for a Ball Sort puzzle.

DO NOT:
- add ads
- add backend
- add audio
- add haptics
- add drag-and-drop
- add procedural generation
- add solver yet
- add grouped multi-ball movement yet
- add complex art
- add Flame
- add complex state-management frameworks

IMPLEMENT:

1. BallType enum with at least:
   red
   blue
   yellow

2. Tube model:
   - fixed capacity = 4
   - balls stored bottom-to-top
   - helper methods:
     isEmpty
     isFull
     topBall
     isComplete

3. BallMove model:
   - sourceTube
   - destinationTube
   - ballsMoved

4. BallSortBoard:
   - list of tubes
   - immutable starting state
   - current state copy
   - move count

5. MoveValidator:
   legal only when:
   - source != destination
   - source not empty
   - destination not full
   - destination empty OR destination top color == source top color

6. Single-ball move execution.

7. Board solved check:
   every tube is either empty OR full with one color.

8. GameController:
   - selectedTubeIndex
   - selectTube()
   - tryMove()
   - restart()
   - solved
   - inputLocked

9. One handcrafted prototype level.

10. Minimal GameScreen:
    - display tubes
    - tap source
    - tap destination
    - selected source highlighted
    - simple immediate move, no fancy transfer animation yet
    - restart button
    - solved message

11. Unit tests for:
    - empty source rejected
    - full destination rejected
    - matching-color destination accepted
    - wrong-color destination rejected
    - empty destination accepted
    - valid move mutates correct tubes
    - invalid move leaves board unchanged
    - solved board detected
    - mixed board not solved
    - restart restores original board

VISUALS:
Use simple placeholder circles and containers.
Do not spend time on art.

REPORT:
- files created
- architecture
- tests
- test results
- manual verification steps
- risks

STOP after this technical foundation milestone.
Do not add extra systems.
```

---

# 47. Success Definition

This project succeeds if:
- rules are deterministic
- legal moves are always correct
- animation never owns game state
- no duplicate or lost balls occur
- undo is reliable
- levels are easy to author
- solver can later validate generated levels
- Flutter remains sufficient
- the visual theme can be replaced without rewriting logic
- development stays significantly simpler than physics-based puzzle games

---

# 48. Final Product Architecture Principle

Always preserve:

```text
GAME LOGIC
    ↓
tube state
ball types
move rules
win condition

ANIMATION
    ↓
selection
transfer movement
landing feedback

UI / PRODUCT
    ↓
progression
themes
audio
haptics
monetization
```

Never let animation become the source of truth.

Never store ball position as puzzle state.

Never use physics to implement sorting logic.

The puzzle is fundamentally a deterministic stack-management game.

---

# 49. Current Decision

**Proceed with Ball Sort as a separate Flutter project plan.**

Primary logic reference:
- `tjwood100/ball-sort-puzzle-solver` — MIT

Secondary study references:
- `SarahAlghadir/ball-sort`
- `M-danish05/Ball-Sort-Nix`

Original project requirements:
- original theme
- original UI
- original visuals
- original levels
- original branding
- original sounds
- original progression

Recommended visual concept:

**Orb Lab**

The next implementation step after this document is:

**Phase 0 — Core Logic Prototype**
