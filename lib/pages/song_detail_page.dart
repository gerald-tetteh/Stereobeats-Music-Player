/*
 * Author: Gerald Addo-Tetteh
 * Stereo Beats Music Player for Android mobile devices.
 * Addo Develop
 * Email: addodevelop@gmail.com
 * Song Detail Page
*/

/*
  This page shows the metadata of a particular song.
  It recieves the path of the song as input.
*/

// imports

// package imports
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// lib file imports
import '../provider/songItem.dart';
import '../provider/music_player.dart';
import '../provider/theme_mode.dart';
import '../utils/text_util.dart';
import '../utils/default_util.dart';
import '../utils/color_util.dart';

import 'edit_song_page.dart';

class SongDetailPage extends StatelessWidget {
  // name of route
  static const routeName = "/song-detail-page";
  @override
  Widget build(BuildContext context) {
    final songProvider = Provider.of<SongProvider>(context);
    final player = Provider.of<AudioPlayer>(context, listen: false);
    final themeProvider = Provider.of<AppThemeMode>(context, listen: false);
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
      backgroundColor: themeProvider.isDarkMode ? ColorUtil.dark : null,
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
                    : DefaultUtil.checkListNotNull(song.artPath2) 
                      ? MemoryImage(song.artPath2) 
                      : AssetImage(DefaultUtil.defaultImage),
              ),
            ),
          ),
          Container(
            height: actualHeight * 0.6,
            child: ListView(
              children: [
                _buildListItem("Title", song.title, themeProvider, mediaQuery),
                _buildListItem(
                    "Artist", song.artist, themeProvider, mediaQuery),
                _buildListItem("Album", song.album, themeProvider, mediaQuery),
                _buildListItem("Album Artist", song.albumArtist, themeProvider,
                    mediaQuery),
                _buildListItem("Year", song.year, themeProvider, mediaQuery),
                _buildListItem(
                  "Length",
                  player.calculateDuration(int.parse(song.duration)),
                  themeProvider,
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

  // this method returns a colum showing a part of the
  // songs metadata
  Column _buildListItem(
      String leading, String songInfo, AppThemeMode themeProvider,
      [MediaQueryData mediaQuery, bool showDivider = true]) {
    return Column(
      children: [
        ListTile(
          leading: Text(
            "$leading :",
            style: TextUtil.songDetailTitles.copyWith(
              color: themeProvider.isDarkMode ? ColorUtil.white : null,
            ),
          ),
          title: Text(
            DefaultUtil.checkNotNull(songInfo) ? songInfo : DefaultUtil.unknown,
            style: themeProvider.isDarkMode ? TextUtil.allSongsTitle : null,
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
