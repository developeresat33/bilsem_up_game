import 'dart:async';
import 'package:bilsemup_minigame/game/box_game_2/square_component2.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class GridComponent2 extends PositionComponent with HasGameRef {
  final List<int> correctSquares;
  final List<Color> colors;
  final List<SquareComponent2> squares = [];
  final double gridSize = 3;
  final double squareSize = 85;
  final double gap = 4.0;
  final VoidCallback? onIncorrectTap;
  final VoidCallback? onCorrectTap;
  GridComponent2(this.correctSquares,
      {this.onIncorrectTap, this.onCorrectTap, required this.colors});

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

      final square = SquareComponent2(
          color, Vector2(x, y), squareSize, isCorrect, i,
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

Future<void> showBlues() async {
  for (int i = 0; i < correctSquares.length; i++) {
    final index = correctSquares[i]; // Doğru index alındığından emin olun
    if (index >= squares.length) {
      continue; // Bu durumda işlemden kaç
    }
    final square = squares[index];
    square.changeColor(Colors.blue); // Tek bir renk mavi kullanıyoruz
    await Future.delayed(Duration(milliseconds: 300)); // 0.3 saniyelik bekleme
    square.changeColor(Colors.grey[800]!); // Sonra rengi gri olacak
  }
  await Future.delayed(Duration(milliseconds: 300)); // Tüm mavi renkler gösterildikten sonra bekleme
  hideColors(); // Son olarak tüm renkleri gizler
}


}
