import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';

const _xFadeInOffset = -75.0;
const _spaceColors = [
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

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<List<ui.Image>> _nyanCatFramesFuture;
  final player = AudioPlayer();

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _nyanCatFramesFuture = loadNyanFrames();
    super.initState();
  }

  Future<List<ui.Image>> loadNyanFrames() async {
    await player
        .setUrl('https://cristurm.github.io/nyan-cat/audio/nyan-cat.ogg');
    player.setVolume(0);
    // await player.setAsset('assets/nyancat.mp3');
    var images = <ui.Image>[];
    for (var i = 0; i < 7; i++) {
      images.add((await (await ui.instantiateImageCodec(
        (await rootBundle.load('assets/' + i.toString() + '.gif'))
            .buffer
            .asUint8List(),
      ))
              .getNextFrame())
          .image);
    }
    return Future<List<ui.Image>>.value(images);
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: kDebugMode,
        title: 'Flutter Demo',
        theme: ThemeData.dark(),
        home: FutureBuilder(
          future: _nyanCatFramesFuture,
          builder: (_, snapshot) => (snapshot.hasData)
              ? MyHomePage(
                  title: 'Flutter Demo Home Page',
                  frames: snapshot.data,
                  audioPlayer: player,
                )
              : Container(),
        ),
      );
}

class MyHomePage extends StatefulWidget {
  MyHomePage({
    Key key,
    this.title,
    this.frames,
    this.audioPlayer,
  }) : super(key: key);

  final String title;

  final List<ui.Image> frames;

  final AudioPlayer audioPlayer;

  final int luckySeed = Random().nextInt(76) + 25;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  int _counter = 0, _rotation;
  bool _direction;
  double _angle, _scale;
  Color _fabColor = Colors.teal;
  Color _bgColor = Color.fromRGBO(10, 52, 97, 1);
  int _nyanSpeed = Random().nextInt(15000) + 5000;

  List<Offset> _translationOffset;
  var _starList = <Star>[];
  var _cat = <Widget>[];

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
        // sparkSize: Random().nextInt(2).toDouble() + 1,
        sparkSize: 2,
        margin: Random().nextDouble() * 10 + 4,
        oppositeOfNyan: _direction,
      ),
    ));
  }

  void setNyanAndTail() => _cat.add(
        Nyan(
          frames: widget.frames,
          angle: _angle,
          tailCount: Random().nextInt(10) * 2 + 4,
          speed: _nyanSpeed,
          audioPlayer: widget.audioPlayer,
        ),
      );

  void _incrementCounter() => setState(() {
        _counter++;
        _fabColor = Color.fromRGBO(
          Random().nextInt(255),
          Random().nextInt(255),
          Random().nextInt(255),
          1,
        );
        // _bgColor = _spaceColors[Random().nextInt(_spaceColors.length)];
        setUp();
        setStars();
        if (_cat.length > 20) _cat.removeRange(0, 10);
        setNyanAndTail();
      });

  void setAngle() => _angle = (DateTime.now().second % 2 == 0 ? -1 : 1) *
      (Random().nextInt(7) + 1) *
      pi /
      (Random().nextInt(270) + 10);

  void setScale() => _scale = 1 + Random().nextDouble() + Random().nextDouble();

  void setDir() => _direction = Random().nextBool();

  void setOffsets() => _translationOffset = List.generate(
        widget.luckySeed,
        (idx) => Offset(Random().nextDouble(), Random().nextDouble()),
      );

  void setRotation() => _rotation = Random().nextInt(2);

  void setUp() {
    setRotation();
    setScale();
    setAngle();
    setDir();
    setOffsets();
    setStars();
  }

  @override
  void initState() {
    super.initState();

    setUp();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: _nyanSpeed ~/ 3),
      tween: ColorTween(
        begin: _bgColor,
        end: _spaceColors[Random().nextInt(_spaceColors.length)],
      ),
      builder: (_, color, child) => Scaffold(
        backgroundColor: color,
        appBar: AppBar(
          title: Text(widget.title),
        ),
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

class Nyan extends StatefulWidget {
  final List<ui.Image> frames;
  final double angle;
  final int tailCount, speed;
  final AudioPlayer audioPlayer;

  Nyan({
    this.frames,
    this.angle,
    this.tailCount,
    this.speed = 5000,
    this.audioPlayer,
  }) : assert(
          speed < 99999,
        );

  @override
  _NyanState createState() => _NyanState();
}

class _NyanState extends State<Nyan> with TickerProviderStateMixin {
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
        relativeOff: _animOffsetController.value,
        tailCount: widget.tailCount,
        // tailCount: Random().nextInt(9) * 2 + 4,
        frame: _nyanTween.animate(_animNyanController).value,
        angleInRadians: widget.angle,
      ),
      foregroundPainter: NyanPainter(
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

class Star extends StatefulWidget {
  Star({
    @required this.duration,
    @required this.offset,
    @required this.angle,
    this.margin = 5,
    this.sparkSize = 2,
    this.oppositeOfNyan = false,
  });

  final Offset offset;
  final Duration duration;
  final double angle, margin, sparkSize;
  final bool oppositeOfNyan;

  @override
  _StarState createState() => _StarState();
}

class _StarState extends State<Star> with SingleTickerProviderStateMixin {
  AnimationController _anim;
  IntTween _nyanTween;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: widget.duration,
      value: Random().nextDouble(),
    )
      ..repeat()
      ..addListener(() {
        setState(() {});
      });
    _nyanTween = IntTween(
      begin: 0,
      end: 5,
    );
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      child: Container(),
      painter: SparkPainter(
        relativeOff: _anim.value,
        sparkSize: widget.sparkSize,
        margin: widget.margin,
        phase: _nyanTween
            .animate(
              _anim,
            )
            .value,
        opposite: widget.oppositeOfNyan,
        translateBy: widget.offset,
        angleInRadians: widget.angle,
      ),
    );
  }
}

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

class RainbowPainter extends CustomPainter {
  static const xLength = 20.0;
  static const yLength = 5.0;
  double relativeOff, angleInRadians, sizeMultiplier = 5;
  int frame, tailCount;
  Paint paintBrush;
  // Paint _paint = Paint()..strokeWidth = 10;

  RainbowPainter({
    this.relativeOff,
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
      size.width * relativeOff + _xFadeInOffset,
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

class NyanPainter extends CustomPainter {
  // List<ui.Image> frameList;
  ui.Image image;

  double relativeOff, angleInRadians;

  NyanPainter({
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
          size.width * relativeOff - 100 + _xFadeInOffset,
          size.height / 2 - 35,
        ),
        Offset(
          size.width * relativeOff + 100 + _xFadeInOffset,
          size.height / 2 + 35,
        ),
      ),
      image: image,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
