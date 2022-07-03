import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/audio_setting.dart';

class AudioSettingController extends StateNotifier<AudioSetting> {
  AudioSettingController() : super(AudioSetting(16000, 16000));

  updateBitrate(double newBitrate) {
    state.bitrate = newBitrate;
  }

  updateSamplerate(double newSampleRate) {
    state.samplerate = newSampleRate;
  }

  double bitrate() {
    if (state.bitrate != null) {
      return state.bitrate!;
    }
    // default
    return 16000;
  }

  double samplerate() {
    if (state.samplerate != null) {
      return state.samplerate!;
    }
    // default
    return 16000;
  }
}
