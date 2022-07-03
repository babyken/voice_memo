import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:testdrive/controller/providers.dart';

import 'dart:async';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

import '../widgets/record_button.dart';
import '../widgets/record_listview.dart';
import '../screens/setting_screen.dart';
import '../models/audio_record_storage.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key, required this.title, required this.storage})
      : super(key: key);

  final String title;
  final AudioRecordStorage storage;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _showRecBtn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SettingScreen()),
                  );
                },
                child: const Icon(Icons.settings),
              )),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            Expanded(
              child: RecordListView(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          height: _showRecBtn ? 2 * kToolbarHeight : 0.0,
          child: _showRecBtn ? RecordButton(storage: widget.storage) : null),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showRecBtn = !_showRecBtn;
            setState(() {});
          },
          tooltip: 'Show Record Button',
          child: const Icon(Icons.mic_external_on_sharp)),
    );
  }
}
