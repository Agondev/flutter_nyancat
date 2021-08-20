import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:just_audio/just_audio.dart';

import '../painters/cat_painter.dart';
import '../painters/rainbow_painter.dart';

/// The Nyan Cat object + its tail + volume control depending on its location on the screen
class NyanCat extends StatefulWidget {
  final List<ui.Image> frames;
  final double angle;
  final int tailCount, speed;
  final AudioPlayer audioPlayer;

  NyanCat({
    this.frames,
    this.angle,
    this.tailCount,
    this.speed = 5000,
    this.audioPlayer,
  }) : assert(
          speed < 99999,
        );

  @override
  _NyanCatState createState() => _NyanCatState();
}

class _NyanCatState extends State<NyanCat> with TickerProviderStateMixin {
  AnimationController _animOffsetController, _animNyanController;
  IntTween _nyanTween = IntTween(begin: 0, end: 6);
  Duration duration;

  @override
  void dispose() {
    widget.audioPlayer.stop();
    _animNyanController.dispose();
    _animOffsetController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    widget.audioPlayer.setVolume(0);
    _animNyanController = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 700,
      ),
    )..repeat();

    _animOffsetController = AnimationController(
      vsync: this,
      upperBound: 4, // should be proportional to the size of the tail
      duration: Duration(
        milliseconds: widget.speed,
      ),
    )
      ..forward()
      ..addListener(
        () => setState(() {
          if (_animOffsetController.value > .0 &&
              _animOffsetController.value <= .5)
            widget.audioPlayer.setVolume(
              _animOffsetController.value + _animOffsetController.value,
            );
          else if (_animOffsetController.value > .5 &&
              _animOffsetController.value <= 1.5)
            widget.audioPlayer.setVolume(
              1.5 - _animOffsetController.value,
            );
        }),
      );

    widget.audioPlayer.seek(Duration(seconds: Random().nextInt(55) + 5));
    widget.audioPlayer.play();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: RainbowPainter(
        relativeOffset: _animOffsetController.value,
        tailCount: widget.tailCount,
        // tailCount: Random().nextInt(9) * 2 + 4,
        frame: _nyanTween.animate(_animNyanController).value,
        angleInRadians: widget.angle,
      ),
      foregroundPainter: CatPainter(
        image: widget.frames[_nyanTween
            .animate(
              _animNyanController,
            )
            .value],
        angleInRadians: widget.angle,
        relativeOff: _animOffsetController.value,
      ),
      child: Container(),
    );
  }
}
