import 'dart:async';
import 'dart:math';

import 'package:bilsemup_minigame/dialog/game_dialog.dart';
import 'package:bilsemup_minigame/pages/match_game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class GameProvider with ChangeNotifier {
  int endOption = 0;
  bool? hasStartGame = false;
  ValueNotifier<int> elapsedSeconds = ValueNotifier(0);
  Timer? scoreTimer;
  StopWatchTimer? stopWatchTimer;
  int stage = 0;
  int totalScore = 0;
  int setScore = 0;
  int level = 1;
  bool isPaused = false;
  List<CardModel>? cards;
  CardModel? firstSelectedCard;
  bool isChecking = false;
  final Set<String> _cachedImages = {};
  void pause() {
    isPaused = true;
  }

  void resume() {
    isPaused = false;
  }

  Future<void> firstInitGame() async {
    level = 1;
    stage = 1;
    totalScore = 0;
    elapsedSeconds.value = 0;
    cards = [];
    isChecking = false;
    firstSelectedCard = null;
    stopWatchTimer = StopWatchTimer();
  }

  Future<void> precacheImages(List<String> images) async {
    for (var image in images) {
      if (!_cachedImages.contains(image)) {
        try {
          await precacheImage(NetworkImage(image), Get.context!);
          _cachedImages.add(image);
        } catch (e) {
          print("Resim önbelleğe alınamadı: $image, Hata: $e");
        }
      } else {
        print("Resim zaten önbellekte: $image");
      }
    }
  }

  void initializeCards() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      hasStartGame = false;
      notifyListeners();
    });

    final allImages = List.generate(
        50, (index) => 'https://bilsemup.com/uygulama/img/${index + 1}.png');
    final random = Random();

    final selectedImages = <String>{};

    while (selectedImages.length < stage + 1) {
      selectedImages.add(allImages[random.nextInt(allImages.length)]);
    }

    final images = selectedImages.toList();
    cards = (images + images)
        .map((image) => CardModel(imagePath: image, isRevealed: false))
        .toList()
      ..shuffle(Random());
    await precacheImages(images);

    await Future.delayed(const Duration(seconds: 1), () {
      cards!.forEach((card) => card.isRevealed = true);
      notifyListeners();

      Future.delayed(const Duration(seconds: 2), () {
        closeCards();
        startCustomTimer();
        hasStartGame = true;
        notifyListeners();
      });
    });

    
  }

  void closeCards() {
    for (var card in cards!) {
      card.isRevealed = false;
    }
  }

  void onCardTap(CardModel card) {
    if (isChecking || card.isMatched || card.isRevealed || !hasStartGame!) {
      return;
    }

    card.isRevealed = true;
    notifyListeners();

    if (firstSelectedCard == null) {
      firstSelectedCard = card;
    } else {
      isChecking = true;

      Future.delayed(const Duration(milliseconds: 400), () {
        if (firstSelectedCard!.imagePath == card.imagePath) {
          firstSelectedCard!.isMatched = true;
          card.isMatched = true;
          _playMatchSound();
        } else {
          firstSelectedCard!.isRevealed = false;
          card.isRevealed = false;
        }
        firstSelectedCard = null;
        isChecking = false;
        notifyListeners();

        _checkGameCompletion();
      });
    }
  }

  void _checkGameCompletion() {
    if (cards!.every((card) => card.isMatched)) {
      stopCustomTimer();

      int levelScore = max(0, 100 - elapsedSeconds.value);
      totalScore += levelScore;

      if (stage == 10) {
        GameDialog.finishGame();
      } else {
        stopCustomTimer();
        closeCards();
        GameDialog.showLevelUpDialog(levelScore);
      }
    }
  }

  void restartGame() async {
    level = 1;
    stage = 1;
    totalScore = 0;
    elapsedSeconds.value = 0;
    resetCustomTimer();
    initializeCards();
  }

  Future<void> _playMatchSound() async {
    await FlameAudio.play('sound/good.mp3', volume: 0.8);
  }

  setOption(int value) {
    endOption = value;
    notifyListeners();
  }

  Future<void> startLevelTimer() async {
    elapsedSeconds.value = 0;
    scoreTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!isPaused) elapsedSeconds.value++;
    });

    notifyListeners();
  }

  Future<void> stopLevelTimer() async {
    if (scoreTimer != null && scoreTimer!.isActive) {
      scoreTimer!.cancel();
    }
  }

  // Başlat
  void startCustomTimer() {
    stopWatchTimer!.onStartTimer();
    stopWatchTimer!.rawTime.listen((value) {
      elapsedSeconds.value = (value / 1000).floor();
    });
  }

  // Duraklat
  void stopCustomTimer() {
    if (stopWatchTimer!.isRunning) stopWatchTimer!.onStopTimer();
  }

  // Sıfırla
  void resetCustomTimer() {
    stopWatchTimer!.onResetTimer();
  }

  void disposeCustomTimer() {
    try {
      stopWatchTimer!.dispose();
    } catch (e) {
      print(e);
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
