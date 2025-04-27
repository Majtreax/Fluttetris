import 'dart:math';
import 'package:flutter/material.dart';
import 'package:tetris/block.dart';

/// Displays the current game score
class ScoreDisplay extends StatelessWidget {
  final int score;
  final double cellSize;
  const ScoreDisplay({
    Key? key,
    required this.score,
    required this.cellSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      'SCORE: $score',
      style: TextStyle(
        color: Colors.white,
        fontSize: cellSize * 0.5,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
            offset: Offset(2, 2),
            blurRadius: 2,
            color: Colors.black45,
          ),
        ],
      ),
    );
  }
}

/// Displays the next piece that will appear
class NextPieceDisplay extends StatelessWidget {
  final Piece? nextPiece;
  final double cellSize;
  const NextPieceDisplay({
    Key? key,
    required this.nextPiece,
    required this.cellSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (nextPiece == null) return const SizedBox.shrink();

    // Calculate dimensions for the next piece display
    final shape = nextPiece!.shape;
    final boxSize = cellSize * 2;
    final maxDim = max(shape.length, shape[0].length).toDouble();
    final painterCellSize = boxSize / maxDim;

    return Center(
      child: CustomPaint(
        painter: NextPiecePainter(
          piece: nextPiece!,
          cellSize: painterCellSize,
        ),
      ),
    );
  }
}

/// Custom painter for the next piece preview
class NextPiecePainter extends CustomPainter {
  final Piece piece;
  final double cellSize;

  NextPiecePainter({
    required this.piece,
    required this.cellSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final shape = piece.shape;
    final offsetX = (size.width - shape[0].length * cellSize) / 2;
    final offsetY = (size.height - shape.length * cellSize) / 2;

    for (var i = 0; i < shape.length; i++) {
      for (var j = 0; j < shape[i].length; j++) {
        if (shape[i][j] == 1) {
          _drawBlock(canvas, offsetX + j * cellSize, offsetY + i * cellSize);
        }
      }
    }
  }

  void _drawBlock(Canvas canvas, double x, double y) {
    final rect = Rect.fromLTWH(x, y, cellSize, cellSize);
    final rrect =
        RRect.fromRectAndRadius(rect, Radius.circular(cellSize * 0.15));

    // Draw block with gradient
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        piece.color,
        piece.color.withAlpha(50),
      ],
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(rrect, paint);

    // Draw highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withAlpha(75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(rrect, highlightPaint);

    // Draw border
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5
      ..color = Colors.black.withAlpha(75);
    canvas.drawRRect(rrect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant NextPiecePainter old) =>
      old.piece != piece || old.cellSize != cellSize;
}
