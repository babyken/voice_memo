import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/audio_record_storage.dart';
import 'screens/home_screen.dart';

// Unchanged value
// final valueProvider = Provider<double>((_) {
//   return 36;
// });

void main() => runApp(const ProviderScope(child: MyApp()));

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test Audio',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(
          title: 'Audio Record testing', storage: AudioRecordStorage()),
    );
  }
}

// typedef Fn = void Function();

// class MyHomePage extends ConsumerStatefulWidget {
//   const MyHomePage({Key? key, required this.title, required this.storage})
//       : super(key: key);

//   final String title;
//   final AudioRecordStorage storage;

//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

// class _MyHomePageState extends ConsumerState<MyHomePage> {
  
//   // player
//   // final FlutterSoundPlayer _mPlayer = FlutterSoundPlayer();
//   // bool _mPlayerIsInited = false;
//   // double _mPlayerSubscriptionDuration = 0;
//   // Uint8List? _boumData;
//   // StreamSubscription? _mPlayerSubscription;
//   // int playerPos = 0;
//   // final _mPath = 'tau_file.mp4';
//   // final _codec = Codec.aacMP4;

//   // @override
//   // void initState() {
//   //   super.initState();
//   //   print(ref.read(valueProvider));
//   //   init().then((value) {
//   //     setState(() {
//   //       _mPlayerIsInited = true;
//   //     });
//   //   });
//   // }

//   // @override
//   // void dispose() {
//   //   stopPlayer();
//   //   cancelPlayerSubscriptions();

//   //   // Be careful : you must `close` the audio session when you have finished with it.
//   //   _mPlayer.closePlayer();
//   //   super.dispose();
//   // }

//   // void cancelPlayerSubscriptions() {
//   //   if (_mPlayerSubscription != null) {
//   //     _mPlayerSubscription!.cancel();
//   //     _mPlayerSubscription = null;
//   //   }
//   // }

//   // Future<void> init() async {
//   //   await _mPlayer.openPlayer();

//   //   _mPlayerSubscription = _mPlayer.onProgress!.listen((e) {
//   //     setState(() {
//   //       playerPos = e.position.inMilliseconds;
//   //     });
//   //   });
//   // }

//   // -------  Here is the code to playback  -----------------------

//   // // Player
//   // void play() async {
//   //   // _boumData = await getAssetData(_mPath);
//   //   await _mPlayer.startPlayer(
//   //       fromURI: _mPath,
//   //       // fromDataBuffer: _boumData,
//   //       codec: _codec,
//   //       whenFinished: () {
//   //         setState(() {});
//   //       });
//   //   setState(() {});
//   // }

//   // void stopPlayer() async {
//   //   await _mPlayer.stopPlayer();
//   // }

//   // Future<void> setPlayerSubscriptionDuration(
//   //     double d) async // v is between 0.0 and 2000 (milliseconds)
//   // {
//   //   _mPlayerSubscriptionDuration = d;
//   //   setState(() {});
//   //   await _mPlayer.setSubscriptionDuration(
//   //     Duration(milliseconds: d.floor()),
//   //   );
//   // }

//   // Fn? getPlayFn(FlutterSoundPlayer? player) {
//   //   if (!_mPlayerIsInited) {
//   //     return null;
//   //   }
//   //   return player!.isStopped ? play : stopPlayer;
//   // }

//   @override
//   Widget build(BuildContext context) {

//     return null
//   }
// }
