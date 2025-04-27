import 'dart:ui';

/// All seven Tetromino types
enum TetrominoType { I, O, T, S, Z, J, L }

/// Represents a single Tetris piece with rotation states and position
class Piece {
  final TetrominoType type;
  final List<List<List<int>>> rotations;
  int rotationIndex;
  int x; // column position on board
  int y; // row position on board
  final Color color;

  Piece(this.type)
      : rotations = shapes[type]!,
        rotationIndex = 0,
        // Spawn roughly centered above the grid
        x = 4,
        y = -_initialYOffset(type),
        color = colors[type]!;

  /// Current 4×4 shape matrix for this rotation
  List<List<int>> get shape => rotations[rotationIndex];

  /// Rotate clockwise
  void rotate() {
    rotationIndex = (rotationIndex + 1) % rotations.length;
  }

  /// Compute vertical spawn offset (I is taller)
  static int _initialYOffset(TetrominoType type) {
    return type == TetrominoType.I ? 2 : 1;
  }
}

/// Predefined rotation matrices for each Tetromino
const Map<TetrominoType, List<List<List<int>>>> shapes = {
  TetrominoType.I: [
    [
      [0, 0, 0, 0],
      [1, 1, 1, 1],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
    ],
    [
      [0, 0, 1, 0],
      [0, 0, 1, 0],
      [0, 0, 1, 0],
      [0, 0, 1, 0],
    ],
  ],
  TetrominoType.O: [
    [
      [0, 1, 1, 0],
      [0, 1, 1, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
    ],
  ],
  TetrominoType.T: [
    [
      [0, 1, 0, 0],
      [1, 1, 1, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
    ],
    [
      [0, 1, 0, 0],
      [0, 1, 1, 0],
      [0, 1, 0, 0],
      [0, 0, 0, 0],
    ],
    [
      [0, 0, 0, 0],
      [1, 1, 1, 0],
      [0, 1, 0, 0],
      [0, 0, 0, 0],
    ],
    [
      [0, 1, 0, 0],
      [1, 1, 0, 0],
      [0, 1, 0, 0],
      [0, 0, 0, 0],
    ],
  ],
  TetrominoType.S: [
    [
      [0, 1, 1, 0],
      [1, 1, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
    ],
    [
      [0, 1, 0, 0],
      [0, 1, 1, 0],
      [0, 0, 1, 0],
      [0, 0, 0, 0],
    ],
  ],
  TetrominoType.Z: [
    [
      [1, 1, 0, 0],
      [0, 1, 1, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
    ],
    [
      [0, 0, 1, 0],
      [0, 1, 1, 0],
      [0, 1, 0, 0],
      [0, 0, 0, 0],
    ],
  ],
  TetrominoType.J: [
    [
      [1, 0, 0, 0],
      [1, 1, 1, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
    ],
    [
      [0, 1, 1, 0],
      [0, 1, 0, 0],
      [0, 1, 0, 0],
      [0, 0, 0, 0],
    ],
    [
      [0, 0, 0, 0],
      [1, 1, 1, 0],
      [0, 0, 1, 0],
      [0, 0, 0, 0],
    ],
    [
      [0, 1, 0, 0],
      [0, 1, 0, 0],
      [1, 1, 0, 0],
      [0, 0, 0, 0],
    ],
  ],
  TetrominoType.L: [
    [
      [0, 0, 1, 0],
      [1, 1, 1, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
    ],
    [
      [0, 1, 0, 0],
      [0, 1, 0, 0],
      [0, 1, 1, 0],
      [0, 0, 0, 0],
    ],
    [
      [0, 0, 0, 0],
      [1, 1, 1, 0],
      [1, 0, 0, 0],
      [0, 0, 0, 0],
    ],
    [
      [1, 1, 0, 0],
      [0, 1, 0, 0],
      [0, 1, 0, 0],
      [0, 0, 0, 0],
    ],
  ],
};

/// Pastel color palette for each Tetromino
const Map<TetrominoType, Color> colors = {
  TetrominoType.I: Color(0xFF4DD0E1), // Teal lighten-1
  TetrominoType.O: Color(0xFFFFEE58), // Yellow lighten-1
  TetrominoType.T: Color(0xFFCE93D8), // Purple lighten-2
  TetrominoType.S: Color(0xFFA5D6A7), // Green lighten-3
  TetrominoType.Z: Color(0xFFE57373), // Red lighten-2
  TetrominoType.J: Color(0xFF90CAF9), // Blue lighten-3
  TetrominoType.L: Color(0xFFFFB74D), // Orange lighten-2
};
