/*
  * Author: Gerald Addo-Tetteh
  * StereoBeats Main
  * AllSongsPopUp
*/

// imports
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/songItem.dart';
import '../provider/music_player.dart';
import '../utils/text_util.dart';
import '../utils/default_util.dart';
import '../utils/color_util.dart';

import 'edit_song_page.dart';

class SongDetailPage extends StatelessWidget {
  static const routeName = "/song-detail-page";
  @override
  Widget build(BuildContext context) {
    final songProvider = Provider.of<SongProvider>(context);
    final player = Provider.of<AudioPlayer>(context, listen: false);
    final songPath = ModalRoute.of(context).settings.arguments as String;
    final song = songProvider.getSongFromPath(songPath);
    var appBar = AppBar(
      backgroundColor: ColorUtil.dark,
      elevation: 0,
      iconTheme: Theme.of(context).iconTheme,
      title: Text("Song Details"),
      actions: [
        IconButton(
          icon: Icon(
            Icons.edit_outlined,
            size: TextUtil.medium,
          ),
          onPressed: () => Navigator.of(context)
              .pushNamed(EditSongPage.routeName, arguments: {
            "song": song,
            "songProvider": songProvider,
          }),
        ),
      ],
    );
    var mediaQuery = MediaQuery.of(context);
    var appBarHeight = appBar.preferredSize.height;
    var extraPadding = mediaQuery.padding.top;
    var viewHeight = mediaQuery.size.height;
    var actualHeight = viewHeight - (appBarHeight + extraPadding);
    return Scaffold(
      appBar: appBar,
      body: Column(
        children: [
          Container(
            height: actualHeight * 0.4,
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: DefaultUtil.checkNotNull(song.artPath)
                    ? FileImage(File(song.artPath))
                    : AssetImage(DefaultUtil.defaultImage),
              ),
            ),
          ),
          Container(
            height: actualHeight * 0.6,
            child: ListView(
              children: [
                _buildListItem("Title", song.title, mediaQuery),
                _buildListItem("Artist", song.artist, mediaQuery),
                _buildListItem("Album", song.album, mediaQuery),
                _buildListItem("Album Artist", song.albumArtist, mediaQuery),
                _buildListItem("Year", song.year, mediaQuery),
                _buildListItem(
                  "Length",
                  player.calculateDuration(int.parse(song.duration)),
                  null,
                  false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Column _buildListItem(String leading, String songInfo,
      [MediaQueryData mediaQuery, bool showDivider = true]) {
    return Column(
      children: [
        ListTile(
          leading: Text(
            "$leading :",
            style: TextUtil.songDetailTitles,
          ),
          title: Text(
            DefaultUtil.checkNotNull(songInfo) ? songInfo : DefaultUtil.unknown,
          ),
        ),
        if (showDivider)
          Divider(
            indent: mediaQuery.size.width * 0.2,
          ),
      ],
    );
  }
}
