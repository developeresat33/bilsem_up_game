import 'dart:async';
import 'dart:developer';

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
  bool _dialogVisible = true;
  int _countdownTime = 3;
  late Timer _countdownTimer;
  List<GameOptions> options = [];
  List<int> correctAnswers = [];
  int gameIndex = 0;
  List<Color> nodeColor = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() async {
    _countdownTime = 3;
    _dialogVisible = true;
    correctAnswers = [];
    gameIndex = 0;
    options = [
      GameOptions(
          colors: [Colors.blue, Colors.red, Colors.green],
          correctSquares: 3,
          milliseconds: 100)
    ];
    nodeColor = [
      Colors.blue[400]!,
      Colors.blue[400]!,
      Colors.blue[400]!,
      Colors.blue[400]!,
      Colors.blue[400]!
    ];

    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdownTime > 1) {
          _countdownTime--;
        } else {
          _countdownTimer.cancel();
          _dialogVisible = false;
        }
      });
    });
  }

  @override
  void dispose() {
    _countdownTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Simple Box Game', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.blue,
        ),
        backgroundColor: Colors.white,
        body: Column(
          children: [
            if (_dialogVisible)
              Expanded(child: _showCountdownDialog()), // Countdown gösterilir
            if (!_dialogVisible && gameIndex != 5)
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      height: double.maxFinite,
                      width: double.maxFinite,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(children: [
                            Expanded(
                                child: FittedBox(
                              fit: BoxFit.contain,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: _buildNodes(
                                  5,
                                ),
                              ),
                            ))
                          ]),
                          SizedBox(
                            height: 50,
                          ),
                          Container(
                            color: Colors.black,
                            height: 400,
                            width: 400,
                            child: GameWidget(
                              backgroundBuilder: (context) {
                                return Container(
                                  height: double.maxFinite,
                                  width: double.maxFinite,
                                  color: Colors.white,
                                );
                              },
                              game: MemoryGame(
                                colors: options[gameIndex].colors!,
                                maxCorrectSquares:
                                    options[gameIndex].correctSquares!,
                                seconds: options[gameIndex].milliseconds!,
                                onFinishGame: () async {
                                  gameIndex++;
                                  await Future.delayed(
                                      Duration(milliseconds: 50));
                                  setState(() {
                                    final bool result = context
                                                .read<MemoryGameProvider>()
                                                .endOption
                                                .value ==
                                            1
                                        ? true
                                        : false;
      
                                    if (result) {
                                      correctAnswers.add(1);
                                      nodeColor[gameIndex - 1] = Colors.green;
                                    } else {
                                      correctAnswers.add(0);
                                      nodeColor[gameIndex - 1] = Colors.red;
                                    }
      
                                    final int correctCount = correctAnswers
                                        .where((answer) => answer == 1)
                                        .length;
      
                                    if (correctCount == 4) {
                                      options.add(GameOptions(colors: [
                                        Colors.blue,
                                        Colors.red,
                                        Colors.green,
                                        Colors.yellow,
                                        Colors.purple
                                      ], correctSquares: 5, milliseconds: 50));
                                    } else if (correctCount >= 2) {
                                      options.add(GameOptions(colors: [
                                        Colors.blue,
                                        Colors.red,
                                        Colors.green,
                                        Colors.yellow
                                      ], correctSquares: 4, milliseconds: 70));
                                    } else {
                                      options.add(GameOptions(colors: [
                                        Colors.blue,
                                        Colors.red,
                                        Colors.green
                                      ], correctSquares: 3, milliseconds: 100));
                                    }
                                  });
      
                                  print("CORRECT ANSWER: ${correctAnswers}");
                                  print("GAME INDEX: ${gameIndex}");
                                  inspect(options);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Consumer<MemoryGameProvider>(
                          builder: (context, _value, child) =>
                              ValueListenableBuilder<int>(
                                  valueListenable: _value.endOption,
                                  builder: (context, value, child) {
                                    if (value != 0)
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 80.0),
                                        child: Container(
                                            alignment: Alignment.center,
                                            height: 200,
                                            width: 200,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.5),
                                                  spreadRadius: 3,
                                                  blurRadius: 5,
                                                  offset: Offset(0,
                                                      3), // changes position of shadow
                                                ),
                                              ],
                                            ),
                                            child: Icon(
                                              value == 1
                                                  ? Icons.check_circle
                                                  : Icons.cancel_outlined,
                                              color: value == 1
                                                  ? Colors.green
                                                  : Colors.red,
                                              size: 80.0,
                                            )),
                                      );
                                    else
                                      return Container();
                                  })),
                    ),
                  ],
                ),
              ),
            if (gameIndex == 5)
              Expanded(
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
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: Colors.black87, width: 2),
                            ),
                            height: 150,
                            child: Center(
                              child: Text(
                                "Oyun Bitti",
                                style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Doğru sayısı: ${correctAnswers.where((answer) => answer == 1).length}",
                          style: TextStyle(fontSize: 25),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Text(
                            "Yanlış sayısı: ${correctAnswers.where((answer) => answer == 0).length}",
                            style: TextStyle(fontSize: 25)),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _init();
                              });
                            },
                            icon: Icon(
                              Icons.refresh,
                              size: 45,
                            ),
                            label: Text(
                              "Tekrar Oyna",
                              style: TextStyle(fontSize: 30),
                            )),
                      ],
                    )
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _showCountdownDialog() {
    return Center(
      child: Container(
        width: 100,
        height: 100,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 3,
              blurRadius: 5,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Text(
            '$_countdownTime',
            style: TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.bold,
                color: Colors.lightBlue[800]),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildNodes(
    int count,
  ) {
    return List.generate(count, (index) {
      return Container(
        width: 80,
        height: 20,
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: nodeColor[index],
          borderRadius: BorderRadius.circular(5.0),
        ),
      );
    });
  }
}

class GameOptions {
  List<Color>? colors;
  int? correctSquares;
  int? milliseconds;

  GameOptions(
      {required this.colors,
      required this.correctSquares,
      required this.milliseconds});
}
