import 'dart:async';
import 'package:bilsemup_minigame/game/box_game_2/square_component2.dart';
import 'package:bilsemup_minigame/states/box_game_provider.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class GridComponent2 extends PositionComponent with HasGameRef {
  final List<int> correctSquares;

  final List<SquareComponent2> squares = [];
  final double gridSize = 3;
  final double squareSize = MediaQuery.of(Get.context!).size.height * 0.105;
  final double gap = 4.0;
  final VoidCallback? onIncorrectTap;
  final VoidCallback? onCorrectTap;

  var boxprovider =
      Provider.of<MemoryGameProvider>(Get.context!, listen: false);
  GridComponent2(
    this.correctSquares, {
    this.onIncorrectTap,
    this.onCorrectTap,
  });

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
      final color = Colors.grey[800]!;

      final square = SquareComponent2(
          color, Vector2(x, y), squareSize, isCorrect, i,
          correctSquaresIndex: correctSquares,
          onCorrectTap: onCorrectTap,
          onIncorrectTap: onIncorrectTap);

      add(square);
      squares.add(square);
    }
  }

  Future<void> hideColors() async {
    for (var square in squares) {
      square.changeColor(Colors.grey[800]!);
    }
  }

  Future<void> showBlues({Duration? duration}) async {
    final getDuration = duration ?? Duration(milliseconds: 300);
    boxprovider.setStartGame(false);

    await Future.delayed(Duration(milliseconds: 900), () async {
      for (int i = 0; i < correctSquares.length; i++) {
        final index = correctSquares[i];
        if (index >= squares.length) {
          continue;
        }

        final square = squares[index];

        square.changeColor(Colors.blue);
        await Future.delayed(getDuration);

        square.changeColor(Colors.grey[800]!);

        if (i != correctSquares.length - 1) {
          await Future.delayed(getDuration);
        }
      }
    });
    boxprovider.setStartGame(true);
    await Future.delayed(Duration(milliseconds: 50));
    boxprovider.startLevelTimer();
  }
}
