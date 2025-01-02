import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MemoryGameProvider with ChangeNotifier {
  int endOption = 0;
  bool? hasStartGame = false;
  ValueNotifier<int> elapsedSeconds = ValueNotifier(0);
  Timer? scoreTimer;
  int totalScore = 0;
  int setScore = 0;

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
    if (scoreTimer != null && scoreTimer!.isActive) {
      scoreTimer!.cancel();
    }
  }


  int calculateScore() {
    print(elapsedSeconds.value);
    if (elapsedSeconds.value <= 3) return 10;
    if (elapsedSeconds.value < 4) return 8;
    if (elapsedSeconds.value <= 8) return 5;
    return 3;
  }

  setStartGame(bool value) async {
    await Future.delayed(Duration(milliseconds: 5));
    hasStartGame = value;
    if (!hasStartGame!) endOption = 0;
    notifyListeners();
  }
}
