import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int gridSize = 5; // 5x5 grid
  late List<List<Color?>> gridColors; // 2D Grid Colors
  late List<dynamic> points; // Points from JSON
  dynamic levelData;
  late List<List<bool>> visited; // Keeps track of visited cells
  Offset? startPoint; // Starting point of the current line
  List<Offset> currentPath = []; // Stores the current drawing path
  Map<Color, List<Offset>> completedPaths = {}; // Stores completed paths
  // Example JSON Level Data

  @override
  void initState() {
    super.initState();
    levelData = {
      "level": 1,
      "gridSize": 6,
      "points": [
        {"x": 0, "y": 0, "color": "red"},
        {"x": 2, "y": 0, "color": "red"},
        {"x": 1, "y": 3, "color": "blue"},
        {"x": 4, "y": 3, "color": "blue"},
        {"x": 3, "y": 1, "color": "green"},
        {"x": 4, "y": 4, "color": "green"}
      ]
    };
    _initializeGameFromJson();
  }

  void _initializeGameFromJson() {
    completedPaths = {};
    gridSize = levelData["gridSize"];
    points = levelData["points"];

    visited =
        List.generate(gridSize, (_) => List.generate(gridSize, (_) => false));

    gridColors =
        List.generate(gridSize, (_) => List.generate(gridSize, (_) => null));

    for (var point in points) {
      int x = point["x"];
      int y = point["y"];
      String colorName = point["color"];
      gridColors[x][y] = _getColorFromName(colorName);
    }

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
    // Tamamlanan yollar tüm noktaları bağlamalı
    for (var point in points) {
      final color = _getColorFromName(point['color']);
      final x = point['x'];
      final y = point['y'];

      // Eğer bu renk için yol yoksa veya bu nokta visited değilse oyun tamamlanmamış
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

      // Eğer bu renk zaten tamamlanmışsa, mevcut yolu temizle
      if (completedPaths.containsKey(color)) {
        _resetPathForColor(color!); // Bu renk grubunu temizle
      }

      startPoint = Offset(x.toDouble(), y.toDouble());
      currentPath.add(startPoint!);
    }
});
    // Eğer bir nokta başlangıç noktasıysa, işlemi başlat

  }

void _handleTouchUpdate(Offset localPosition) {
  if (startPoint == null) return;

  int x = (localPosition.dy ~/ (MediaQuery.of(context).size.width / gridSize))
      .clamp(0, gridSize - 1);
  int y = (localPosition.dx ~/ (MediaQuery.of(context).size.width / gridSize))
      .clamp(0, gridSize - 1);

  Offset newPoint = Offset(x.toDouble(), y.toDouble());

  // Eğer yeni nokta zaten ziyaret edilmişse veya başka bir renk noktasına temas ediyorsa
  if (visited[x][y] ||
      (gridColors[x][y] != null &&
          gridColors[x][y] !=
              gridColors[startPoint!.dx.toInt()][startPoint!.dy.toInt()])) {
    return; // Geçerli bir hareket değil, ekleme yapma
  }

  // Eğer geri dönme durumu varsa
  if (currentPath.length > 1 && newPoint == currentPath[currentPath.length - 2]) {
    currentPath.removeLast(); // Son eklenen noktayı sil
    setState(() {});
    return;
  }

  // Sadece yukarı, aşağı, sağ, sol hareketlere izin ver
  if ((newPoint.dx == currentPath.last.dx &&
          (newPoint.dy - currentPath.last.dy).abs() == 1) ||
      (newPoint.dy == currentPath.last.dy &&
          (newPoint.dx - currentPath.last.dx).abs() == 1)) {
    if (!currentPath.contains(newPoint)) {
      currentPath.add(newPoint); // Yeni noktayı ekle
      setState(() {});
    }
  }
}


  void _handleTouchEnd() async {
    if (startPoint != null && currentPath.isNotEmpty) {
      Offset lastPoint = currentPath.last;

      // Renk eşleşmesi kontrolü
      if (gridColors[lastPoint.dx.toInt()][lastPoint.dy.toInt()] ==
          gridColors[startPoint!.dx.toInt()][startPoint!.dy.toInt()]) {
        final color =
            gridColors[startPoint!.dx.toInt()][startPoint!.dy.toInt()]!;
        completedPaths[color] = List.from(currentPath);

        // Yolu işaretle
        for (var point in currentPath) {
          visited[point.dx.toInt()][point.dy.toInt()] = true;
        }
        await FlameAudio.play('sound/connect.mp3', volume: 0.8);
      }
    }

    // Sıfırla
    startPoint = null;
    currentPath.clear();
    setState(() {});
  }

  /// Belirli bir renk grubunun yolunu temizler
  void _resetPathForColor(Color color) {
    if (!completedPaths.containsKey(color)) return;

    // Bu renk için tamamlanan yol
    final path = completedPaths[color]!;
    for (var point in path) {
      visited[point.dx.toInt()][point.dy.toInt()] =
          false; // İşaretlemeyi kaldır
    }

    completedPaths.remove(color); // Tamamlanan yolu sil
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double gridSizePx = MediaQuery.of(context).size.width / gridSize;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Color.fromARGB(255, 19, 19, 19),
        body: Stack(
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
                    ),
                  ),
                ),
              ],
            ),
            if (_isGameCompleted()) // Oyun tamamlandıysa düğmeyi göster
              Align(
                alignment: Alignment.bottomCenter,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _initializeGameFromJson();
                      completedPaths.clear(); // Tüm tamamlanan yolları sıfırla
                    });
                  },
                  child: const Text("Yeni Oyun"),
                ),
              ),
          ],
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

  GridPainter({
    required this.gridSize,
    required this.gridColors,
    required this.completedPaths,
    required this.currentPath,
    required this.gridSizePx,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Grid arka planını doldur
    final backgroundPaint = Paint()
      ..color = const Color.fromARGB(255, 45, 45, 45) // Hafif gri
      ..style = PaintingStyle.fill;
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);

    // Gölge efekti ekle
    final shadowPaint = Paint()
      ..color = const Color.fromARGB(100, 0, 0, 0) // Yarı saydam siyah
      ..maskFilter =
          const MaskFilter.blur(BlurStyle.normal, 10); // Blur gölgesi
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height + 10), // Hafif alttan taşır
      shadowPaint,
    );

    // Grid çizimi
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

    // Noktaları çiz
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (gridColors[i][j] != null) {
          final dotPaint = Paint()
            ..color = gridColors[i][j]!
            ..style = PaintingStyle.fill;
          canvas.drawCircle(
            Offset(j * gridSizePx + gridSizePx / 2,
                i * gridSizePx + gridSizePx / 2),
            gridSizePx / 3,
            dotPaint,
          );
        }
      }
    }

    // Tamamlanan yolları çiz (yumuşak dönüşler)
    completedPaths.forEach((color, path) {
      final pathPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8;

      _drawSmoothPath(canvas, path, pathPaint);
    });

    // Aktif yolu çiz (yumuşak dönüşler)
    if (currentPath.isNotEmpty) {
      final activePathPaint = Paint()
        ..color = gridColors[currentPath.first.dx.toInt()]
            [currentPath.first.dy.toInt()]!
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8;

      _drawSmoothPath(canvas, currentPath, activePathPaint);
    }
  }

  /// Yumuşak yolları çizmek için quadratic Bezier kullan
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

      // Calculate the mid-point for smooth transitions
      final midX = (current.dy + next.dy) / 2;
      final midY = (current.dx + next.dx) / 2;

      pathToDraw.quadraticBezierTo(
        current.dy * gridSizePx + gridSizePx / 2,
        current.dx * gridSizePx + gridSizePx / 2,
        midX * gridSizePx + gridSizePx / 2,
        midY * gridSizePx + gridSizePx / 2,
      );
    }

    // Son noktayı çiz
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
