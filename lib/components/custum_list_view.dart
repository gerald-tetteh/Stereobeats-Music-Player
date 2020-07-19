import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/songItem.dart';
import '../utils/default_util.dart';
import '../components/box_image.dart';
import '../provider/music_player.dart';

class CustumListView extends StatelessWidget {
  const CustumListView({
    Key key,
    @required this.song,
    @required this.songs,
    @required this.index,
  }) : super(key: key);

  final SongItem song;
  final int index;
  final List<SongItem> songs;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: BoxImage(
        path: song.artPath,
      ),
      title: Text(
        DefaultUtil.checkNotNull(song.title) ? song.title : DefaultUtil.unknown,
      ),
      subtitle: Text(
        DefaultUtil.checkNotNull(song.artist)
            ? song.artist
            : DefaultUtil.unknown,
      ),
      onTap: () =>
          Provider.of<AudioPlayer>(context, listen: false).play(songs, index),
    );
  }
}
