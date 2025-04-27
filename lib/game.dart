import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:tetris/board.dart';
import 'package:tetris/widgets.dart';
import 'package:tetris/painter.dart';

class GamePage extends StatefulWidget {
  const GamePage({Key? key}) : super(key: key);

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late Board board;
  Timer? _dropTimer;
  int score = 0;
  bool isPaused = false;

  static const _normalDrop = Duration(milliseconds: 500);
  static const _fastDrop = Duration(milliseconds: 50);

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  @override
  void dispose() {
    _dropTimer?.cancel();
    super.dispose();
  }

  void _startNewGame() {
    board = Board.empty();
    score = 0;
    isPaused = false;
    _spawnNext();
    _startDrop(_normalDrop);
  }

  void _spawnNext() => board.spawnPiece();

  void _startDrop(Duration interval) {
    _dropTimer?.cancel();
    _dropTimer = Timer.periodic(interval, (_) => _step());
  }

  void _step() {
    if (!mounted || isPaused) return;
    if (!board.moveDown()) {
      board.lockPiece();
      final lines = board.clearFullLines();
      if (lines > 0) score += lines * 100;
      _spawnNext();
      if (board.isGameOver) {
        _dropTimer?.cancel();
        _showGameOverDialog();
      }
    }
    setState(() {});
  }

  void _togglePause() {
    setState(() {
      isPaused = !isPaused;
      if (isPaused) {
        _dropTimer?.cancel();
      } else {
        _startDrop(_normalDrop);
      }
    });
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.black87,
        contentPadding: const EdgeInsets.all(24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Game Over',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Score: $score',
              style: const TextStyle(color: Colors.white70, fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _startNewGame();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyan,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Restart',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildHeader(),
            const SizedBox(height: 20),
            Expanded(child: _buildBoard()),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final screenWidth = MediaQuery.of(context).size.width;
    // Divide available width between board columns + a slot for next‐piece display
    final cellSize = screenWidth / (Board.cols + 4);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ScoreDisplay(score: score, cellSize: cellSize),
          const SizedBox(
            width: 30,
          ),
          NextPieceDisplay(nextPiece: board.nextPiece, cellSize: cellSize),
        ],
      ),
    );
  }

  Widget _buildBoard() {
    return LayoutBuilder(builder: (ctx, constraints) {
      // Keep the board square via AspectRatio
      return Center(
        child: AspectRatio(
          aspectRatio: Board.cols / Board.rows,
          child: LayoutBuilder(builder: (c2, c2Cons) {
            final cellSize = min(
              c2Cons.maxWidth / Board.cols,
              c2Cons.maxHeight / Board.rows,
            );
            return _BoardDisplay(
              board: board,
              cellSize: cellSize,
              onMoveLeft: () => setState(() => board.moveLeft()),
              onMoveRight: () => setState(() => board.moveRight()),
              onRotate: () => setState(() => board.rotate()),
              onFastDrop: () => _startDrop(_fastDrop),
              onSlowDrop: () => _startDrop(_normalDrop),
            );
          }),
        ),
      );
    });
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: IconButton(
        icon: Icon(
          isPaused ? Icons.play_arrow : Icons.pause,
          color: Colors.white,
        ),
        onPressed: _togglePause,
      ),
    );
  }
}

class _BoardDisplay extends StatelessWidget {
  final Board board;
  final double cellSize;
  final VoidCallback onMoveLeft, onMoveRight, onRotate, onFastDrop, onSlowDrop;

  const _BoardDisplay({
    Key? key,
    required this.board,
    required this.cellSize,
    required this.onMoveLeft,
    required this.onMoveRight,
    required this.onRotate,
    required this.onFastDrop,
    required this.onSlowDrop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final boardW = cellSize * Board.cols;
    final boardH = cellSize * Board.rows;

    return SizedBox(
      width: boardW,
      height: boardH,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapUp: _handleTap,
        onDoubleTap: () => onRotate(),
        onPanUpdate: _handlePan,
        onLongPressStart: (_) => onFastDrop(),
        onLongPressEnd: (_) => onSlowDrop(),
        child: CustomPaint(
          painter: TetrisPainter(board: board),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }

  void _handleTap(TapUpDetails d) {
    final dx = d.localPosition.dx;
    if (dx < (cellSize * Board.cols) / 2) {
      onMoveLeft();
    } else {
      onMoveRight();
    }
  }

  void _handlePan(DragUpdateDetails d) {
    if (d.delta.dx.abs() > cellSize) {
      if (d.delta.dx > 0) {
        onMoveRight();
      } else {
        onMoveLeft();
      }
    }
  }
}
