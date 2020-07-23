import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/music_player.dart';
import '../utils/default_util.dart';
import '../utils/text_util.dart';
import '../components/play_page_song_info.dart';
import '../components/slider_and_duration.dart';
import '../components/play_page_controls.dart';

class PlayMusicScreen extends StatefulWidget {
  static const routeName = "/play-page";

  @override
  _PlayMusicScreenState createState() => _PlayMusicScreenState();
}

class _PlayMusicScreenState extends State<PlayMusicScreen> {
  @override
  Widget build(BuildContext context) {
    final value = Provider.of<AudioPlayer>(context, listen: false);
    final slider = value.slider;
    // Color(0xffeceff1)
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: DefaultUtil.appName,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_drop_down,
            size: TextUtil.large,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: slider,
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.fromLTRB(0, 45, 0, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      PlayPageSongInfo(),
                      SliderAndDuration(),
                    ],
                  ),
                  PlayPageControls(value: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
