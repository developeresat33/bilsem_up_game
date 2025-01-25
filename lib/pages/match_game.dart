import 'dart:math';
import 'package:animated_background/animated_background.dart';
import 'package:bilsemup_minigame/dialog/game_dialog.dart';
import 'package:bilsemup_minigame/states/game_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class MatchGame extends StatefulWidget {
  @override
  _MatchGameState createState() => _MatchGameState();
}

class _MatchGameState extends State<MatchGame> with TickerProviderStateMixin {
  var value = Provider.of<GameProvider>(Get.context!, listen: false);

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    value.firstInitGame();
    value.initializeCards();
  }

  @override
  void dispose() {
    value.disposeCustomTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
        builder: (context, _value, child) => PopScope(
              onPopInvoked: (didPop) {
                SystemChrome.setPreferredOrientations([
                  DeviceOrientation.portraitUp,
                  DeviceOrientation.portraitDown,
                ]);
              },
              child: Scaffold(
                backgroundColor: Color.fromRGBO(100, 89, 181, 1),
                body: SafeArea(
                  child: AnimatedBackground(
                    vsync: this,
                    behaviour: RandomParticleBehaviour(
                      options: ParticleOptions(
                          particleCount: 30,
                          spawnOpacity: 0.1,
                          spawnMaxSpeed: 50,
                          spawnMaxRadius: 20,
                          spawnMinSpeed: 15,
                          baseColor: Colors.white),
                    ),
                    child: Column(
                      children: [
                        ValueListenableBuilder<int>(
                            valueListenable: _value.elapsedSeconds,
                            builder: (context, elapsedSeconds, child) {
                              return Stack(
                                children: [
                                  if (_value.hasStartGame!)
                                    Positioned(
                                      right: 25,
                                      top: 10,
                                      child: SizedBox(
                                          height: 20,
                                          width: 70,
                                          child: FittedBox(
                                            fit: BoxFit.fitWidth,
                                            child: IconButton(
                                              onPressed: () async {
                                                value.stopCustomTimer();
                                                GameDialog.pauseGame();
                                              },
                                              icon: Icon(
                                                _value.isPaused
                                                    ? Icons.play_arrow
                                                    : Icons.pause,
                                                color: Color.fromARGB(
                                                    255, 255, 145, 0),
                                              ),
                                            ),
                                          )),
                                    ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            ' Seviye: ${_value.level}, Puan: ${_value.totalScore} | Geçen Süre: $elapsedSeconds saniye',
                                            style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Color.fromRGBO(
                                                    255, 217, 0, 1)),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            }),
                        Expanded(
                          child: GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: _value.stage + 1,
                                    crossAxisSpacing: 5,
                                    mainAxisSpacing: 5,
                                    mainAxisExtent:
                                        MediaQuery.of(context).size.height *
                                            0.39,
                                    childAspectRatio: 2),
                            itemCount: _value.cards!.length,
                            itemBuilder: (context, index) {
                              final card = _value.cards![index];
                              return GestureDetector(
                                onTap: () => _value.onCardTap(card),
                                child: CardWidget(card: card),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ));
  }
}

class CardModel {
  final String imagePath;
  bool isRevealed;
  bool isMatched;

  CardModel({
    required this.imagePath,
    this.isRevealed = false,
    this.isMatched = false,
  });
}

class CardWidget extends StatefulWidget {
  final CardModel card;

  const CardWidget({Key? key, required this.card}) : super(key: key);

  @override
  _CardWidgetState createState() => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    if (widget.card.isRevealed) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant CardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.card.isRevealed) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final isFront = _controller.value < 0.5;
        final rotationValue = _controller.value * pi;

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.rotationY(rotationValue),
          child: isFront
              ? _buildBackSide()
              : Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(pi),
                  child: _buildFrontSide(),
                ),
        );
      },
    );
  }

  Widget _buildBackSide() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 255, 187, 0),
            Color.fromARGB(255, 224, 165, 0),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
          child: Image.asset(
        'assets/img/bilsemup_logo.png',
        opacity: const AlwaysStoppedAnimation<double>(1),
        color: Colors.white70,
      )),
    );
  }

  Widget _buildFrontSide() {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 44, 29, 0),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purple, width: 1),
      ),
      child: Image.network(
        widget.card.imagePath,
        fit: BoxFit.scaleDown,
        errorBuilder: (context, error, stackTrace) => Center(
            child: Image.asset(
          'assets/img/bilsemup_logo.png',
          opacity: const AlwaysStoppedAnimation<double>(0.8),
          color: Colors.white,
        )),
      ),
    );
  }
}
