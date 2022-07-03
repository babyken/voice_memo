import 'dart:async';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';

import 'package:testdrive/models/audio_record.dart';
import 'package:logger/logger.dart';

import 'dart:io';

class AudioPlayer {
  FlutterSoundPlayer? _mPlayer;
  bool _mPlayerIsInited = false;
  double _mSubscriptionDuration = 0;
  StreamSubscription? _mPlayerSubscription;
  final _codec = Codec.aacMP4;
  int playerPos = 0;
  AudioRecord? currentRec;

  bool get isPlaying {
    if (!_mPlayerIsInited) return false;
    return _mPlayer!.isPlaying;
  }

  void dispose() {
    _stop();
    cancelPlayerSubscriptions();
    // Be careful : you must `close` the audio session when you have finished with it.
    _mPlayer!.closePlayer();
    _mPlayerIsInited = false;
    print('player dispose');
  }

  void cancelPlayerSubscriptions() {
    if (_mPlayerSubscription != null) {
      _mPlayerSubscription!.cancel();
      _mPlayerSubscription = null;
    }
  }

  Future<void> init() async {
    if (_mPlayerIsInited) return;
    _mPlayer = FlutterSoundPlayer(logLevel: Level.debug);
    await _mPlayer!.openPlayer();

    _mPlayerSubscription = _mPlayer!.onProgress!
        .listen((e) => playerPos = e.position.inMilliseconds);
    _mPlayerIsInited = true;
  }

  // -------  Here is the code to playback  -----------------------
  Future<void> _play(AudioRecord rec, VoidCallback whenFinished) async {
    if (!_mPlayerIsInited) return;
    currentRec = rec;

    print(currentRec!.path);
    try {
      var asset = File(currentRec!.path!);
      var byteData = await asset.readAsBytes();

      await _mPlayer!.startPlayer(
          fromDataBuffer: byteData, codec: _codec, whenFinished: whenFinished);
    } catch (e) {
      print(e);
    }
  }

  Future<void> _stop() async {
    if (!_mPlayerIsInited) return;
    await _mPlayer!.stopPlayer();
  }

  // Future<void> setPlayerSubscriptionDuration(
  //     double d) async // v is between 0.0 and 2000 (milliseconds)
  // {
  //   _mPlayerSubscriptionDuration = d;
  //   setState(() {});
  //   await _mPlayer.setSubscriptionDuration(
  //     Duration(milliseconds: d.floor()),
  //   );
  // }

  Future<void> togglePlaying(AudioRecord rec, VoidCallback whenFinished) async {
    if (!_mPlayerIsInited) return;
    if (currentRec != null) {
      // if playing different files, stop current one and then play the new one
      if (rec.path != currentRec!.path) {
        print('togglePlaying Play another audio case');
        // stop current one
        if (_mPlayer!.isPlaying) {
          await _stop();
        }
        await _play(rec, whenFinished);
        return;
      }
    }
    // General case
    print('togglePlaying General case');
    await (_mPlayer!.isStopped ? _play(rec, whenFinished) : _stop());
  }
}
