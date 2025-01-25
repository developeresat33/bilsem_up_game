import 'package:bilsemup_minigame/states/game_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class GameDialog {
  static const Color backgroundColor = Color.fromRGBO(100, 89, 181, 1);
  static const Color buttonStartColor = Color.fromARGB(255, 255, 145, 0);
  static const Color buttonEndColor = Color.fromARGB(255, 255, 200, 50);

  static ButtonStyle cartoonButtonStyle = ButtonStyle(
    padding:
        MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 12)),
    backgroundColor: MaterialStateProperty.all(Colors.transparent),
    shape: MaterialStateProperty.all(RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    )),
    overlayColor: MaterialStateProperty.all(buttonEndColor.withOpacity(0.2)),
    elevation: MaterialStateProperty.all(5),
  );

  static Widget cartoonButton(String text, VoidCallback onPressed) {
    return Ink(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [buttonStartColor, buttonEndColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onPressed,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  blurRadius: 2,
                  color: Colors.black26,
                  offset: Offset(1, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void showLevelUpDialog(int levelScore) {
    showDialog(
      barrierDismissible: false,
      context: Get.context!,
      builder: (_) => WillPopScope(
        onWillPop: () => Future.value(false),
        child: Consumer<GameProvider>(
          builder: (_, value, __) => AlertDialog(
            backgroundColor: backgroundColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(
              "Seviye ${value.level} Tamamlandı!",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            content: Text(
              "Puanınız: ${value.totalScore}\nBu seviyeden kazandığınız puan: $levelScore",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, color: Colors.white70),
            ),
            actions: [
              cartoonButton("Sonraki Seviye", () async {
                Get.back();
                await Future.delayed(const Duration(milliseconds: 100));
                value.level++;
                if (value.level % 4 == 0) value.stage++;
                value.resetCustomTimer();
                value.elapsedSeconds.value = 0;

                value.initializeCards();
              }),
            ],
          ),
        ),
      ),
    );
  }

  static void finishGame() {
    showDialog(
      barrierDismissible: false,
      context: Get.context!,
      builder: (_) => WillPopScope(
        onWillPop: () => Future.value(false),
        child: Consumer<GameProvider>(
          builder: (_, value, __) => AlertDialog(
            backgroundColor: backgroundColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text(
              "Oyun Bitti!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            content: Text(
              "Puanınız: ${value.totalScore}",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, color: Colors.white70),
            ),
            actions: [
              cartoonButton("Tekrar Dene", () {
                Get.back();
                value.restartGame();
              }),
            ],
          ),
        ),
      ),
    );
  }

  static void pauseGame() {
    showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (_) => WillPopScope(
        onWillPop: () => Future.value(false),
        child: Consumer<GameProvider>(
          builder: (_, value, __) => AlertDialog(
            backgroundColor: backgroundColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(
              "Oyun Durduruldu! | Puanınız: ${value.totalScore}",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  cartoonButton("Devam Et", () {
                    Get.back();
                    value.startCustomTimer();
                  }),
                  const SizedBox(height: 10),
                  cartoonButton("Seviyeyi Yeniden Başlat", () {
                    Get.back();
                    value.resetCustomTimer();
                    value.elapsedSeconds.value = 0;
                    value.initializeCards();
                  }),
                  const SizedBox(height: 10),
                  cartoonButton("Tekrar Dene", () {
                    Get.back();
                    value.restartGame();
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
