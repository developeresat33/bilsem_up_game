import 'package:bilsemup_minigame/game/box_game/box_game_logic.dart';
import 'package:bilsemup_minigame/states/box_game_provider.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

class SimpleBoxGame extends StatefulWidget {
  @override
  State<SimpleBoxGame> createState() => _SimpleBoxGameState();
}

class _SimpleBoxGameState extends State<SimpleBoxGame> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 400,
            width: 500,
            child: GameWidget(
              backgroundBuilder: (context) {
                return Container(
                  height: double.maxFinite,
                  width: double.maxFinite,
                  color: Colors.white,
                );
              },
              game: MemoryGame(), // MemoryGame'yi buraya bağla
            ),
          ),
          Spacer(),
          Consumer<MemoryGameProvider>(
              builder: (context, _value, child) => ValueListenableBuilder<int>(
                  valueListenable: _value.endOption,
                  builder: (context, value, child) {
                    if (value != 0)
                      return Text(
                        value == 1
                            ? "Tebrikler Oyunu Kazandınız"
                            : "Oyunu Kaybettiniz",
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold),
                      );
                    else
                      return Container();
                  })),
          Spacer()
        ],
      ),
    );
  }
}
