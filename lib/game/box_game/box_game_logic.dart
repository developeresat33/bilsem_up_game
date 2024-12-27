import 'dart:async';

import 'package:bilsemup_minigame/game/box_game/grid_component.dart';
import 'package:bilsemup_minigame/states/box_game_provider.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class MemoryGame extends FlameGame {
  late List<Color> colors;
  late List<int> correctSquares;
  late GridComponent grid;
  int incorrectTaps = 0;
  int score = 0;
  var boxprovider =
      Provider.of<MemoryGameProvider>(Get.context!, listen: false);
  @override
  Future<void> onLoad() async {
    await _initializeGame();
  }

  Future<void> _initializeGame() async {
    incorrectTaps = 0;
    score = 0;
    boxprovider.endOption.value = 0;
    colors = [Colors.blue, Colors.red, Colors.green];
    correctSquares = _generateRandomSquares();

    grid = GridComponent(correctSquares, colors,
        onIncorrectTap: _handleIncorrectTap, onCorrectTap: _handleCorrectTap);
    add(grid);

    Timer.periodic(Duration(milliseconds: 150), (timer) {
      if (timer.tick >= 10) {
        grid.hideColors();
        timer.cancel();
      }
    });
  }

  void _handleIncorrectTap() async {
    incorrectTaps++;

    if (incorrectTaps == 3) {
      grid.showColors();
      boxprovider.setOption(2);
      await Future.delayed(Duration(seconds: 3));
      restartGame();
    }
  }

  void _handleCorrectTap() async {
    score++;

    if (score == 3) {
      boxprovider.setOption(1);
      await Future.delayed(Duration(seconds: 3));
      restartGame();
    }
  }

  void restartGame() async {
    await _initializeGame();
  }

  List<int> _generateRandomSquares() {
    return (List.generate(9, (index) => index)..shuffle()).sublist(0, 3);
  }
}
