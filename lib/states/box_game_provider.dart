import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MemoryGameProvider with ChangeNotifier {
  int endOption = 0;
  bool? hasStartGame = false;
  ValueNotifier<int> elapsedSeconds = ValueNotifier(0);
  late Timer scoreTimer;
  int totalScore = 0;


  setOption(int value) {
    endOption = value;
    notifyListeners();
  }

  Future<void> startLevelTimer() async {
    elapsedSeconds.value = 0;
    scoreTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      elapsedSeconds.value++;
    });

    notifyListeners();
  }

  Future<void> stopLevelTimer() async {
    scoreTimer.cancel();
  }

  int calculateScore(int elapsedSeconds) {
    if (elapsedSeconds <= 3) return 100;
    if (elapsedSeconds < 4) return 80;
    if (elapsedSeconds <= 8) return 50;
    return 20;
  }

  setStartGame(bool value) async {
    await Future.delayed(Duration(milliseconds: 5));
    hasStartGame = value;
    if (!hasStartGame!) endOption = 0;
    notifyListeners();
  }
}
