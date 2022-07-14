/*
 * Author: Gerald Addo-Tetteh
 * Stereo Beats Music Player for Android mobile devices.
 * Addo Develop
 * Email: addodevelop@gmail.com
 * Play Page Song Info (Component)
*/

/*
  This widgets returns a conatiner showing the title and
  artist of the current song.
  A heart icon is below the text. It is used indicated the 
  favourite status.
*/

// imports

// package imports
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stereo_beats_main/provider/songItem.dart';

// lib file imports
import '../provider/music_player.dart';
import '../utils/default_util.dart';
import '../utils/text_util.dart';

class PlayPageSongInfo extends StatelessWidget {
  const PlayPageSongInfo({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // the consumer rebuilds the widget when the song changes
    return Consumer<AudioPlayer>(builder: (context, provider, child) {
      final song =
          provider.songsQueue[provider.findCurrentIndex(provider.playing.path)]!;
      final mediaQuery = MediaQuery.of(context);
      return Container(
        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
        child: Container(
          width: mediaQuery.size.width,
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Text(
                DefaultUtil.checkNotNull(song.title)
                    ? song.title!
                    : DefaultUtil.unknown,
                style: TextUtil.playPageTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              Text(
                DefaultUtil.checkNotNull(song.artist)
                    ? song.artist!
                    : DefaultUtil.unknown,
                style: TextUtil.mutedText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              Consumer<SongProvider>(
                builder: (context, songProvider, child) => IconButton(
                  icon: Icon(
                    songProvider.isFavourite(song.path)
                        ? Icons.favorite
                        : Icons.favorite_border,
                  ),
                  onPressed: () => songProvider.toggleFavourite(song.path),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
