import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/audio_record.dart';
import 'package:testdrive/models/audio_record_storage.dart';
import 'package:path/path.dart' as p;

class AudioRecordController
    extends StateNotifier<AsyncValue<List<AudioRecord>>> {
  AudioRecordController() : super(const AsyncValue.loading()) {
    _loadFromDir();
  }

  Future<void> _loadFromDir() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => loadFromDir());
  }

  Future<List<AudioRecord>> loadFromDir() async {
    final AudioRecordStorage storage = AudioRecordStorage();
    return await storage.fileList;
  }

  Future<void> addRecord(AudioRecord newRecord) async {
    print('add record!!!');
    print(state.value);
    // state.value!.add(newRecord);

    state = state.whenData((value) {
      value.add(newRecord);
      return value;
    });

    //   AsyncValue.data(state);
    // state = await AsyncValue.guard(() => _loadFromState());
  }

  Future<void> removeRecord(AudioRecord removeRecord) async {
    final AudioRecordStorage storage = AudioRecordStorage();
    final result = await storage.removeRecord(removeRecord);
    print('del file result $result');
    state = await AsyncValue.guard(() => loadFromDir());
  }
}
