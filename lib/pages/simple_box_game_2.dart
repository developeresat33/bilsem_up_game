import 'dart:async';
import 'package:bilsemup_minigame/common/common_ui_widgets.dart';
import 'package:bilsemup_minigame/game/box_game_2/box_game_logic2.dart';
import 'package:bilsemup_minigame/states/box_game_provider.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class SimpleBoxGame2 extends StatefulWidget {
  @override
  State<SimpleBoxGame2> createState() => _SimpleBoxGame2State();
}

class _SimpleBoxGame2State extends State<SimpleBoxGame2> {
  bool _dialogVisible = true;
  int _countdownTime = 3;
  late Timer _countdownTimer;
  List<GameOptions> options = [];
  List<int> correctAnswers = [];
  int gameIndex = 0;
  var provider = Provider.of<MemoryGameProvider>(Get.context!, listen: false);

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
    provider.totalScore = 0;
    provider.elapsedSeconds.value = 0;
    provider.endOption = 0;
    options = [GameOptions(correctSquares: 3, milliseconds: 400)];

    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdownTime > 1) {
          _countdownTime--;
        } else {
          _countdownTimer.cancel();
          _dialogVisible = false;
          provider.stopLevelTimer();
        }
      });
    });
  }

  @override
  void dispose() {
    if (_countdownTimer.isActive) _countdownTimer.cancel();
    provider.stopLevelTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          title:
              Text('Kutu Oyunu Sıralı', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.blue,
        ),
        backgroundColor: Colors.white,
        body: Column(
          children: [
            if (_dialogVisible) Expanded(child: _showCountdownDialog()),
            if (!_dialogVisible &&
                context.read<MemoryGameProvider>().endOption != 2)
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
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Card(
                                  color: Colors.white,
                                  elevation: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.25,
                                        child: FittedBox(
                                            fit: BoxFit.fitWidth,
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.timeline_rounded,
                                                  size: 15,
                                                  color: Colors.black54,
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                  "Seviye : ",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Text((gameIndex + 1).toString())
                                              ],
                                            ))),
                                  ),
                                )
                              ]),
                          SizedBox(
                            height: 50,
                          ),
                          Container(
                            alignment: Alignment.center,
                            height: MediaQuery.of(context).size.height * 0.3,
                            width: MediaQuery.of(context).size.height * 0.3,
                            child: GameWidget(
                              backgroundBuilder: (context) {
                                return Container(
                                  height: double.maxFinite,
                                  width: double.maxFinite,
                                  color: Colors.white,
                                );
                              },
                              game: MemoryGame2(
                                maxCorrectSquares:
                                    options[gameIndex].correctSquares!,
                                seconds: options[gameIndex].milliseconds!,
                                onFinishGame: () async {
                                  await context
                                      .read<MemoryGameProvider>()
                                      .stopLevelTimer();
                                  if (context
                                          .read<MemoryGameProvider>()
                                          .endOption !=
                                      2) {
                                    int score = context
                                        .read<MemoryGameProvider>()
                                        .calculateScore();
                                    context
                                        .read<MemoryGameProvider>()
                                        .totalScore += score;
                                  }

                                  gameIndex++;
                                  await Future.delayed(
                                      Duration(milliseconds: 50));
                                  setState(() {
                                    context
                                        .read<MemoryGameProvider>()
                                        .elapsedSeconds
                                        .value = 0;
                                    final bool result = context
                                                .read<MemoryGameProvider>()
                                                .endOption ==
                                            1
                                        ? true
                                        : false;

                                    if (result) {
                                      correctAnswers.add(1);
                                    } else {
                                      correctAnswers.add(0);
                                    }

                                    final int correctCount = correctAnswers
                                        .where((answer) => answer == 1)
                                        .length;

                                    if (correctCount >= 20) {
                                      options.add(GameOptions(
                                          correctSquares: 5,
                                          milliseconds: 300));
                                    } else if (correctCount >= 12) {
                                      options.add(GameOptions(
                                          correctSquares: 5,
                                          milliseconds: 325));
                                    } else if (correctCount >= 9) {
                                      options.add(GameOptions(
                                          correctSquares: 4,
                                          milliseconds: 350));
                                    } else if (correctCount >= 4) {
                                      options.add(GameOptions(
                                          correctSquares: 4,
                                          milliseconds: 375));
                                    } else {
                                      options.add(GameOptions(
                                          correctSquares: 3,
                                          milliseconds: 400));
                                    }
                                  });

                                  if (context
                                          .read<MemoryGameProvider>()
                                          .endOption ==
                                      2) {
                                    print(context
                                        .read<MemoryGameProvider>()
                                        .totalScore);
                                  }
                                },
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 50,
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.6,
                                    child: FittedBox(
                                      fit: BoxFit.fitWidth,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          ValueListenableBuilder<int>(
                                            valueListenable: context
                                                .read<MemoryGameProvider>()
                                                .elapsedSeconds,
                                            builder: (context, elapsedSeconds,
                                                child) {
                                              return Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                        width: 150,
                                                        alignment:
                                                            Alignment.center,
                                                        child: FittedBox(
                                                          fit: BoxFit.fitWidth,
                                                          child: Row(
                                                            children: [
                                                              Icon(
                                                                Icons.star,
                                                                color: Colors
                                                                    .black54,
                                                              ),
                                                              SizedBox(
                                                                width: 5,
                                                              ),
                                                              Text(
                                                                "Skor: ${context.read<MemoryGameProvider>().totalScore} ",
                                                              ),
                                                            ],
                                                          ),
                                                        )),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    Container(
                                                        width: 150,
                                                        alignment:
                                                            Alignment.center,
                                                        child: FittedBox(
                                                          fit: BoxFit.fitWidth,
                                                          child: Row(
                                                            children: [
                                                              Icon(
                                                                Icons
                                                                    .access_time_filled,
                                                                color: Colors
                                                                    .black54,
                                                              ),
                                                              SizedBox(
                                                                width: 5,
                                                              ),
                                                              Text(
                                                                "${elapsedSeconds} s",
                                                              ),
                                                            ],
                                                          ),
                                                        ))
                                                  ]);
                                            },
                                          )
                                        ],
                                      ),
                                    ))
                              ]),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Consumer<MemoryGameProvider>(
                          builder: (context, _value, child) {
                        if (_value.endOption != 0)
                          return Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: Container(
                                alignment: Alignment.center,
                                height:
                                    MediaQuery.of(context).size.height * 0.12,
                                width:
                                    MediaQuery.of(context).size.height * 0.12,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 3,
                                      blurRadius: 5,
                                      offset: Offset(
                                          0, 3), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Icon(
                                    _value.endOption == 1
                                        ? Icons.check_circle
                                        : Icons.cancel_outlined,
                                    color: _value.endOption == 1
                                        ? Colors.green
                                        : Colors.red,
                                    size: 40.0,
                                  ),
                                )),
                          );
                        else
                          return Container();
                      }),
                    ),
                  ],
                ),
              ),
            if (context.read<MemoryGameProvider>().endOption == 2)
              CommonUiWidgets.gameOverWidget(context, () {
                if (_countdownTimer.isActive) _countdownTimer.cancel();
                setState(() {
                  _init();
                });
              }, correctAnswers)
          ],
        ),
      ),
    );
  }

  Widget _showCountdownDialog() {
    return Center(
      child: Container(
        width: MediaQuery.of(Get.context!).size.height * 0.09,
        height: MediaQuery.of(Get.context!).size.height * 0.09,
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
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '$_countdownTime',
              style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  color: Colors.lightBlue[800]),
            ),
          ),
        ),
      ),
    );
  }
}

class GameOptions {
  List<Color>? colors;
  int? correctSquares;
  int? milliseconds;

  GameOptions(
      {this.colors, required this.correctSquares, required this.milliseconds});
}
