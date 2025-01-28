class LevelData {
  final int level;
  final int gridSize;
  final List<Point> points;
  static final List<String> categoryNames = const [
    "4x4 Katmanı",
    "5x5 Katmanı",
    "6x6 Katmanı"
  ];

  LevelData(
      {required this.level, required this.gridSize, required this.points});

  factory LevelData.fromJson(Map<String, dynamic> json) {
    return LevelData(
      level: json['level'],
      gridSize: json['gridSize'],
      points: List<Point>.from(
        json['points'].map((point) => Point.fromJson(point)),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'level': level,
        'gridSize': gridSize,
        'points': points.map((point) => point.toJson()).toList(),
      };
}

class Point {
  final int x;
  final int y;
  final String color;

  Point({required this.x, required this.y, required this.color});

  factory Point.fromJson(Map<String, dynamic> json) {
    return Point(x: json['x'], y: json['y'], color: json['color']);
  }

  Map<String, dynamic> toJson() => {'x': x, 'y': y, 'color': color};
}
