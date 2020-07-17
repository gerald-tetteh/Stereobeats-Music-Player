import 'dart:io';

import 'package:flutter/material.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../provider/music_player.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({
    Key key,
    @required this.audioProvider,
    @required this.mediaQuery,
  }) : super(key: key);

  final AudioPlayer audioProvider;
  final MediaQueryData mediaQuery;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: audioProvider.audioPlayer.isPlaying,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          bool isPlaying = snapshot.data;
          if (isPlaying) {
            return StreamBuilder(
              stream: audioProvider.audioPlayer.current,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  Playing current = snapshot.data;
                  Audio song = current.audio.audio;
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
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundImage:
                                      FileImage(File(song.metas.image.path)),
                                ),
                                Container(
                                  margin: EdgeInsets.only(
                                    left: 20,
                                  ),
                                  constraints: BoxConstraints(
                                    maxWidth: mediaQuery.size.width * 0.35,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                                icon: FaIcon(FontAwesomeIcons.stepBackward),
                                onPressed: () async =>
                                    await audioProvider.previousTrack()),
                            IconButton(
                                icon: FaIcon(FontAwesomeIcons.play),
                                onPressed: () async =>
                                    await audioProvider.playOrPause()),
                            IconButton(
                                icon: FaIcon(FontAwesomeIcons.stepForward),
                                onPressed: () async =>
                                    await audioProvider.nextTrack()),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                return Container();
              },
            );
          }
        }
        return Container();
      },
    );
  }
}
