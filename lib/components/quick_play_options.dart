/*
 * Author: Gerald Addo-Tetteh
 * Stereo Beats Music Player for Android mobile devices.
 * Addo Develop
 * Email: addodevelop@gmail.com
 * Quick Play Options
*/

/*
  This widget returns a row which
  contains two widgets that either shuffle all the songs
  or plays them in alphabetical order.
*/

// imports

// package imports
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// lib file imports
import '../provider/songItem.dart';
import '../utils/text_util.dart';
import '../provider/music_player.dart';

class QuickPlayOptions extends StatelessWidget {
  const QuickPlayOptions({
    Key key,
    @required this.provider,
    @required this.songs,
  }) : super(key: key);

  final AudioPlayer provider; // audio player
  final List<SongItem> songs;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: FaIcon(
              FontAwesomeIcons.random,
              size: TextUtil.xsmall,
            ),
            onPressed: () async {
              await provider.setShuffle(true);
              await provider.play(songs, 0, true);
            },
          ),
          IconButton(
            icon: FaIcon(
              FontAwesomeIcons.playCircle,
              size: TextUtil.xsmall,
            ),
            onPressed: () async {
              await provider.setShuffle(false);
              await provider.play(songs, 0, false);
            },
          ),
        ],
      ),
    );
  }
}
