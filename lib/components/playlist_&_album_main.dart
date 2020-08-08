import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import '../models/playlist.dart';
import '../provider/songItem.dart';
import '../utils/text_util.dart';
import '../utils/default_util.dart';
import '../utils/color_util.dart';
import '../extensions/string_extension.dart';

enum Purpose { PlayListView, AlbumView }

class PlayListAndAlbum extends StatelessWidget {
  final String title;
  final String subTitle;
  final List<Map<String, SongItem>> albums;
  final Purpose purpose;

  PlayListAndAlbum({
    this.title,
    this.subTitle,
    this.albums,
    this.purpose,
  });
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final songProvider = Provider.of<SongProvider>(context, listen: false);
    if (purpose == Purpose.PlayListView) {
      return Column(
        children: [
          ListTile(
            title: Text(
              title,
              style: TextUtil.pageHeadingTop,
            ),
            subtitle: Text(subTitle),
            trailing: Icon(Icons.library_music_outlined),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: ColorUtil.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: _buildPlayList(mediaQuery, songProvider),
            ),
          ),
        ],
      );
    } else {
      return Text("Helo");
    }
  }

  Widget _buildPlayList(MediaQueryData mediaQuery, SongProvider songProvider) {
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
            String artPath;
            if (playLists[index].paths != null) {
              artPath = songProvider.getArtPath(playLists[index].paths[0]);
            }
            return ListTile(
              title: Text(
                playLists[index].toString().capitalize(),
                style: TextUtil.playlistCardTitle,
              ),
              subtitle: Text(
                "Tracks: ${playLists[index].paths == null ? 0 : playLists[index].paths.length}",
              ),
              trailing: CircleAvatar(
                backgroundColor: Colors.black,
                backgroundImage: artPath != null
                    ? FileImage(File(artPath))
                    : AssetImage(DefaultUtil.defaultImage),
              ),
            );
          },
        );
      },
    );
  }
}
