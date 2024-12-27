import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class SquareComponent extends PositionComponent with TapCallbacks {
  final Color initialColor;
  final double squareSize;
  final bool isCorrect;
  final int index;
  late Color currentColor;
  final VoidCallback? onIncorrectTap; // Hata callback'i
  final VoidCallback? onCorrectTap;

  SquareComponent(
    this.initialColor,
    Vector2 position,
    this.squareSize,
    this.isCorrect,
    this.index, {
    this.onIncorrectTap,
    this.onCorrectTap,
  }) : super(
          position: position,
          size: Vector2(squareSize, squareSize),
        ) {
    currentColor = initialColor;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Yuvarlatılmış köşe yarıçapı
    const double cornerRadius = 8.0;

    // RRect tanımlama
    final rect = size.toRect();
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(cornerRadius));

    // Kare boyama
    final paint = Paint()..color = currentColor;
    canvas.drawRRect(rrect, paint);

    // Kenar boyama
    final borderPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(rrect, borderPaint);
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    if (!isCorrect) {
      onIncorrectTap?.call();
    } else {
      onCorrectTap?.call();
    }
    changeColor(isCorrect ? Colors.green : Colors.blueGrey[800]!);
  }

  void changeColor(Color newColor) {
    currentColor = newColor;
  }
}
