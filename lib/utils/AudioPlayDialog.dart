import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/utils/player_widget.dart';

import '../main.dart';

class AudioPlayDialog extends StatefulWidget {
  @override
  _AudioPlayDialogState createState() => _AudioPlayDialogState();
}

class _AudioPlayDialogState extends State<AudioPlayDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      elevation: 0.0,
      backgroundColor: appStore.scaffoldBackground,
      child: PlayerWidget(
          url: "https://luan.xyz/files/audio/ambient_c_motion.mp3"),
    );
  }
}
