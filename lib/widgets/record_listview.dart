import 'package:flutter/material.dart';

import 'package:testdrive/controller/providers.dart';
import 'package:testdrive/models/audio_record.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:testdrive/widgets/play_button.dart';

import 'package:testdrive/models/audio_player.dart';
import 'package:testdrive/widgets/waveform.dart';

import 'package:just_waveform/just_waveform.dart';

import 'package:async/async.dart' show StreamGroup;

class RecordListView extends ConsumerStatefulWidget {
  const RecordListView({Key? key}) : super(key: key);

  @override
  ConsumerState<RecordListView> createState() => _RecordListViewState();
}

class _RecordListViewState extends ConsumerState<RecordListView> {
  // AudioRecordController? recordController;
  final AudioPlayer _player = AudioPlayer();
  final StreamGroup<WaveformProgress> streamGroup =
      StreamGroup<WaveformProgress>();

  @override
  void initState() {
    _player.init().then((_) {
      setState(() {
        print('player init complete');
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void streamCallback(Stream<WaveformProgress> stream) {
    streamGroup.add(stream);
    print('------------- Streamn Group------------');
    print(streamGroup.stream);
  }

  @override
  Widget build(BuildContext context) {
    final aysnclistRecord = ref.watch(audioRecordProvider);

    return aysnclistRecord.when(
        data: (data) => ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              AudioRecord rec = data[index];

              return Dismissible(
                key: UniqueKey(),
                onDismissed: (direction) async {
                  // Remove the item from the data source.
                  await ref
                      .read(audioRecordProvider.notifier)
                      .removeRecord(rec);
                  // setState(() {

                  // });

                  // Then show a snackbar.
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${rec.name} removed')));
                },
                child: ListTile(
                  title: WaveformVisual(
                      record: rec, index: index, callback: streamCallback),
                  leading: PlayButton(rec, _player),
                ),
              );
            }),
        error: (e, st) => Text('Error: $e'),
        loading: () => const CircularProgressIndicator());
  }
}
