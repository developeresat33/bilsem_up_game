import 'dart:async';

import 'package:bilsemup_minigame/game/box_game/grid_component.dart';
import 'package:bilsemup_minigame/states/box_game_provider.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class MemoryGame extends FlameGame {
  late List<Color> colors;
  late List<int> correctSquares;
  late GridComponent grid;
  int incorrectTaps = 0;
  int score = 0;
  final VoidCallback onFinishGame;
  final int maxCorrectSquares;
  final int seconds;
  var boxprovider =
      Provider.of<MemoryGameProvider>(Get.context!, listen: false);

  MemoryGame(
      {required this.onFinishGame,
      required this.colors,
      required this.maxCorrectSquares,
      required this.seconds});

  @override
  Future<void> onLoad() async {
    await _initializeGame();
  }

  Future<void> _initializeGame() async {
    incorrectTaps = 0;
    score = 0;
    correctSquares = _generateRandomSquares(maxCorrectSquares);

    grid = GridComponent(seconds, correctSquares, colors,
        onIncorrectTap: _handleIncorrectTap, onCorrectTap: _handleCorrectTap);
    add(grid);
   
    grid.initColor();
  }

  void _handleIncorrectTap() async {
    incorrectTaps++;

    if (incorrectTaps == 1) {
      grid.showColors();
      boxprovider.setOption(2);
      FlameAudio.play('sound/fail_game.mp3', volume: 0.8);
      await Future.delayed(Duration(milliseconds: 900));
      onFinishGame.call();
    }
  }

  void _handleCorrectTap() async {
    score++;

    if (score == maxCorrectSquares) {
      boxprovider.setOption(1);
      FlameAudio.play('sound/succes_game.mp3', volume: 0.8);
      await Future.delayed(Duration(milliseconds: 900));
      onFinishGame.call();
    }
  }

  List<int> _generateRandomSquares(int max) {
    return (List.generate(9, (index) => index)..shuffle()).sublist(0, max);
  }
}
