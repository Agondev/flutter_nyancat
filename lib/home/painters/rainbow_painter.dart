import 'dart:math';

import 'package:flutter/material.dart';

import 'common.dart';

/// Paints the cat's rainbow tail
class RainbowPainter extends CustomPainter {
  static const xLength = 20.0;
  static const yLength = 5.0;
  double relativeOffset, angleInRadians, sizeMultiplier = 5;
  int frame, tailCount;
  Paint paintBrush;

  RainbowPainter({
    this.relativeOffset,
    this.paintBrush,
    this.frame,
    this.tailCount = 12,
    this.angleInRadians = 0,
  }) : assert(tailCount % 2 == 0,
            'Should be an even number, or tail swing animation goes from start') {
    paintBrush ??= Paint()
      ..strokeWidth = 10
      ..isAntiAlias = true
      ..color = Color.fromRGBO(
        Random().nextInt(255),
        Random().nextInt(255),
        Random().nextInt(255),
        1,
      );
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.rotate(angleInRadians);
    var generalOffset = Offset(
      size.width * relativeOffset + kFadeInOffset,
      size.height / 2, // + (frame < 3 ? 4 : 0),
    );
    for (var i = tailCount; i > 0; i--) {
      if (i % 2 == 0) {
        generalOffset =
            generalOffset.translate(0, frame < 3 ? -yLength : yLength);
        canvas
          ..drawLine(
            generalOffset.translate(-i * xLength, -5 * sizeMultiplier),
            generalOffset.translate(xLength - i * xLength, -5 * sizeMultiplier),
            paintBrush..color = Colors.red.withOpacity(1 - i / tailCount),
          )
          ..drawLine(
            generalOffset.translate(-i * xLength, -3 * sizeMultiplier),
            generalOffset.translate(xLength - i * xLength, -3 * sizeMultiplier),
            paintBrush..color = Colors.orange.withOpacity(1 - i / tailCount),
          )
          ..drawLine(
            generalOffset.translate(-i * xLength, -1 * sizeMultiplier),
            generalOffset.translate(xLength - i * xLength, -1 * sizeMultiplier),
            paintBrush..color = Colors.yellow.withOpacity(1 - i / tailCount),
          )
          ..drawLine(
            generalOffset.translate(-i * xLength, sizeMultiplier),
            generalOffset.translate(xLength - i * xLength, sizeMultiplier),
            paintBrush..color = Colors.green.withOpacity(1 - i / tailCount),
          )
          ..drawLine(
            generalOffset.translate(-i * xLength, 3 * sizeMultiplier),
            generalOffset.translate(xLength - i * xLength, 3 * sizeMultiplier),
            paintBrush..color = Colors.blue.withOpacity(1 - i / tailCount),
          )
          ..drawLine(
            generalOffset.translate(-i * xLength, 5 * sizeMultiplier),
            generalOffset.translate(xLength - i * xLength, 5 * sizeMultiplier),
            paintBrush..color = Colors.purple.withOpacity(1 - i / tailCount),
          );
      } else {
        generalOffset =
            generalOffset.translate(0, frame < 3 ? yLength : -yLength);
        canvas
          ..drawLine(
            generalOffset.translate(-i * xLength, -5 * sizeMultiplier),
            generalOffset.translate(xLength - i * xLength, -5 * sizeMultiplier),
            paintBrush..color = Colors.red.withOpacity(1 - i / tailCount),
          )
          ..drawLine(
            generalOffset.translate(-i * xLength, -3 * sizeMultiplier),
            generalOffset.translate(xLength - i * xLength, -3 * sizeMultiplier),
            paintBrush..color = Colors.orange.withOpacity(1 - i / tailCount),
          )
          ..drawLine(
            generalOffset.translate(-i * xLength, -1 * sizeMultiplier),
            generalOffset.translate(xLength - i * xLength, -1 * sizeMultiplier),
            paintBrush..color = Colors.yellow.withOpacity(1 - i / tailCount),
          )
          ..drawLine(
            generalOffset.translate(-i * xLength, sizeMultiplier),
            generalOffset.translate(xLength - i * xLength, sizeMultiplier),
            paintBrush..color = Colors.green.withOpacity(1 - i / tailCount),
          )
          ..drawLine(
            generalOffset.translate(-i * xLength, 3 * sizeMultiplier),
            generalOffset.translate(xLength - i * xLength, 3 * sizeMultiplier),
            paintBrush..color = Colors.blue.withOpacity(1 - i / tailCount),
          )
          ..drawLine(
            generalOffset.translate(-i * xLength, 5 * sizeMultiplier),
            generalOffset.translate(xLength - i * xLength, 5 * sizeMultiplier),
            paintBrush..color = Colors.purple.withOpacity(1 - i / tailCount),
          );
      }
    }
    // canvas = Canvas(ui.PictureRecorder());
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
