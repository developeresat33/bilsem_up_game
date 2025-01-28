import 'dart:async';

import 'package:animated_background/animated_background.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  int gridSize = 5; // 5x5 grid
  late List<List<Color?>> gridColors; // 2D Grid Colors
  late List<dynamic> points; // Points from JSON
  dynamic levelData;
  late List<List<bool>> visited; // Keeps track of visited cells
  Offset? startPoint; // Starting point of the current line
  List<Offset> currentPath = []; // Stores the current drawing path
  Map<Color, List<Offset>> completedPaths = {}; // Stores completed paths

  late AnimationController _glowAnimationController;
  late AnimationController _animationController;
  List<Offset>? animatedPoints; // The two points to animate

  @override
  void initState() {
    super.initState();
    levelData = {
      "level": 1,
      "gridSize": 5,
      "points": [
        {"x": 0, "y": 0, "color": "red"},
        {"x": 2, "y": 0, "color": "red"},
        {"x": 1, "y": 3, "color": "blue"},
        {"x": 4, "y": 3, "color": "blue"},
        {"x": 3, "y": 1, "color": "green"},
        {"x": 4, "y": 4, "color": "green"}
      ]
    };

    // Initialize Animation Controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..addListener(() {
        setState(() {});
      });

    _glowAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _initializeGameFromJson();
  }

  void _initializeGameFromJson() async {
    completedPaths = {};
    gridSize = levelData["gridSize"];
    points = levelData["points"];

    visited =
        List.generate(gridSize, (_) => List.generate(gridSize, (_) => false));

    gridColors =
        List.generate(gridSize, (_) => List.generate(gridSize, (_) => null));

    animatedPoints = [];
    for (var point in points) {
      int x = point["x"];
      int y = point["y"];
      String colorName = point["color"];
      gridColors[x][y] = _getColorFromName(colorName);

      animatedPoints!.add(Offset(x.toDouble(), y.toDouble()));
    }

    _animationController.forward(from: 0);

    await Future.delayed(const Duration(milliseconds: 300));

    await _animationController.reverse();

    setState(() {});
  }

  Color _getColorFromName(String colorName) {
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

  bool _isGameCompleted() {
    for (var point in points) {
      final color = _getColorFromName(point['color']);
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

  void _handleTouchStart(Offset localPosition) {
    int x = (localPosition.dy ~/ (MediaQuery.of(context).size.width / gridSize))
        .clamp(0, gridSize - 1);
    int y = (localPosition.dx ~/ (MediaQuery.of(context).size.width / gridSize))
        .clamp(0, gridSize - 1);

    setState(() {
      if (gridColors[x][y] != null) {
        final color = gridColors[x][y];

        if (completedPaths.containsKey(color)) {
          _resetPathForColor(color!);
        }

        startPoint = Offset(x.toDouble(), y.toDouble());
        currentPath.add(startPoint!);
      }
    });
  }

  void _handleTouchUpdate(Offset localPosition) {
    if (startPoint == null) return;

    int x = (localPosition.dy ~/ (MediaQuery.of(context).size.width / gridSize))
        .clamp(0, gridSize - 1);
    int y = (localPosition.dx ~/ (MediaQuery.of(context).size.width / gridSize))
        .clamp(0, gridSize - 1);

    Offset newPoint = Offset(x.toDouble(), y.toDouble());

    if (visited[x][y] ||
        (gridColors[x][y] != null &&
            gridColors[x][y] !=
                gridColors[startPoint!.dx.toInt()][startPoint!.dy.toInt()])) {
      return;
    }

    if (currentPath.length > 1 &&
        newPoint == currentPath[currentPath.length - 2]) {
      currentPath.removeLast();
      setState(() {});
      return;
    }

    if ((newPoint.dx == currentPath.last.dx &&
            (newPoint.dy - currentPath.last.dy).abs() == 1) ||
        (newPoint.dy == currentPath.last.dy &&
            (newPoint.dx - currentPath.last.dx).abs() == 1)) {
      if (!currentPath.contains(newPoint)) {
        currentPath.add(newPoint);
        setState(() {});
      }
    }
  }

  void _handleTouchEnd() async {
    if (startPoint != null && currentPath.isNotEmpty) {
      Offset lastPoint = currentPath.last;

      if (gridColors[lastPoint.dx.toInt()][lastPoint.dy.toInt()] ==
          gridColors[startPoint!.dx.toInt()][startPoint!.dy.toInt()]) {
        final color =
            gridColors[startPoint!.dx.toInt()][startPoint!.dy.toInt()]!;
        completedPaths[color] = List.from(currentPath);

        for (var point in currentPath) {
          visited[point.dx.toInt()][point.dy.toInt()] = true;
        }

        animatedPoints = [startPoint!, lastPoint];
        _animationController.forward(from: 0);
        await Future.delayed(const Duration(milliseconds: 100));
        await _animationController.reverse();

        await FlameAudio.play('sound/connect.mp3', volume: 0.8);
      }
    }

    startPoint = null;
    currentPath.clear();
    setState(() {});
  }

  void _resetPathForColor(Color color) {
    if (!completedPaths.containsKey(color)) return;

    final path = completedPaths[color]!;
    for (var point in path) {
      visited[point.dx.toInt()][point.dy.toInt()] = false;
    }

    completedPaths.remove(color);
    setState(() {});
  }

  @override
  void dispose() {
    _animationController.dispose();
    _glowAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double gridSizePx = MediaQuery.of(context).size.width / gridSize;
    final glowOpacity =
        Tween<double>(begin: 0.5, end: 1.0).animate(_glowAnimationController);
    return SafeArea(
        child: Scaffold(
      backgroundColor: const Color.fromARGB(255, 19, 19, 19),
      body: AnimatedBackground(
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
                baseColor: Colors.white),
            paint: Paint()),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onPanStart: (details) {
                    _handleTouchStart(details.localPosition);
                  },
                  onPanUpdate: (details) {
                    _handleTouchUpdate(details.localPosition);
                  },
                  onPanEnd: (_) {
                    _handleTouchEnd();
                  },
                  child: CustomPaint(
                    size: Size(gridSizePx * gridSize, gridSizePx * gridSize),
                    painter: GridPainter(
                        gridSize: gridSize,
                        gridColors: gridColors,
                        completedPaths: completedPaths,
                        currentPath: currentPath,
                        gridSizePx: gridSizePx,
                        animatedPoints: animatedPoints,
                        scale: _animationController.value,
                        glowOpacity: glowOpacity),
                  ),
                ),
              ],
            ),
            if (_isGameCompleted())
              Align(
                alignment: Alignment.bottomCenter,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _initializeGameFromJson();
                      completedPaths.clear();
                    });
                  },
                  child: const Text("Yeni Oyun"),
                ),
              ),
          ],
        ),
      ),
    ));
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
