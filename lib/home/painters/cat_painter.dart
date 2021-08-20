import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'common.dart';

/// Pains the cat without the tail
class CatPainter extends CustomPainter {
  ui.Image image;

  double relativeOff, angleInRadians;

  CatPainter({
    this.relativeOff,
    this.image,
    this.angleInRadians,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.rotate(angleInRadians);
    canvas.translate(30, 0);
    paintImage(
      canvas: canvas,
      isAntiAlias: true,
      rect: Rect.fromPoints(
        Offset(
          size.width * relativeOff - 100 + kFadeInOffset,
          size.height / 2 - 35,
        ),
        Offset(
          size.width * relativeOff + 100 + kFadeInOffset,
          size.height / 2 + 35,
        ),
      ),
      image: image,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
