import 'dart:async';
import 'dart:math';

import 'package:bilsemup_minigame/dialog/game_dialog.dart';
import 'package:bilsemup_minigame/pages/match_game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class GameProvider with ChangeNotifier {
  int endOption = 0;
  bool? hasStartGame = false;
  ValueNotifier<int> elapsedSeconds = ValueNotifier(0);
  Timer? scoreTimer;
  int totalScore = 0;
  int setScore = 0;
  int level = 1;
  bool isPaused = false;
  List<CardModel>? cards;
  CardModel? _firstSelectedCard;
  bool _isChecking = false;

  void pause() {
    isPaused = true;
  }

  void resume() {
    isPaused = false;
  }

  Future<void> firstInitGame() async {
    level = 1;
    totalScore = 0;
    elapsedSeconds.value = 0;
    cards = [];
    _isChecking = false;
    _firstSelectedCard = null;
    await stopLevelTimer();
  }

  void initializeCards() async {
    final allImages =
        List.generate(21, (index) => 'assets/img/${index + 1}.png');
    final random = Random();

    final selectedImages = <String>{};

    while (selectedImages.length < level + 1) {
      selectedImages.add(allImages[random.nextInt(allImages.length)]);
    }

    final images = selectedImages.toList();
    cards = (images + images)
        .map((image) => CardModel(imagePath: image, isRevealed: false))
        .toList()
      ..shuffle(Random());

    await Future.delayed(const Duration(seconds: 2), () {
      // Kartları 2 saniye açık tut
      cards!.forEach((card) => card.isRevealed = true);
      notifyListeners();

      Future.delayed(const Duration(seconds: 2), () {
        closeCards();
        startLevelTimer();
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
    if (_isChecking || card.isMatched || card.isRevealed) {
      return;
    }

    card.isRevealed = true;
    notifyListeners();

    if (_firstSelectedCard == null) {
      _firstSelectedCard = card;
    } else {
      _isChecking = true;

      Future.delayed(const Duration(seconds: 1), () {
        if (_firstSelectedCard!.imagePath == card.imagePath) {
          _firstSelectedCard!.isMatched = true;
          card.isMatched = true;
          _playMatchSound();
        } else {
          _firstSelectedCard!.isRevealed = false;
          card.isRevealed = false;
        }
        _firstSelectedCard = null;
        _isChecking = false;
        notifyListeners();
        // Oyun bitiş kontrolü
        _checkGameCompletion();
      });
    }
  }

  void _checkGameCompletion() {
    if (cards!.every((card) => card.isMatched)) {
      stopLevelTimer();
      // Geçen süreye göre puan ekle
      int levelScore = max(0, (100 - elapsedSeconds.value) * level);
      totalScore += levelScore;

      if (level == 8) {
        GameDialog.finishGame();
      } else {
        closeCards();
        GameDialog.showLevelUpDialog(levelScore);
      }
    }
  }

  void initializeGame() async {
    isPaused = false;
    await stopLevelTimer();
    initializeCards();
  }

  void restartGame() async {
    level = 1;
    totalScore = 0;
    elapsedSeconds.value = 0;
    stopLevelTimer();
    initializeGame();
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
