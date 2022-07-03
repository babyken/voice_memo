import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:testdrive/controller/setting.dart';
import 'package:testdrive/controller/audio_record.dart';
import 'package:testdrive/models/audio_record.dart';
import 'package:testdrive/controller/waveform_loading_controller.dart';

final audioSettingProvider =
    StateNotifierProvider((_) => AudioSettingController());

final audioRecordProvider =
    StateNotifierProvider<AudioRecordController, AsyncValue<List<AudioRecord>>>(
        (_) {
  final controller = AudioRecordController();

  return controller;
});

final waveformLoadingProvider =
    StateNotifierProvider.autoDispose((_) => WaveformLoadingController());
