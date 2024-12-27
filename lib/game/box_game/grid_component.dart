import 'package:bilsemup_minigame/game/box_game/square_component.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class GridComponent extends PositionComponent with HasGameRef {
  final List<int> correctSquares;
  final List<Color> colors;
  final List<SquareComponent> squares = [];
  final double gridSize = 3;
  final double squareSize = 100;
  final double gap = 4.0;
  final VoidCallback? onIncorrectTap;
  final VoidCallback? onCorrectTap;

  GridComponent(this.correctSquares, this.colors,
      {this.onIncorrectTap, this.onCorrectTap});

  @override
  Future<void> onLoad() async {
    super.onLoad();
    initSquare();
  }

  void initSquare() async {
    if (squares.isNotEmpty) {
      for (var square in squares) {
        remove(square);
      }
    }
    final double offsetX =
        (gameRef.size.x - gridSize * squareSize - (gridSize - 1) * gap) / 2;
    final double offsetY =
        (gameRef.size.y - gridSize * squareSize - (gridSize - 1) * gap) / 2;

    for (int i = 0; i < 9; i++) {
      final x = offsetX + (i % gridSize) * (squareSize + gap);
      final y = offsetY + (i ~/ gridSize) * (squareSize + gap);

      final isCorrect = correctSquares.contains(i);
      final color = isCorrect
          ? colors[correctSquares.indexOf(i) % colors.length]
          : Colors.blueGrey[800]!;

      final square = SquareComponent(
          color, Vector2(x, y), squareSize, isCorrect, i,
          onIncorrectTap: isCorrect ? null : onIncorrectTap,
          onCorrectTap: isCorrect ? onCorrectTap : null,
          correctColors: colors,
          correctSquaresIndex: correctSquares);

      add(square);
      squares.add(square);
    }
  }

  Future<void> hideColors() async {
    for (var square in squares) {
      square.changeColor(Colors.grey[800]!);
    }
  }

  Future<void> showColors() async {
    for (int i = 0; i < squares.length; i++) {
      if (correctSquares.contains(i)) {
        final correctIndex = correctSquares.indexOf(i);
        squares[i].changeColor(colors[correctIndex % colors.length]);
      }
    }
  }

  Future<void> animateShowColors() async {
    for (int i = 0; i < squares.length; i++) {
      if (correctSquares.contains(i)) {
        final correctIndex = correctSquares.indexOf(i);
        await squares[i].animateSizeChange();
        squares[i].changeColor(colors[correctIndex % colors.length]);
      }
    }
  }
}
