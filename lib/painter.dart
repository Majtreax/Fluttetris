import 'dart:math';
import 'package:flutter/material.dart';
import 'package:tetris/board.dart';

/// CustomPainter to draw the Tetris board with grid shadows, lines, and styled blocks
class TetrisPainter extends CustomPainter {
  final Board board;
  TetrisPainter({required this.board});

  @override
  void paint(Canvas canvas, Size size) {
    final rows = Board.rows;
    final cols = Board.cols;
    final cellWidth = size.width / cols;
    final cellHeight = size.height / rows;
    final cellSize = min(cellWidth, cellHeight);
    final boardWidth = cellSize * cols;
    final boardHeight = cellSize * rows;
    final offsetX = (size.width - boardWidth) / 2;
    final offsetY = (size.height - boardHeight) / 2;
    final radius = Radius.circular(cellSize * 0.15);

    // Board background
    final bgPaint = Paint()..color = Colors.black12;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(offsetX, offsetY, boardWidth, boardHeight),
        const Radius.circular(12),
      ),
      bgPaint,
    );

    // Grid shadow (blurred, offset)
    final gridShadowPaint = Paint()
      ..color = Colors.black.withAlpha(50)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 0; i <= rows; i++) {
      final y = offsetY + i * cellSize;
      canvas.drawLine(
        Offset(offsetX + 1, y + 1),
        Offset(offsetX + boardWidth + 1, y + 1),
        gridShadowPaint,
      );
    }
    for (int i = 0; i <= cols; i++) {
      final x = offsetX + i * cellSize;
      canvas.drawLine(
        Offset(x + 1, offsetY + 1),
        Offset(x + 1, offsetY + boardHeight + 1),
        gridShadowPaint,
      );
    }

    // Grid lines (crisp)
    final gridPaint = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 0; i <= rows; i++) {
      final y = offsetY + i * cellSize;
      canvas.drawLine(
        Offset(offsetX, y),
        Offset(offsetX + boardWidth, y),
        gridPaint,
      );
    }
    for (int i = 0; i <= cols; i++) {
      final x = offsetX + i * cellSize;
      canvas.drawLine(
        Offset(x, offsetY),
        Offset(x, offsetY + boardHeight),
        gridPaint,
      );
    }

    // Draw a single cell with shadow, gradient, highlight, border
    void drawCell(double x, double y, Color color) {
      final rect = Rect.fromLTWH(x + 1, y + 1, cellSize - 2, cellSize - 2);

      // Cell shadow
      canvas.drawRect(
        rect.shift(const Offset(2, 2)),
        Paint()
          ..color = Colors.black.withAlpha(75)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );

      // Gradient fill
      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color,
            color.withAlpha(204), // ~80% opacity
          ],
        ).createShader(rect);
      canvas.drawRRect(RRect.fromRectAndRadius(rect, radius), fillPaint);

      // Highlight edge
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, radius),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = Colors.white.withAlpha(75),
      );

      // Dark border
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, radius),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5
          ..color = Colors.black.withAlpha(102), // ~40% opacity
      );
    }

    // Placed blocks
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final blockColor = board.grid[r][c];
        if (blockColor != null) {
          drawCell(offsetX + c * cellSize, offsetY + r * cellSize, blockColor);
        }
      }
    }

    // Active piece
    final piece = board.activePiece;
    if (piece != null) {
      for (int r = 0; r < piece.shape.length; r++) {
        for (int c = 0; c < piece.shape[r].length; c++) {
          if (piece.shape[r][c] == 1) {
            drawCell(
              offsetX + (piece.x + c) * cellSize,
              offsetY + (piece.y + r) * cellSize,
              piece.color,
            );
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant TetrisPainter oldDelegate) => true;
}
