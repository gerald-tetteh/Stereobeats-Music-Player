import 'dart:io';

import 'package:flutter/material.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../provider/music_player.dart';
import '../utils/text_util.dart';
import '../pages/play_page.dart';
import '../provider/songItem.dart';
import '../utils/default_util.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({
    Key key,
    @required this.mediaQuery,
  }) : super(key: key);

  final MediaQueryData mediaQuery;
  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioPlayer>(context, listen: false);
    return PlayerBuilder.isPlaying(
      player: audioProvider.audioPlayer,
      builder: (context, snapshot) {
        bool isPlaying = snapshot ?? false;
        Audio song = audioProvider.playing;
        int songIndex = audioProvider.audioPlayer.playlist.audios.indexOf(song);
        try {
          SongItem songItem = audioProvider.songsQueue[songIndex];
          return Container(
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
                    GestureDetector(
                      onTap: () => Navigator.of(context)
                          .pushNamed(PlayMusicScreen.routeName),
                      child: Row(
                        children: [
                          Hero(
                            tag: song.path,
                            child: CircleAvatar(
                              backgroundImage:
                                  DefaultUtil.checkNotNull(songItem.artPath)
                                      ? FileImage(File(songItem.artPath))
                                      : null,
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(
                              left: 20,
                            ),
                            constraints: BoxConstraints(
                              maxWidth: mediaQuery.size.width * 0.35,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
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
                        ],
                      ),
                    ),
                    IconButton(
                        icon: FaIcon(FontAwesomeIcons.stepBackward),
                        onPressed: () async =>
                            await audioProvider.previousTrack()),
                    IconButton(
                        icon: (!isPlaying)
                            ? FaIcon(FontAwesomeIcons.play)
                            : FaIcon(FontAwesomeIcons.pause),
                        onPressed: () async =>
                            await audioProvider.playOrPause()),
                    IconButton(
                        icon: FaIcon(FontAwesomeIcons.stepForward),
                        onPressed: () async => await audioProvider.nextTrack()),
                  ],
                ),
              ),
            ),
          );
        } catch (e) {
          return Container();
        }
      },
    );
  }
}
