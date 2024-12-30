import 'dart:async';
import 'package:bilsemup_minigame/states/box_game_provider.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:flame_audio/flame_audio.dart';

class SquareComponent extends PositionComponent with TapCallbacks {
  final Color initialColor;
  final double squareSize;
  final bool isCorrect;
  final int index;
  late Color currentColor;
  late List<Color> correctColors;
  late List<int> correctSquaresIndex;
  final VoidCallback? onIncorrectTap;
  final VoidCallback? onCorrectTap;

  var boxprovider =
      Provider.of<MemoryGameProvider>(Get.context!, listen: false);

  SquareComponent(
    this.initialColor,
    Vector2 position,
    this.squareSize,
    this.isCorrect,
    this.index, {
    this.onIncorrectTap,
    this.onCorrectTap,
    required this.correctColors,
    required this.correctSquaresIndex,
  }) : super(
          position: position,
          size: Vector2(squareSize, squareSize),
        ) {
    currentColor = initialColor;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    double cornerRadius = MediaQuery.of(Get.context!).size.width * 0.025;
    final rect = size.toRect();
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(cornerRadius));

    final paint = Paint()..color = currentColor;
    canvas.drawRRect(rrect, paint);

    final borderPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(rrect, borderPaint);
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    if (boxprovider.hasStartGame! &&
        boxprovider.endOption == 0 &&
        currentColor == Colors.grey[800]!) {
      FlameAudio.play('sound/click_sound.wav', volume: 0.5);
      if (!isCorrect) {
        print("IM INCORRECT");
        onIncorrectTap?.call();
        changeColor(Colors.blueGrey);
      } else {
        print("IM CORRECT");
        onCorrectTap?.call();
        changeColor(correctColors[
            correctSquaresIndex.indexOf(index) % correctColors.length]);
      }

      animateSizeChange();
    }
  }

  void showCorrectColor() {
    currentColor = correctColors[
        correctSquaresIndex.indexOf(index) % correctColors.length];
  }

  void changeColor(Color newColor) {
    currentColor = newColor;
  }

  Future<void> animateSizeChange() async {
    final targetSize = size.clone()..multiply(Vector2(1.0, 1.0));
    final originalSize = size.clone();
    final originalPosition = position.clone();
    final targetPosition = position.clone()..add(Vector2(0, -10));

    final duration = 0.2;

    add(
      SizeEffect.to(
        targetSize,
        EffectController(duration: duration, reverseDuration: duration),
        onComplete: () {
          size = originalSize;
        },
      ),
    );

    add(
      MoveEffect.to(
        targetPosition,
        EffectController(duration: duration, reverseDuration: duration),
        onComplete: () {
          position = originalPosition;
        },
      ),
    );
  }
}
