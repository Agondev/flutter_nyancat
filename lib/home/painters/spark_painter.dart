import 'dart:math';

import 'package:flutter/material.dart';

/// Paints the star/spark
class SparkPainter extends CustomPainter {
  Offset offset, translateBy;
  Paint paintBrush;
  int phase;
  bool opposite;
  double relativeOff, angleInRadians, sparkSize, margin;

  SparkPainter({
    this.relativeOff,
    this.angleInRadians,
    this.sparkSize = 5,
    this.margin = 10,
    this.opposite,
    this.translateBy,
    this.offset = const Offset(0, 0),
    this.paintBrush,
    this.phase = 10,
  }) {
    paintBrush = Paint()..color = Colors.grey;
    translateBy ??= Offset(Random().nextDouble(), Random().nextDouble());
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(
      opposite
          ? size.width / 1.2 * translateBy.dx
          : size.width / 3 * translateBy.dx,
      size.height * translateBy.dy,
    );
    canvas.rotate(angleInRadians);

    Rect rect = Rect.fromCircle(
      center: Offset(
        (opposite ? -1 : 1) * size.width / 2 * relativeOff,
        size.height / 4,
      ),
      radius: sparkSize,
    );

    switch (phase) {
      case 0: // 1 center dot
        canvas.drawRect(
          rect,
          paintBrush,
        );
        break;
      case 1: // 4 circular dots
        canvas
          ..drawRect(rect.translate(margin / 2, 0), paintBrush)
          ..drawRect(rect.translate(-margin / 2, 0), paintBrush)
          ..drawRect(rect.translate(0, margin / 2), paintBrush)
          ..drawRect(rect.translate(0, -margin / 2), paintBrush);
        break;
      case 2: // 4 lines + 1 center dot
        canvas
          ..drawRect(rect, paintBrush)
          ..drawRect(rect.translate(margin, 0), paintBrush)
          ..drawRect(rect.translate(-margin, 0), paintBrush)
          ..drawRect(rect.translate(0, margin), paintBrush)
          ..drawRect(rect.translate(0, -margin), paintBrush);
        break;
      case 3: // 8 circular dots
        canvas
          ..drawRect(rect.translate(margin * 2, 0), paintBrush)
          ..drawRect(rect.translate(-margin * 2, 0), paintBrush)
          ..drawRect(rect.translate(0, margin * 2), paintBrush)
          ..drawRect(rect.translate(0, -margin * 2), paintBrush)
          ..drawRect(rect.translate(margin, margin), paintBrush)
          ..drawRect(rect.translate(margin, -margin), paintBrush)
          ..drawRect(rect.translate(-margin, margin), paintBrush)
          ..drawRect(rect.translate(-margin, -margin), paintBrush);
        break;
      case 4: // 4 spaced out dots
        canvas
          ..drawRect(rect.translate(margin * 2, 0), paintBrush)
          ..drawRect(rect.translate(-margin * 2, 0), paintBrush)
          ..drawRect(rect.translate(0, margin * 2), paintBrush)
          ..drawRect(rect.translate(0, -margin * 2), paintBrush);
        break;
      default:
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
