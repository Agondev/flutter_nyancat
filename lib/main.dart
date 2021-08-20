import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';

import 'home/home.dart';

void main() => runApp(MyApp());

/// Here we load the audio and the assets necessary before loading the actual app
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<List<ui.Image>> _nyanCatFramesFuture;
  final player = AudioPlayer();

  @override
  void initState() {
    _nyanCatFramesFuture = loadNyanFrames();
    loadAudio();
    super.initState();
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  /// Load Nyan Cat's sound effect / voice / music
  /// Doesn't work on windows and linux but doesn't throw so safe to keep
  Future<void> loadAudio() async {
    // await player.setAsset('assets/nyancat.mp3');
    await player
        .setUrl('https://cristurm.github.io/nyan-cat/audio/nyan-cat.ogg');
    player.setVolume(0);
  }

  /// Load the assets (individual image frames) that make up Nyan Cat's movements
  Future<List<ui.Image>> loadNyanFrames() async {
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
        title: 'Flutter Nyan Cat',
        theme: ThemeData.dark(),
        home: FutureBuilder(
          future: _nyanCatFramesFuture,
          builder: (_, snapshot) => (snapshot.hasData)
              ? MyHomePage(
                  frames: snapshot.data,
                  audioPlayer: player,
                )
              : CircularProgressIndicator.adaptive(),
        ),
      );
}
