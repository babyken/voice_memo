// import 'dart:ffi';

import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:just_waveform/just_waveform.dart';
import 'package:testdrive/models/audio_record.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:testdrive/models/waveform_loading_manager.dart';
import 'package:testdrive/controller/waveform_loading_controller.dart';
import 'package:testdrive/controller/providers.dart';

import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'dart:typed_data';

class WaveformVisual extends ConsumerStatefulWidget {
  const WaveformVisual(
      {Key? key,
      required this.record,
      required this.index,
      required this.callback})
      : super(key: key);

  final AudioRecord record;
  final int index;
  final Function callback;

  @override
  ConsumerState<WaveformVisual> createState() => _WaveformVisualState();
}

class _WaveformVisualState extends ConsumerState<WaveformVisual> {
  final progressStream = BehaviorSubject<WaveformProgress>();
  Waveform? _waveform;
  bool _isLoading = false;

  // Waveform? waveform;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _loadWaveform() async {
    final waveFilePath = p.join((await getTemporaryDirectory()).path,
        widget.record.nameWithNoExt + '.wav');

    // final ffwaveFilePath = p.join((await getTemporaryDirectory()).path,
    //     widget.record.nameWithNoExt + '_ffmpeg.wav');

    // If temp wavefile exists, remove it
    if (await File(waveFilePath).exists()) {
      final waveFile = File(waveFilePath);
      print('${waveFile.path}....... File exist, going to delete...');
      await waveFile.delete();
    }
    // final waveFile = File(waveFilePath);
    // print('-----------JustWaveform result ------------------');
    // final result = await JustWaveform.extract(
    //         audioInFile: widget.record.file, waveOutFile: waveFile)
    //     .last;

    // _waveform = result.waveform;
    // print(_waveform!.duration);
    // print(_waveform!.data);
    // setState(() {});
    // return;
    final ffmpegCmd = '-i ${widget.record.path} $waveFilePath';

    FFmpegKit.execute(ffmpegCmd).then((session) async {
      final returnCode = await session.getReturnCode();
      if (ReturnCode.isSuccess(returnCode)) {
        final ffmpegWaveFile = File(waveFilePath);

        final bytes =
            Uint8List.fromList(await File(waveFilePath).readAsBytes()).buffer;

        final header = Uint32List.view(bytes, 0, 20);
        // final header2 = Uint16List.view(bytes, 0, 40);
        ByteData bd = ByteData.sublistView(header);

        final channelNumber = bd.getUint16(22, Endian.little);
        print('Channel Number: $channelNumber');

        final flags = bd.getUint16(34, Endian.little);
        print('Flag: ${flags == 16 ? 0 : 1}');

        final sampleRate = header[6];
        print('SampleRate: $sampleRate');

        final dataSize = bd.getUint32(74, Endian.little);
        print('datasize: $dataSize bytes');

        final int samplesPerPixel = sampleRate ~/ 100;

        // for (var i = 0; i < header2.length; i++) {
        //   if (header2[i] > 0) {
        //     print(
        //         'header2[$i]: ${header2[i]} | ${header2[i].toRadixString(16)}');
        //   }
        // }

        final data = Int16List.view(bytes, 78);

        // Not sure why /2, just obtain from
        final int expectedSampleCount = data.length;
        // Multiply by 2 since 2 bytes are needed for each short, and multiply by 2 again because for each sample we store a pair of (min,max)
        // DEL this line?: multiple for 1 time because used int directly, instead of pointer
        final int scaledByteSamplesLength =
            2 * 2 * (expectedSampleCount ~/ samplesPerPixel);
        final int scaledSamplesLength = scaledByteSamplesLength ~/ 2;
        final int waveLength =
            (scaledByteSamplesLength ~/ 2); // better name: numPixels?

        int scaledSampleIdx = 0; // only positive number
        int sampleIdx = 0;
        int sample = 0;
        int minSample = 32767;
        int maxSample = -32768;

        List<int> wave = [];

        // // TODO: Support two channels

        for (int i = 0; i < data.length * channelNumber; i += channelNumber) {
          for (int j = 0; j < channelNumber; j++) {
            sample += data[i + j];
          }
          sample ~/= channelNumber;
          if (sample < -32768) sample = -32768;
          if (sample > 32767) sample = 32767;
          if (sample < minSample) minSample = sample;
          if (sample > maxSample) maxSample = sample;
          sampleIdx++;

          if (sampleIdx % samplesPerPixel == 0) {
            if (scaledSampleIdx + 1 < waveLength) {
              wave.add(minSample);
              wave.add(maxSample);
              scaledSampleIdx += 2;
              // reset for next pixel
              minSample = 32767;
              maxSample = -32768;
            }
          }

          // reset for each iteration per channel per byte
          sample = 0;
        }
        // waveHeader[4] = (UInt32)(scaledSampleIdx / 2);

        print(wave);
        _waveform = Waveform(
          version: 1,
          flags: flags == 16 ? 0 : 1,
          sampleRate: sampleRate,
          samplesPerPixel: samplesPerPixel, //flags * header[6],
          length: scaledSampleIdx ~/ 2,
          data: wave,
        );
        print(_waveform!.duration);
        print(_waveform!.data);

        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  // TODO: free resource here ?
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   if (state == AppLifecycleState.detached) {

  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final waveformManagerNotifer = ref.watch(waveformLoadingProvider.notifier);

    if (!_isLoading) {
      _loadWaveform();
      _isLoading = true;
    }

    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(widget.record.name),
          Container(
              height: 150.0,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: const BorderRadius.all(Radius.circular(20.0)),
              ),
              padding: const EdgeInsets.all(16.0),
              width: double.maxFinite,
              child: _waveform == null
                  ? const Center(
                      child: Text('loading'),
                    )
                  : AudioWaveformWidget(
                      waveform: _waveform!,
                      start: Duration.zero,
                      duration: _waveform!.duration,
                    ))

          // : AudioWaveformWidget(
          //     waveform: waveform!,
          //     start: Duration.zero,
          //     duration: waveform!.duration,
          //   )),
        ],
      ),
    );
  }
}

class AudioWaveformWidget extends StatefulWidget {
  final Color waveColor;
  final double scale;
  final double strokeWidth;
  final double pixelsPerStep;
  final Waveform waveform;
  final Duration start;
  final Duration duration;

  const AudioWaveformWidget({
    Key? key,
    required this.waveform,
    required this.start,
    required this.duration,
    this.waveColor = Colors.blue,
    this.scale = 1.0,
    this.strokeWidth = 5.0,
    this.pixelsPerStep = 8.0,
  }) : super(key: key);

  @override
  _AudioWaveformState createState() => _AudioWaveformState();
}

class _AudioWaveformState extends State<AudioWaveformWidget> {
  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: CustomPaint(
        painter: AudioWaveformPainter(
          waveColor: widget.waveColor,
          waveform: widget.waveform,
          start: widget.start,
          duration: widget.duration,
          scale: widget.scale,
          strokeWidth: widget.strokeWidth,
          pixelsPerStep: widget.pixelsPerStep,
        ),
      ),
    );
  }
}

class AudioWaveformPainter extends CustomPainter {
  final double scale;
  final double strokeWidth;
  final double pixelsPerStep;
  final Paint wavePaint;
  final Waveform waveform;
  final Duration start;
  final Duration duration;

  AudioWaveformPainter({
    required this.waveform,
    required this.start,
    required this.duration,
    Color waveColor = Colors.blue,
    this.scale = 1.0,
    this.strokeWidth = 5.0,
    this.pixelsPerStep = 8.0,
  }) : wavePaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
          ..color = waveColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (duration == Duration.zero) return;

    double width = size.width;
    double height = size.height;

    final waveformPixelsPerWindow = waveform.positionToPixel(duration).toInt();
    final waveformPixelsPerDevicePixel = waveformPixelsPerWindow / width;
    final waveformPixelsPerStep = waveformPixelsPerDevicePixel * pixelsPerStep;
    final sampleOffset = waveform.positionToPixel(start);
    final sampleStart = -sampleOffset % waveformPixelsPerStep;
    for (var i = sampleStart.toDouble();
        i <= waveformPixelsPerWindow + 1.0;
        i += waveformPixelsPerStep) {
      final sampleIdx = (sampleOffset + i).toInt();
      final x = i / waveformPixelsPerDevicePixel;
      final minY = normalise(waveform.getPixelMin(sampleIdx), height);
      final maxY = normalise(waveform.getPixelMax(sampleIdx), height);
      canvas.drawLine(
        Offset(x + strokeWidth / 2, max(strokeWidth * 0.75, minY)),
        Offset(x + strokeWidth / 2, min(height - strokeWidth * 0.75, maxY)),
        wavePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant AudioWaveformPainter oldDelegate) {
    return false;
  }

  double normalise(int s, double height) {
    if (waveform.flags == 0) {
      final y = 32768 + (scale * s).clamp(-32768.0, 32767.0).toDouble();
      return height - 1 - y * height / 65536;
    } else {
      final y = 128 + (scale * s).clamp(-128.0, 127.0).toDouble();
      return height - 1 - y * height / 256;
    }
  }
}
