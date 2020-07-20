import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../provider/music_player.dart';
import '../utils/default_util.dart';
import '../utils/text_util.dart';
import '../components/play_page_song_info.dart';
import '../components/slider_and_duration.dart';

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
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(
              Icons.search,
              size: TextUtil.large,
            ),
            onPressed: () {},
          ),
        ],
        title: DefaultUtil.appName,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: slider,
          ),
          Expanded(
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PlayPageSongInfo(),
                  SliderAndDuration(),
                  PlayerBuilder.isPlaying(
                    player: value.audioPlayer,
                    builder: (context, playing) {
                      var isPlaying = playing ?? false;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          IconButton(
                              icon: FaIcon(FontAwesomeIcons.stepBackward),
                              onPressed: () async =>
                                  await value.previousTrack()),
                          IconButton(
                              icon: (!isPlaying)
                                  ? FaIcon(FontAwesomeIcons.play)
                                  : FaIcon(FontAwesomeIcons.pause),
                              onPressed: () async => await value.playOrPause()),
                          IconButton(
                              icon: FaIcon(FontAwesomeIcons.stepForward),
                              onPressed: () async => await value.nextTrack()),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
