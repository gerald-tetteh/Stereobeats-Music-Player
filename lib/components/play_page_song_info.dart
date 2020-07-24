import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stereo_beats_main/provider/songItem.dart';

import '../provider/music_player.dart';
import '../utils/default_util.dart';
import '../utils/text_util.dart';

class PlayPageSongInfo extends StatelessWidget {
  const PlayPageSongInfo({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioPlayer>(builder: (context, provider, child) {
      final song =
          provider.songsQueue[provider.findCurrentIndex(provider.playing.path)];
      return Container(
        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
        child: Column(
          children: [
            Text(
              DefaultUtil.checkNotNull(song.title)
                  ? song.title
                  : DefaultUtil.unknown,
              style: TextUtil.playPageTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            Text(
              DefaultUtil.checkNotNull(song.artist)
                  ? song.artist
                  : DefaultUtil.unknown,
              style: TextUtil.mutedText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            Consumer<SongProvider>(
              builder: (context, songProvider, child) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  icon: Icon(songProvider.isFavourite(song.path)
                      ? Icons.favorite
                      : Icons.favorite_border),
                  onPressed: () => songProvider.toggleFavourite(song.path),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
