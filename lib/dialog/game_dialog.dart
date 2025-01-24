import 'package:bilsemup_minigame/states/game_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class GameDialog {
  static void showLevelUpDialog(int levelScore) {
    showDialog(
        context: Get.context!,
        builder: (_) => Consumer<GameProvider>(
              builder: (_, value, __) => AlertDialog(
                title: Text("Seviye ${value.level} Tamamlandı!"),
                content: Text(
                    "Puanınız: ${value.totalScore}\nBu seviyeden kazandığınız puan: $levelScore"),
                actions: [
                  TextButton(
                    onPressed: () async {
                      Get.back();
                      value.level++;
                      value.initializeCards();
                    },
                    child: const Text("Sonraki Seviye"),
                  ),
                ],
              ),
            ));
  }

  static void finishGame() {
    showDialog(
        context: Get.context!,
        builder: (_) => Consumer<GameProvider>(
              builder: (_, value, __) => AlertDialog(
                title: const Text("Oyun Bitti!"),
                content: Text("Puanınız: ${value.totalScore}"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Get.back();
                      value.restartGame();
                    },
                    child: const Text("Tekrar Dene"),
                  ),
                ],
              ),
            ));
  }

  static void pauseGame() {
    showDialog(
        context: Get.context!,
        builder: (_) => Consumer<GameProvider>(
              builder: (_, value, __) => AlertDialog(
                title: const Text("Oyun Durduruldu!"),
                content: Text("Puanınız: ${value.totalScore}"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Get.back();
                      value.restartGame();
                    },
                    child: const Text("Yeniden Başla"),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.back();
                      value.resume();
                    },
                    child: const Text("Devam Et"),
                  ),
                ],
              ),
            ));
  }
}
