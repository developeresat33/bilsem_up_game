import 'dart:core';

import 'package:bilsemup_minigame/game/box_game/square_component.dart';
import 'package:bilsemup_minigame/states/game_provider.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class GridComponent extends PositionComponent with HasGameRef {
  final List<int> correctSquares;
  final List<Color> colors;
  final List<SquareComponent> squares = [];
  final double gridSize = 3;
  final double squareSize = MediaQuery.of(Get.context!).size.height * 0.105;
  final double gap = 4.0;
  final VoidCallback? onIncorrectTap;
  final VoidCallback? onCorrectTap;
  final int initSecond;
  var boxprovider =
      Provider.of<GameProvider>(Get.context!, listen: false);

  GridComponent(this.initSecond, this.correctSquares, this.colors,
      {this.onIncorrectTap, this.onCorrectTap});
  @override
  Future<void> onLoad() async {
    super.onLoad();
    initSquare();
  }

  Future<void> initSquare() async {
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

  void initColor() async {
    print(initSecond);
    boxprovider.setStartGame(false);
    await Future.delayed(Duration(milliseconds: 900));
    await showColors();
    await Future.delayed(Duration(milliseconds: initSecond), () async {
      hideColors();
    });
    boxprovider.setStartGame(true);
    await Future.delayed(Duration(milliseconds: 50));
    boxprovider.startLevelTimer();
  }
}
