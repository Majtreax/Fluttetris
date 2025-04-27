import 'dart:ui';
import 'dart:math';

import 'package:tetris/block.dart';

/// Represents the Tetris board: a grid of fixed size with an active piece.
/// Handles piece movement, rotation, and line clearing.
class Board {
  static const int rows = 20;
  static const int cols = 10;

  /// The fixed grid: null = empty, Color = filled block color
  late final List<List<Color?>> grid;

  /// Currently active falling piece
  Piece? activePiece;

  /// Next piece to be spawned
  Piece? nextPiece;

  final Random _rand = Random();

  Board.empty() {
    // Initialize empty grid
    grid = List.generate(rows, (_) => List.filled(cols, null));
  }

  /// Spawn a new piece at the top
  /// [type] - Optional specific piece type to spawn, otherwise random
  void spawnPiece([TetrominoType? type]) {
    // If no next piece exists, generate one
    if (nextPiece == null) {
      final pieceType = type ?? _getRandomPieceType();
      nextPiece = Piece(pieceType);
    }

    // Set active piece to next piece
    activePiece = nextPiece;

    // Generate new next piece
    final nextType = type ?? _getRandomPieceType();
    nextPiece = Piece(nextType);
  }

  /// Get a random piece type
  TetrominoType _getRandomPieceType() {
    return TetrominoType.values[_rand.nextInt(TetrominoType.values.length)];
  }

  /// Attempt to move down; returns true if moved, false if blocked
  bool moveDown() {
    if (activePiece == null) return false;
    if (!_collides(activePiece!.x, activePiece!.y + 1, activePiece!.shape)) {
      activePiece!.y += 1;
      return true;
    }
    return false;
  }

  /// Attempt to move left
  bool moveLeft() {
    if (activePiece == null) return false;
    if (!_collides(activePiece!.x - 1, activePiece!.y, activePiece!.shape)) {
      activePiece!.x -= 1;
      return true;
    }
    return false;
  }

  /// Attempt to move right
  bool moveRight() {
    if (activePiece == null) return false;
    if (!_collides(activePiece!.x + 1, activePiece!.y, activePiece!.shape)) {
      activePiece!.x += 1;
      return true;
    }
    return false;
  }

  /// Rotate piece clockwise, revert if collision
  /// Implements wall kick by trying to move left/right if rotation fails
  bool rotate() {
    if (activePiece == null) return false;

    // Store current rotation for potential revert
    final originalRotation = activePiece!.rotationIndex;

    // Try rotation
    activePiece!.rotate();
    if (_collides(activePiece!.x, activePiece!.y, activePiece!.shape)) {
      // Try wall kicks
      if (moveLeft()) return true;
      if (moveRight()) return true;

      // If wall kicks fail, revert rotation
      while (activePiece!.rotationIndex != originalRotation) {
        activePiece!.rotate();
      }
      return false;
    }
    return true;
  }

  /// Locks the active piece into the grid
  void lockPiece() {
    if (activePiece == null) return;

    final shape = activePiece!.shape;
    for (int i = 0; i < shape.length; i++) {
      for (int j = 0; j < shape[i].length; j++) {
        if (shape[i][j] == 1) {
          final row = activePiece!.y + i;
          final col = activePiece!.x + j;
          if (row >= 0 && row < rows && col >= 0 && col < cols) {
            grid[row][col] = activePiece!.color;
          }
        }
      }
    }
    activePiece = null;
  }

  /// Clears filled lines and returns number of lines removed
  int clearFullLines() {
    int cleared = 0;
    for (int r = rows - 1; r >= 0; r--) {
      if (grid[r].every((cell) => cell != null)) {
        grid.removeAt(r);
        grid.insert(0, List.filled(cols, null));
        cleared++;
        r++; // re-check this row index after removal
      }
    }
    return cleared;
  }

  /// Check if placing a shape at (x,y) collides with walls or existing blocks
  bool _collides(int x, int y, List<List<int>> shape) {
    for (int i = 0; i < shape.length; i++) {
      for (int j = 0; j < shape[i].length; j++) {
        if (shape[i][j] == 1) {
          final nx = x + j;
          final ny = y + i;
          // Collision with walls or floor/ceiling
          if (nx < 0 || nx >= cols || ny >= rows) return true;
          // Above board is allowed (ny<0)
          if (ny >= 0 && grid[ny][nx] != null) return true;
        }
      }
    }
    return false;
  }

  /// Check for game over: active piece collides on spawn
  bool get isGameOver {
    if (activePiece == null) return false;
    return _collides(activePiece!.x, activePiece!.y, activePiece!.shape);
  }
}
