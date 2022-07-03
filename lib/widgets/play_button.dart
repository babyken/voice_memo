import 'package:flutter/material.dart';
import 'package:testdrive/models/audio_player.dart';
import 'package:testdrive/models/audio_record.dart';
import 'package:testdrive/widgets/alert_dialog.dart';
import 'package:testdrive/utils/extension.dart';

typedef Fn = void Function();

class PlayButton extends StatefulWidget {
  const PlayButton(this.rec, this._player, {Key? key}) : super(key: key);

  final AudioRecord rec;
  final AudioPlayer _player;

  @override
  State<PlayButton> createState() => _PlayButtonState();
}

class _PlayButtonState extends State<PlayButton> {
  void toggleButton() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: '#dddddd'.toColor(),
      child: IconButton(
          icon: Icon(
            widget._player.isPlaying ? Icons.stop : Icons.play_arrow,
            color: Colors.blue,
          ),
          onPressed: () async {
            try {
              await widget._player.togglePlaying(widget.rec, toggleButton);
              toggleButton();
            } catch (err) {
              showAlertDialog(context, err);
            }
          }),
    );
  }
}
