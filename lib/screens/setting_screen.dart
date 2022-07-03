import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:testdrive/controller/providers.dart';
import '../controller/setting.dart';

class SettingScreen extends ConsumerStatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends ConsumerState<SettingScreen> {
  AudioSettingController? settingController;

  double get _bitrateValue {
    if (settingController != null) {
      return settingController!.bitrate();
    }
    return 0;
  }

  double get _samplerateValue {
    if (settingController != null) {
      return settingController!.samplerate();
    }
    return 0;
  }

  @override
  void initState() {
    settingController = ref.read(audioSettingProvider.notifier);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Setting')),
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
                padding: const EdgeInsets.all(12),
                child: Text('Bit Rate (in Hz) - $_bitrateValue',
                    textAlign: TextAlign.start,
                    style: const TextStyle(
                      fontSize: 19.0,
                      // color: Colors.yellow,
                    ))),
            Slider(
              value: _bitrateValue,
              max: 32000,
              divisions: 16,
              label: _bitrateValue.round().toString(),
              onChanged: (double value) {
                setState(() {
                  settingController!.updateBitrate(value);
                });
              },
            ),
            Padding(
                padding: const EdgeInsets.all(12),
                child: Text('Sample Rate (in Hz, PCM only) - $_samplerateValue',
                    textAlign: TextAlign.start,
                    style: const TextStyle(
                      fontSize: 19.0,
                      // color: Colors.yellow,
                    ))),
            Slider(
              value: _samplerateValue,
              max: 32000,
              divisions: 16,
              label: _samplerateValue.round().toString(),
              onChanged: (double value) {
                setState(() {
                  settingController!.updateSamplerate(value);
                });
              },
            ),
          ],
        )));
  }
}
