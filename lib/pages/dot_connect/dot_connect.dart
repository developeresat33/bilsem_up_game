import 'package:animated_background/animated_background.dart';
import 'package:bilsemup_minigame/dialog/game_dialog.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'package:bilsemup_minigame/states/game_provider.dart';

class DotGameScreen extends StatefulWidget {
  const DotGameScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<DotGameScreen> createState() => _DotGameScreenState();
}

class _DotGameScreenState extends State<DotGameScreen>
    with TickerProviderStateMixin {
  bool? loaded = true;
  var value = Provider.of<GameProvider>(Get.context!, listen: false);

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  _initGame({bool afterInit = false}) async {
    if (!afterInit) {
      await value.setAnimationControllers(this);
    }
    await value.initializeGameFromJson();
  }

  @override
  void dispose() {
    value.disposeAnimateControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final glowOpacity = Tween<double>(begin: 0.5, end: 1.0)
        .animate(value.glowAnimationController!);

    return Consumer<GameProvider>(
      builder: (context, _value, child) => SafeArea(
        child: Scaffold(
          floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
          floatingActionButton: FloatingActionButton(
            backgroundColor: Color.fromARGB(255, 34, 34, 34).withOpacity(0.8),
            child: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () async {
              Get.back();
            },
          ),
          appBar: AppBar(
            leading: null,
            leadingWidth: 0,
            backgroundColor: Colors.transparent,
            centerTitle: false,
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    'Dot Connect ${_value.selectedLevel!.gridSize}x${_value.selectedLevel!.gridSize} |  ${_value.selectedLevel!.level}',
                    maxLines: 2,
                    style: TextStyle(
                        color: Colors.white, overflow: TextOverflow.ellipsis),
                  ),
                ),
              ],
            ),
            actions: [
              CircleAvatar(
                backgroundColor:
                    Color.fromARGB(255, 34, 34, 34).withOpacity(0.8),
                child: IconButton(
                  icon: Icon(
                    FlameAudio.bgm.isPlaying
                        ? Icons.music_note
                        : Icons.music_off,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    _value.startStopBgmMusic();
                  },
                ),
              ),
              SizedBox(
                width: 10,
              ),
            ],
          ),
          backgroundColor: const Color.fromARGB(255, 19, 19, 19),
          body: _value.hasStartGame!
              ? AnimatedBackground(
                  vsync: this,
                  behaviour: RandomParticleBehaviour(
                    options: ParticleOptions(
                      image: Image.asset(
                        'assets/img/space.png',
                      ),
                      particleCount: 30,
                      spawnOpacity: 0.1,
                      spawnMaxSpeed: 50,
                      spawnMaxRadius: 20,
                      spawnMinSpeed: 15,
                      baseColor: Colors.white,
                    ),
                    paint: Paint(),
                  ),
                  child: Stack(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onPanStart: (details) {
                              _value.handleTouchStart(details.localPosition);
                            },
                            onPanUpdate: (details) {
                              _value.handleTouchUpdate(details.localPosition);
                            },
                            onPanEnd: (_) {
                              _value.handleTouchEnd();
                            },
                            child: CustomPaint(
                              size: Size(_value.gridSizePx! * _value.gridSize,
                                  _value.gridSizePx! * _value.gridSize),
                              painter: GridPainter(
                                gridSize: _value.gridSize,
                                gridColors: _value.gridColors!,
                                completedPaths: _value.completedPaths,
                                currentPath: _value.currentPath,
                                gridSizePx: _value.gridSizePx!,
                                animatedPoints: _value.animatedPoints,
                                scale: _value.animationController!.value,
                                glowOpacity: glowOpacity,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_value.isGameCompleted() &&
                          _value.selectedLevel!.level != _value.levels.length)
                        Positioned(
                          bottom: 20,
                          right: 10,
                          child: GameDialog.darkThemeButton(
                            "Devam Et",
                            () async {
                              int lvl = value.selectedLevel!.level + 1;
                              value.selectedLevel = value.levels[lvl - 1];
                              _initGame(afterInit: true);
                            },
                          ),
                        ),
                    ],
                  ),
                )
              : Center(
                  child: CircularProgressIndicator(
                    color: Colors.white70,
                  ),
                ),
        ),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  final int gridSize;
  final List<List<Color?>> gridColors;
  final Map<Color, List<Offset>> completedPaths;
  final List<Offset> currentPath;
  final double gridSizePx;
  final List<Offset>? animatedPoints;
  final double scale;
  final Animation<double> glowOpacity;

  GridPainter({
    required this.gridSize,
    required this.gridColors,
    required this.completedPaths,
    required this.currentPath,
    required this.gridSizePx,
    required this.animatedPoints,
    required this.scale,
    required this.glowOpacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = const Color.fromARGB(255, 45, 45, 45)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);

    final gridPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color.fromARGB(255, 54, 54, 54);

    for (int i = 0; i <= gridSize; i++) {
      double offset = i * gridSizePx;
      canvas.drawLine(
          Offset(offset, 0), Offset(offset, size.height), gridPaint);
      canvas.drawLine(Offset(0, offset), Offset(size.width, offset), gridPaint);
    }

    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (gridColors[i][j] != null) {
          final dotPaint = Paint()
            ..color = gridColors[i][j]!
            ..style = PaintingStyle.fill;

          double circleRadius = gridSizePx / 3;

          if (animatedPoints != null &&
              animatedPoints!.contains(Offset(i.toDouble(), j.toDouble()))) {
            circleRadius *= (1 + 0.2 * scale); // Animate scale
          }

          canvas.drawCircle(
            Offset(j * gridSizePx + gridSizePx / 2,
                i * gridSizePx + gridSizePx / 2),
            circleRadius,
            dotPaint,
          );
        }
      }
    }

    completedPaths.forEach((color, path) {
      final pathPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..shader = _createGlowShader(color, path, gridSizePx);

      _drawSmoothPath(canvas, path, pathPaint);
    });

    if (currentPath.isNotEmpty) {
      final activePathPaint = Paint()
        ..color = gridColors[currentPath.first.dx.toInt()]
            [currentPath.first.dy.toInt()]!
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8;

      _drawSmoothPath(canvas, currentPath, activePathPaint);
    }
  }

  Shader _createGlowShader(Color color, List<Offset> path, double gridSizePx) {
    final startPoint = path.first;
    final endPoint = path.last;

    final glowOpacityValue = glowOpacity.value;

    final gradientColors = [
      color.withOpacity(glowOpacityValue * 0.5),
      color.withOpacity(glowOpacityValue),
      color.withOpacity(glowOpacityValue * 0.5),
    ];

    return LinearGradient(
      colors: gradientColors,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      stops: [0.0, 0.5, 1.0],
    ).createShader(Rect.fromPoints(
      Offset(startPoint.dy * gridSizePx, startPoint.dx * gridSizePx),
      Offset(endPoint.dy * gridSizePx, endPoint.dx * gridSizePx),
    ));
  }

  void _drawSmoothPath(Canvas canvas, List<Offset> path, Paint paint) {
    if (path.length < 2) return;

    final pathToDraw = Path();
    pathToDraw.moveTo(
      path.first.dy * gridSizePx + gridSizePx / 2,
      path.first.dx * gridSizePx + gridSizePx / 2,
    );

    for (int i = 0; i < path.length - 1; i++) {
      final current = path[i];
      final next = path[i + 1];

      final midX = (current.dy + next.dy) / 2;
      final midY = (current.dx + next.dx) / 2;

      pathToDraw.quadraticBezierTo(
        current.dy * gridSizePx + gridSizePx / 2,
        current.dx * gridSizePx + gridSizePx / 2,
        midX * gridSizePx + gridSizePx / 2,
        midY * gridSizePx + gridSizePx / 2,
      );
    }

    final lastPoint = path.last;
    pathToDraw.lineTo(
      lastPoint.dy * gridSizePx + gridSizePx / 2,
      lastPoint.dx * gridSizePx + gridSizePx / 2,
    );

    canvas.drawPath(pathToDraw, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
