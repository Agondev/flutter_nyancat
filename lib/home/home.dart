import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:just_audio/just_audio.dart';

import 'objects/nyancat.dart';
import 'objects/star.dart';

/// List of background colors
const kSpaceColors = [
  Color.fromRGBO(10, 52, 97, 1),
  Color(0xff1c253c),
  Color(0xff1f3e5a),
  Color(0xff000007),
  Color(0xff00023f),
  Color(0xff000754),
  // Color(0xff145051),
  // Color(0xff281c3c),
  // Color(0xff3c1c31),
  // Color(0xff340054),
  // Color(0xff48006c),
];

/// This is where we set all the variables that determine the speed, amount of
/// stars, length of nyan's tail, where nyan appears from, etc.
class MyHomePage extends StatefulWidget {
  MyHomePage({
    Key key,
    this.frames,
    this.audioPlayer,
  }) : super(key: key);

  /// The assets that constitute Nyan Cat itself
  final List<ui.Image> frames;

  /// The audio player controller
  final AudioPlayer audioPlayer;

  /// Arbitrary number that determines the amount of stars generated
  final int luckySeed = Random().nextInt(76) + 25;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  /// Increases when we tap the FAB
  int _counter = 0;

  /// Rotation of the entire viewport for immersion variety
  int _rotation;

  /// Whether the stars flow in the same direction as nyan cat or opposite
  bool _direction;

  /// Angle of the stars/sparks
  double _angle;

  /// Scale of the viewport for 3D illusion
  double _scale;

  /// Color of the FAB
  Color _fabColor = Colors.teal;

  /// Color of the background color of the viewport
  Color _bgColor = Color.fromRGBO(10, 52, 97, 1);

  /// Nyancat's speed
  int _nyanSpeed = Random().nextInt(15000) + 5000;

  /// The offsets of the individual stars
  List<Offset> _translationOffset;

  /// The amount of Stars
  var _starList = <Star>[];

  /// Nyan Cat itself
  var _cat = <Widget>[];

  /// Initializes the stars in the viewport
  void setStars() {
    _starList.clear();
    _starList = <Star>[];
    _starList.addAll(List.generate(
      widget.luckySeed,
      (index) => Star(
        duration: Duration(seconds: Random().nextInt(3) + 1),
        offset: _translationOffset[index],
        angle: _angle,
        // for some reason looks better with 2 as const...
        sparkSize: 2,
        // sparkSize: Random().nextInt(2).toDouble() + 1,
        margin: Random().nextDouble() * 10 + 4,
        oppositeOfNyan: _direction,
      ),
    ));
  }

  /// Initializes Nyan Cat including the rainbow
  void setNyanAndTail() => _cat.add(
        NyanCat(
          frames: widget.frames,
          angle: _angle,
          tailCount: Random().nextInt(10) * 2 + 4,
          speed: _nyanSpeed,
          audioPlayer: widget.audioPlayer,
        ),
      );

  /// Callback to reinitialize the viewport + adds new Nyan Cat
  void _incrementCounter() => setState(() {
        _counter++;

        // Set FAB to random color
        _fabColor = Color.fromRGBO(
          Random().nextInt(255),
          Random().nextInt(255),
          Random().nextInt(255),
          1,
        );

        // Reapply camera viewport
        setUpViewPortInstance();

        // Arbitrary limit to the amount of cats stores to avoid memory leaks and performance impact
        if (_cat.length > 20) _cat.removeRange(0, 10);

        // add a new Nyan Cat to the viewport
        setNyanAndTail();
      });

  /// Randomly set the angle of the stars
  void setAngle() => _angle = (DateTime.now().second % 2 == 0 ? -1 : 1) *
      (Random().nextInt(7) + 1) *
      pi /
      (Random().nextInt(270) + 10);

  /// Randomly set the scale of the viewport
  void setScale() => _scale = 1 + Random().nextDouble() + Random().nextDouble();

  /// Randomly set the direction of the stars in line or opposite of Nyan Cat
  void setDirection() => _direction = Random().nextBool();

  /// Randomly set the initial offset of each star to mimic dynamic location in space
  void setOffsets() => _translationOffset = List.generate(
        widget.luckySeed,
        (idx) => Offset(Random().nextDouble(), Random().nextDouble()),
      );

  /// Randomly set the rotation of the entire viewport for variety
  void setRotation() => _rotation = Random().nextInt(2);

  /// Initialize new stars, offsets, etc. (entire new viewport)
  void setUpViewPortInstance() {
    setRotation();
    setScale();
    setAngle();
    setDirection();
    setOffsets();
    setStars();
  }

  @override
  void initState() {
    super.initState();

    setUpViewPortInstance();
  }

  @override
  Widget build(BuildContext context) {
    // Smooth transition between different random background colors
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: _nyanSpeed ~/ 3),
      tween: ColorTween(
        begin: _bgColor,
        end: kSpaceColors[Random().nextInt(kSpaceColors.length)],
      ),
      builder: (_, color, child) => Scaffold(
        backgroundColor: color,
        body: child,
        floatingActionButton: FloatingActionButton(
          backgroundColor: _fabColor,
          foregroundColor: Colors.white,
          onPressed: _incrementCounter,
          tooltip: 'Increment',
          child: Icon(Icons.add),
        ),
      ),
      child: Stack(
        children: [
          RotatedBox(
            quarterTurns: _rotation,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(_direction ? pi : 0)..scale(_scale),
              child: Stack(
                children: [
                  ..._starList,
                  ..._cat,
                ],
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'You have pushed the button this many times:',
                ),
                Text(
                  '$_counter',
                  style: Theme.of(context).textTheme.headline4,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
