import 'package:flutter/material.dart';

class Blob extends StatelessWidget {
  final double rotation;
  final double scale;
  final Color color;

  const Blob(
      {this.color = Colors.black, this.rotation = 0, this.scale = 1, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: Transform.rotate(
        angle: rotation,
        child: Container(
          width: kToolbarHeight,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(150),
              topRight: Radius.circular(240),
              bottomLeft: Radius.circular(220),
              bottomRight: Radius.circular(180),
            ),
          ),
        ),
      ),
    );
  }
}
