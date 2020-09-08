/*
 * Author: Gerald Addo-Tetteh
 * Stereo Beats Music Player for Android mobile devices.
 * Addo Develop
 * Email: addodevelop@gmail.com
 * Mini Player (component)
*/

/*
  This widget returns a rectangle with rounded edges which shows
  the current song that is playing. It also has controls to pause or play the
  song and also sekip to the next track or return to the previous song.

  Cliking on the miniplayer opens the play page.
*/

// imports

// package imports
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

// lib file imports
import '../provider/music_player.dart';
import '../provider/songItem.dart';
import '../utils/text_util.dart';
import '../pages/play_page.dart';
import '../utils/default_util.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({
    Key key,
    @required this.mediaQuery,
  }) : super(key: key);

  final MediaQueryData mediaQuery;
  @override
  Widget build(BuildContext context) {
    // widget rebuilds each time the song changes.
    final audioProvider = Provider.of<AudioPlayer>(context);
    final songProvider = Provider.of<SongProvider>(context, listen: false);
    if (audioProvider.audioPlayer.playerState.value != PlayerState.stop) {
      Audio song = audioProvider.playing;
      var albumArt = songProvider.getSongFromPath(song.path).artPath;
      return GestureDetector(
        onTap: () => Navigator.of(context).pushNamed(PlayMusicScreen.routeName),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
          ),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Hero(
                          tag: song.path,
                          child: CircleAvatar(
                            backgroundImage: DefaultUtil.checkNotNull(albumArt)
                                ? FileImage(File(albumArt))
                                : AssetImage(DefaultUtil.defaultImage),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.only(
                              left: 10,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // shows song title and artist
                                Text(
                                  song.metas.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  song.metas.artist,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextUtil.mutedText,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // play controls
                  Row(
                    children: [
                      IconButton(
                          icon: FaIcon(FontAwesomeIcons.stepBackward),
                          onPressed: () async =>
                              await audioProvider.previousTrack()),
                      // depending on the playing state
                      // either the play or pause button is shown
                      PlayerBuilder.playerState(
                        player: audioProvider.audioPlayer,
                        builder: (context, playerState) => IconButton(
                            icon: (playerState == PlayerState.pause ||
                                    playerState == PlayerState.stop)
                                ? FaIcon(FontAwesomeIcons.play)
                                : FaIcon(FontAwesomeIcons.pause),
                            onPressed: () async =>
                                await audioProvider.playOrPause()),
                      ),
                      IconButton(
                          icon: FaIcon(FontAwesomeIcons.stepForward),
                          onPressed: () async =>
                              await audioProvider.nextTrack()),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      // returned when no song is playing
      return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
        child: Padding(
          padding: const EdgeInsets.all(7),
          child: Center(child: DefaultUtil.appName),
        ),
      );
    }
  }
}
