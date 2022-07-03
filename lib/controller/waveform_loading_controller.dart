import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:testdrive/models/waveform_loading_manager.dart';

class WaveformLoadingController extends StateNotifier<WaveformLoadingManager> {
  WaveformLoadingController() : super(WaveformLoadingManager());

  int currentIndex() {
    return state.index;
  }

  updateIndex() {
    state.index++;
  }
}
