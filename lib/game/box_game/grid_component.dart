import 'package:bilsemup_minigame/game/box_game/square_component.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class GridComponent extends PositionComponent with HasGameRef {
  final List<int> correctSquares;
  final List<Color> colors;
  final List<SquareComponent> squares = [];
  final double gridSize = 3;
  final double squareSize = 100;
  final VoidCallback? onIncorrectTap; // Hata callback'i
  final VoidCallback? onCorrectTap;

  GridComponent(this.correctSquares, this.colors,
      {this.onIncorrectTap, this.onCorrectTap});

  @override
  Future<void> onLoad() async {
    super.onLoad();

    final double offsetX = (gameRef.size.x - gridSize * squareSize) / 2;
    final double offsetY = (gameRef.size.y - gridSize * squareSize) / 2;

    for (int i = 0; i < 9; i++) {
      final x = offsetX + (i % gridSize) * squareSize;
      final y = offsetY + (i ~/ gridSize) * squareSize;

      final isCorrect = correctSquares.contains(i);
      final color = isCorrect
          ? colors[correctSquares.indexOf(i) % colors.length]
          : Colors.grey;

      final square = SquareComponent(
        color,
        Vector2(x, y),
        squareSize,
        isCorrect,
        i,
        onIncorrectTap: isCorrect ? null : onIncorrectTap,
        onCorrectTap: isCorrect ? onCorrectTap : null,
      );
      add(square);
      squares.add(square);
    }
  }

  Future<void> hideColors() async {
    for (var square in squares) {
      square.changeColor(Colors.grey);
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
}
