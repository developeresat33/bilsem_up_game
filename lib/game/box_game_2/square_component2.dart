import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:bilsemup_minigame/states/box_game_provider.dart';

class SquareComponent2 extends PositionComponent with TapCallbacks {
  final Color initialColor;
  final double squareSize;
  final bool isCorrect;
  final int index;
  late Color currentColor;
  late List<int> correctSquaresIndex;
  final VoidCallback? onIncorrectTap;
  final VoidCallback? onCorrectTap;
  var boxprovider =
      Provider.of<MemoryGameProvider>(Get.context!, listen: false);

  SquareComponent2(
    this.initialColor,
    Vector2 position,
    this.squareSize,
    this.isCorrect,
    this.index, {
    this.onIncorrectTap,
    this.onCorrectTap,
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

    const double cornerRadius = 20.0;

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
    if (boxprovider.hasStartGame! && boxprovider.endOption == 0) {
      FlameAudio.play('sound/click_sound.wav', volume: 0.5);
      if (!isCorrect) {
        onIncorrectTap?.call();
        changeColor(Colors.red);
      } else {
        onCorrectTap?.call();
        changeColor(Colors.green);

        checkCorrectOrder();
      }

      animateSizeChange();
    }
  }

  void changeColor(Color newColor) {
    currentColor = newColor;
  }

  Future<void> animateSizeChange() async {
    final targetSize = size.clone()..multiply(Vector2(1.1, 1.1));

    final originalSize = size.clone();

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
  }

  void checkCorrectOrder() {
    if (correctSquaresIndex.contains(index)) {
      correctSquaresIndex.remove(index);

      if (correctSquaresIndex.isEmpty) {
        FlameAudio.play('sound/success_game.mp3', volume: 0.8);
        Future.delayed(Duration(milliseconds: 900), () {
          onCorrectTap?.call(); // Oyunu tamamla
        });
      }
    } else {
      // Yanlış sıra
      onIncorrectTap?.call(); // Tekrar yanlış yapıldıysa ilgili işlemleri yap
    }
  }
}
