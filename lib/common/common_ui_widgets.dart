import 'package:bilsemup_minigame/states/box_game_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CommonUiWidgets {
  static gameOverWidget(
      BuildContext context, void Function()? onPressed, List correctAnswers) {
    return StatefulBuilder(
      builder: (context, setState) => Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      "Oyun Bitti",
                      style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
              ],
            ),
            SizedBox(
              height: 15,
            ),
            Row(
              children: [
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.timeline_rounded,
                          color: Colors.black54,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Mevcut Seviye : ${correctAnswers.length}",
                          style: TextStyle(fontSize: 17),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 15,
            ),
            Row(
              children: [
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.black54,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Skor : ${context.read<MemoryGameProvider>().totalScore}",
                          style: TextStyle(fontSize: 17),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  style:  ElevatedButton.styleFrom(
                    surfaceTintColor: Colors.white,
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue
                    
                  ),
                    onPressed: onPressed,
                    icon: Icon(Icons.play_arrow_rounded),
                    label: Text("Tekrar Oyna")),
              ],
            )
          ],
        ),
      ),
    );
  }
}
