import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/playlist.dart';
import '../provider/songItem.dart';

class PlayListAndAlbum extends StatelessWidget {
  final String title;
  final String subTitle;
  final List<Map<String, SongItem>> albums;

  PlayListAndAlbum({
    this.title,
    this.subTitle,
    this.albums,
  });
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return _buildPlayList(mediaQuery);
  }

  Widget _buildPlayList(MediaQueryData mediaQuery) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<PlayList>("playLists").listenable(),
      builder: (context, Box<PlayList> box, child) {
        var playLists = box.values.toList() ?? [];
        if (playLists == null || playLists.length == 0) {
          return Center(
            child: Text("No PlayLists"),
          );
        }
        return ListView.separated(
          separatorBuilder: (context, index) => index != playLists.length - 1
              ? Divider(
                  indent: mediaQuery.size.width * (1 / 4),
                )
              : "",
          itemCount: playLists.length,
          itemBuilder: (context, index) {
            return Card(
              child: ListTile(
                title: Text(playLists[index].toString()),
                subtitle: Text(
                    "Tracks: ${playLists[index].paths == null ? 0 : playLists[index].paths.length}"),
              ),
            );
          },
        );
      },
    );
  }
}
