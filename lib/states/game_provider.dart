import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:bilsemup_minigame/data/level_data.dart';
import 'package:bilsemup_minigame/dialog/game_dialog.dart';
import 'package:bilsemup_minigame/pages/match_game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:http/http.dart' as http;

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
  int currentPage = 0;
  bool isPaused = false;
  List<CardModel>? cards;
  CardModel? firstSelectedCard;
  bool isChecking = false;
  int gridSize = 5;
  List<List<Color?>>? gridColors;
  List<dynamic>? points;
  dynamic levelData;
  List<List<bool>>? visited;
  Offset? startPoint;
  List<Offset> currentPath = [];
  Map<Color, List<Offset>> completedPaths = {};
  AnimationController? glowAnimationController;
  AnimationController? animationController;
  List<Offset>? animatedPoints;
  final Set<String> _cachedImages = {};
  List<LevelData> levels = [];
  Map<int, List<LevelData>> groupedLevels = {};
  LevelData? selectedLevel;
  double? gridSizePx;
  PageController? pageController;
  String? selectedCategory;

  setCurrentPage(int page) {
    currentPage = page;
    notifyListeners();
  }

  startStopBgmMusic() async {
    if (FlameAudio.bgm.isPlaying) {
      await FlameAudio.bgm.pause();
      isPaused = true;
    } else {
      await FlameAudio.bgm.resume();
      isPaused = false;
    }
    notifyListeners();
  }

  Future<void> loadLevels(String category) async {
    levels = [];
    print('Kategori: $category');
    try {
      // API'den JSON verisi çek
      final response = await http.get(
        Uri.parse('https://bilsemup.com/uygulama/json/$category.json'),
      );

      // HTTP isteğinin başarılı olduğunu kontrol et
      if (response.statusCode == 200) {
        // JSON stringini decode et
        List<dynamic> jsonData = json.decode(response.body);

        // Veriyi LevelData listesine dönüştür
        levels = jsonData.map((data) => LevelData.fromJson(data)).toList();

        // Level verilerini gridSize'e göre grupla
        groupedLevels = {};
        for (var level in levels) {
          groupedLevels[level.gridSize] = [
            ...?groupedLevels[level.gridSize],
            level,
          ];
        }

        pageController!.animateToPage(1,
            duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
        currentPage = 1;
        notifyListeners();
      } else {

        // ENTEGRE'DE DEFAULT MSG PAKETİ KULLANILABİLİR..
        Get.showSnackbar(
          const GetSnackBar(
            message: 'Veri Çekme Başarısız',
            duration: Duration(seconds: 2),
            backgroundColor: Colors.red,
            icon: Icon(
              Icons.error,
              color: Colors.white,
            ),
            snackPosition: SnackPosition.BOTTOM,
            margin: EdgeInsets.all(16),
        ));
        throw Exception('Veri çekme başarısız: ${response.statusCode}');
      }
    } catch (e) {
      print('Bir hata oluştu: $e');
    }
  }

  void handleTouchStart(Offset localPosition) {
    int x = (localPosition.dy ~/
            (MediaQuery.of(Get.context!).size.width / gridSize))
        .clamp(0, gridSize - 1);
    int y = (localPosition.dx ~/
            (MediaQuery.of(Get.context!).size.width / gridSize))
        .clamp(0, gridSize - 1);

    if (gridColors![x][y] != null) {
      final color = gridColors![x][y];

      if (completedPaths.containsKey(color)) {
        resetPathForColor(color!);
      }

      startPoint = Offset(x.toDouble(), y.toDouble());
      currentPath.add(startPoint!);
    }
    notifyListeners();
  }

  void handleTouchUpdate(Offset localPosition) {
    if (startPoint == null) return;

    int x = (localPosition.dy ~/
            (MediaQuery.of(Get.context!).size.width / gridSize))
        .clamp(0, gridSize - 1);
    int y = (localPosition.dx ~/
            (MediaQuery.of(Get.context!).size.width / gridSize))
        .clamp(0, gridSize - 1);

    Offset newPoint = Offset(x.toDouble(), y.toDouble());

    if (visited![x][y] ||
        (gridColors![x][y] != null &&
            gridColors![x][y] !=
                gridColors![startPoint!.dx.toInt()][startPoint!.dy.toInt()])) {
      return;
    }

    if (currentPath.length > 1 &&
        newPoint == currentPath[currentPath.length - 2]) {
      currentPath.removeLast();
      notifyListeners();
      return;
    }

    if ((newPoint.dx == currentPath.last.dx &&
            (newPoint.dy - currentPath.last.dy).abs() == 1) ||
        (newPoint.dy == currentPath.last.dy &&
            (newPoint.dx - currentPath.last.dx).abs() == 1)) {
      if (!currentPath.contains(newPoint)) {
        currentPath.add(newPoint);
        notifyListeners();
      }
    }
  }

  void handleTouchEnd() async {
    if (startPoint != null && currentPath.isNotEmpty) {
      Offset lastPoint = currentPath.last;

      if (gridColors![lastPoint.dx.toInt()][lastPoint.dy.toInt()] ==
          gridColors![startPoint!.dx.toInt()][startPoint!.dy.toInt()]) {
        final color =
            gridColors![startPoint!.dx.toInt()][startPoint!.dy.toInt()]!;
        completedPaths[color] = List.from(currentPath);

        for (var point in currentPath) {
          visited![point.dx.toInt()][point.dy.toInt()] = true;
        }

        animatedPoints = [startPoint!, lastPoint];
        animationController!.forward(from: 0);
        await Future.delayed(const Duration(milliseconds: 100));
        await animationController!.reverse();

        await FlameAudio.play('sound/connect.mp3', volume: 0.8);
      }
    }

    startPoint = null;
    currentPath.clear();
    notifyListeners();
  }

  void resetPathForColor(Color color) {
    if (!completedPaths.containsKey(color)) return;

    final path = completedPaths[color]!;
    for (var point in path) {
      visited![point.dx.toInt()][point.dy.toInt()] = false;
    }

    completedPaths.remove(color);
    notifyListeners();
  }

  bool isGameCompleted() {
    for (var point in points!) {
      final color = getColorFromName(point['color']);
      final x = point['x'];
      final y = point['y'];

      if (!completedPaths.containsKey(color) ||
          !completedPaths[color]!
              .contains(Offset(x.toDouble(), y.toDouble()))) {
        return false;
      }
    }
    return true;
  }

  Future<void> setAnimationControllers(
    TickerProvider async,
  ) async {
    animationController = AnimationController(
      vsync: async,
      duration: const Duration(milliseconds: 200),
    )..addListener(() {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
      });

    glowAnimationController = AnimationController(
      vsync: async,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  void disposeAnimateControllers() {
    if (animationController != null) {
      if (animationController!.isAnimating) {
        animationController!.stop(); // Animasyonu durdur
      }
      animationController!.dispose(); // AnimationController'ı temizle
      animationController = null;
    }
    if (glowAnimationController != null) {
      if (glowAnimationController!.isAnimating) {
        glowAnimationController!.stop(); // Animasyonu durdur
      }
      glowAnimationController!.dispose(); // AnimationController'ı temizle
      glowAnimationController = null;
    }
  }

  Future<void> initializeGameFromJson() async {
    hasStartGame = false;
    notifyListeners();
    levelData = selectedLevel!.toJson();
    completedPaths = {};
    gridSize = levelData["gridSize"];
    points = levelData["points"];
    gridSizePx = MediaQuery.of(Get.context!).size.width / gridSize;

    visited =
        List.generate(gridSize, (_) => List.generate(gridSize, (_) => false));

    gridColors =
        List.generate(gridSize, (_) => List.generate(gridSize, (_) => null));

    animatedPoints = [];
    for (var point in points!) {
      int x = point["x"];
      int y = point["y"];
      String colorName = point["color"];
      gridColors![x][y] = getColorFromName(colorName);

      animatedPoints!.add(Offset(x.toDouble(), y.toDouble()));
    }

    animationController!.forward(from: 0);

    await Future.delayed(const Duration(milliseconds: 300));

    await animationController!.reverse();
    hasStartGame = true;
    notifyListeners();
  }

  Color getColorFromName(String colorName) {
    switch (colorName.toLowerCase()) {
      case "red":
        return Colors.red;
      case "blue":
        return Colors.blue;
      case "green":
        return Colors.green;
      case "yellow":
        return Colors.yellow;
      case "orange":
        return Colors.orange;
      case "purple":
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

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
