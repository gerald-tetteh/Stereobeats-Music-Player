/*
 * Author: Gerald Addo-Tetteh
 * Stereo Beats Music Player for Android mobile devices.
 * Addo Develop
 * Email: addodevelop@gmail.com
 * Mini Player (component)
*/

/// This widget returns a rectangle with rounded edges which shows
/// the current song that is playing. It also has controls to pause or play the
/// song and also skip to the next track or return to the previous song.

/// Clicking on the mini player opens the play page.

// imports

// package imports
import 'package:flutter/material.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

// lib file imports
import '../provider/music_player.dart';
import '../provider/theme_mode.dart';
import '../utils/text_util.dart';
import '../pages/play_page.dart';
import '../utils/default_util.dart';
import '../utils/color_util.dart';

import './circular_image.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({
    Key? key,
    required this.mediaQuery,
  }) : super(key: key);

  final MediaQueryData mediaQuery;
  @override
  Widget build(BuildContext context) {
    // widget rebuilds each time the song changes.
    final audioProvider = Provider.of<AudioPlayer>(context);
    final themeProvider = Provider.of<AppThemeMode>(context, listen: false);
    if (audioProvider.audioPlayer.playerState.value != PlayerState.stop) {
      Audio song = audioProvider.playing!;
      final albumId = song.metas.extra!["albumId"] as int?;
      final songId = song.metas.extra!["songId"] as int?;
      return GestureDetector(
        onTap: () => Navigator.of(context).pushNamed(PlayMusicScreen.routeName),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
          ),
          child: Card(
            color: themeProvider.isDarkMode ? ColorUtil.dark2 : null,
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
                          child: CircularImage(
                            albumId: albumId,
                            songId: songId,
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
                                  song.metas.title!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: themeProvider.isDarkMode
                                      ? TextUtil.miniPlayerTitle
                                      : null,
                                ),
                                Text(
                                  song.metas.artist!,
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
                        icon: FaIcon(FontAwesomeIcons.backwardStep),
                        onPressed: () async =>
                            await audioProvider.previousTrack(),
                      ),
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
                              await audioProvider.playOrPause(),
                        ),
                      ),
                      IconButton(
                        icon: FaIcon(FontAwesomeIcons.forwardStep),
                        onPressed: () async => await audioProvider.nextTrack(),
                      ),
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
        color: themeProvider.isDarkMode ? ColorUtil.dark2 : null,
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
