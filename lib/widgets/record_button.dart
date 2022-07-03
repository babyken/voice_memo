import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:typed_data';
import 'dart:io';

import 'package:flutter_sound/flutter_sound.dart';
import 'package:audio_session/audio_session.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

// Temp for using such storage class, long term use provider
import '../models/audio_record_storage.dart';
import '../controller/setting.dart';
import '../controller/providers.dart';

import 'package:testdrive/controller/providers.dart';
import 'package:testdrive/models/audio_record.dart';
import 'package:testdrive/controller/audio_record.dart';

import 'package:testdrive/widgets/alert_dialog.dart';

import 'dart:math';

import 'package:testdrive/widgets/blob.dart';

import 'package:path/path.dart' as p;

class RecordButton extends ConsumerStatefulWidget {
  const RecordButton({Key? key, required this.storage}) : super(key: key);

  final AudioRecordStorage storage;

  @override
  ConsumerState<RecordButton> createState() => _RecordButtonState();
}

class _RecordButtonState extends ConsumerState<RecordButton>
    with TickerProviderStateMixin {
  // ------ Animation ------- //
  static const _kToggleDuration = Duration(milliseconds: 300);
  static const _kRotationDuration = Duration(seconds: 5);

  AnimationController? _rotationController;
  AnimationController? _scaleController;
  double _rotation = 0;
  double _scale = 0.85;

  // ----- Sound Recorder
  final FlutterSoundRecorder _mRecorder = FlutterSoundRecorder();
  Codec _codec = Codec.aacMP4;
  String _mPath = 'temp_file_name.mp4';
  bool _mRecorderIsInited = false;
  StreamSubscription? _recorderSubscription;
  double _mSubscriptionDuration = 0;
  int pos = 0;
  double dbLevel = 0;

  AudioSettingController? settingController;

  int get _bitrateValue {
    if (settingController != null) {
      return settingController!.bitrate().round();
    }
    return 0;
  }

  int get _samplerateValue {
    if (settingController != null) {
      return settingController!.samplerate().round();
    }
    return 0;
  }

  void _updateRotation() => _rotation = _rotationController!.value * 2 * pi;
  void _updateScale() => _scale = (_scaleController!.value * 0.2) + 0.85;

  @override
  void initState() {
    settingController = ref.read(audioSettingProvider.notifier);

    _rotationController =
        AnimationController(vsync: this, duration: _kRotationDuration)
          ..addListener(() => setState(_updateRotation))
          ..repeat();

    _scaleController =
        AnimationController(vsync: this, duration: _kToggleDuration)
          ..addListener(() => setState(_updateScale));

    init().then((value) {
      setState(() {
        _mRecorderIsInited = true;
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    if (_mRecorder.isRecording) {
      stopRecorder();
    }

    // Be careful : you must `close` the audio session when you have finished with it.
    _mRecorder.closeRecorder();
    cancelRecorderSubscriptions();

    _scaleController!.dispose();
    _rotationController!.dispose();
    super.dispose();
  }

// --------------- Record setup ---------------- //

  void cancelRecorderSubscriptions() {
    if (_recorderSubscription != null) {
      _recorderSubscription!.cancel();
      _recorderSubscription = null;
    }
  }

  Future<void> openTheRecorder() async {
    if (!kIsWeb) {
      try {
        var status = await Permission.microphone.request();
        if (status != PermissionStatus.granted) {
          throw RecordingPermissionException(
              'Microphone permission not granted');
        }
      } on RecordingPermissionException catch (_) {
        print('recording permission exception');
      }
    }
    await _mRecorder.openRecorder();
    if (!await _mRecorder.isEncoderSupported(_codec) && kIsWeb) {
      _codec = Codec.opusWebM;

      if (!await _mRecorder.isEncoderSupported(_codec) && kIsWeb) {
        _mRecorderIsInited = true;
        return;
      }
    }

    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
      avAudioSessionCategoryOptions:
          AVAudioSessionCategoryOptions.allowBluetooth |
              AVAudioSessionCategoryOptions.defaultToSpeaker,
      avAudioSessionMode: AVAudioSessionMode.spokenAudio,
      avAudioSessionRouteSharingPolicy:
          AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: const AndroidAudioAttributes(
        contentType: AndroidAudioContentType.speech,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.voiceCommunication,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));

    _mRecorderIsInited = true;
  }

  Future<void> init() async {
    await openTheRecorder();

    print('Supported Codec in ${Platform.operatingSystem}');
    for (var value in Codec.values) {
      if (await _mRecorder.isEncoderSupported(value)) print('$value');
    }

    _recorderSubscription = _mRecorder.onProgress!.listen((e) {
      setState(() {
        pos = e.duration.inMilliseconds;
        if (e.decibels != null) {
          dbLevel = e.decibels as double;
        }
      });
    });
  }

  // ------------ File helper -------------- //
  Future<String> _findPath(String imageUrl) async {
    String tmpPath;
    if (Platform.isIOS) {
      final Directory directory = await getApplicationDocumentsDirectory();
      tmpPath = "${directory.parent.path}/tmp/$imageUrl";
    } else {
      Directory tempDir = await getTemporaryDirectory();
      tmpPath = '${tempDir.path}/$imageUrl';
    }

    return tmpPath;
  }

  Future<Uint8List> getAssetData(String path) async {
    // var asset = await rootBundle.load(path);
    String filePath = await _findPath(path);
    var asset = File(filePath);
    return asset.readAsBytes(); // .buffer.asUint8List();
  }

// ------------ Record Action -------------------- //

  Future<void> setSubscriptionDuration(
      double d) async // v is between 0.0 and 2000 (milliseconds)
  {
    _mSubscriptionDuration = d;
    setState(() {});
    await _mRecorder.setSubscriptionDuration(
      Duration(milliseconds: d.floor()),
    );
  }

  // Recorder
  Future<void> record() async {
    final now = DateTime.now();
    const prefix = 'mysound';
    if (kIsWeb) {
      _mPath = '$prefix-$now.webm';
    } else {
      _mPath = '$prefix-$now.mp4';
    }

    _mPath = _mPath.replaceAll(' ', '_');

    await _mRecorder.startRecorder(
        codec: _codec,
        toFile: _mPath,
        bitRate: _bitrateValue,
        sampleRate: _samplerateValue);
    setSubscriptionDuration(100);
    setState(() {});
  }

  Future<void> stopRecorder() async {
    await _mRecorder.stopRecorder();
    setSubscriptionDuration(0);
    Uint8List data = await getAssetData(_mPath);
    final File file = await widget.storage.save(data, _mPath);

    AudioRecordController ctler = ref.read(audioRecordProvider.notifier);
    await ctler.addRecord(AudioRecord(file.path));

    setState(() {});
  }

  Future<void> Function()? getPlaybackFn() {
    print('is recorder init: $_mRecorderIsInited');

    return _mRecorder.isStopped ? record : stopRecorder;
  }

  // -------------- Widget/UI -------------- //

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _mRecorder.isRecording
          ? Color.fromARGB(236, 213, 213, 213)
          : const Color(0xffff8906),
      child: InkWell(
          onTap: () async {
            try {
              var myFn = getPlaybackFn();
              await myFn!();
            } catch (err) {
              showAlertDialog(context, err);
            }
          },
          child: SizedBox(
            height: 2 * kToolbarHeight,
            width: double.infinity,
            child: Stack(alignment: Alignment.center, children: [
              if (_mRecorder.isRecording) ...[
                Blob(
                    color: Color(0xff0092ff),
                    scale: _scale,
                    rotation: _rotation),
                Blob(
                    color: Color(0xff4ac7b7),
                    scale: _scale,
                    rotation: _rotation * 2 - 30),
                Blob(
                    color: Color(0xffa4a6f6),
                    scale: _scale,
                    rotation: _rotation * 3 - 45)
              ],
              Transform.scale(
                scale: _scale * .8,
                child: Container(
                    constraints: const BoxConstraints.expand(),
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: Colors.white),
                    child: AnimatedSwitcher(
                      duration: _kToggleDuration,
                      child: _mRecorder.isRecording
                          ? Center(
                              child: Text('${(pos / 1000).toStringAsFixed(1)}s',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 35,
                                  )),
                            )
                          : const Icon(
                              Icons.mic,
                              size: 60,
                            ),
                    )),
              ),
            ]),
          )),
    );
  }
}
