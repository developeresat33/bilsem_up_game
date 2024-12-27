import 'package:flutter/material.dart';

class MemoryGameProvider with ChangeNotifier {
  ValueNotifier<int> endOption = ValueNotifier<int>(0);

  setOption(int value) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      endOption.value = value;
    });
    notifyListeners();
  }
}
