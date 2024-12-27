import 'package:flutter/material.dart';

class MemoryGameProvider with ChangeNotifier {
  ValueNotifier<int> endOption = ValueNotifier<int>(0);
  bool? hasStartGame = false;

  setOption(int value) {
    endOption.value = value;
    notifyListeners();
  }

  setStartGame(bool value) async {
    await Future.delayed(Duration(milliseconds: 5));
    hasStartGame = value;
    if (!hasStartGame!) endOption.value = 0;
    notifyListeners();
  }
}
