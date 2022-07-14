/*
 * Author: Gerald Addo-Tetteh
 * Stereo Beats Music Player for Android mobile devices.
 * Addo Develop
 * Email: addodevelop@gmail.com
 * Playlist Detail Screen
*/

/*
  This Screen shows all the songs on a particular playlist.
*/

// imports

// package imports
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// lib file imports
import '../components/playlist_&_album_detail.dart';
import '../components/mini_player.dart';
import '../models/playlist.dart';
import '../components/bottom_actions_bar.dart';
import '../provider/songItem.dart';
import '../provider/theme_mode.dart';
import '../utils/color_util.dart';
import '../helpers/db_helper.dart';

import 'play_page.dart';

class PlaylistDetailScreen extends StatelessWidget {
  // name of route
  static const routeName = "/playlist-detail";
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    AssetsAudioPlayer.addNotificationOpenAction((notification) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        PlayMusicScreen.routeName,
        (route) => route.isFirst,
      );
      return true;
    });
    final mediaQuery = MediaQuery.of(context);
    final themeProvider = Provider.of<AppThemeMode>(context, listen: false);
    final playlist = ModalRoute.of(context)!.settings.arguments as PlayList?;
    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? ColorUtil.dark : null,
      key: _scaffoldKey,
      bottomNavigationBar:
          Consumer<SongProvider>(builder: (context, songProvider, _) {
        return AnimatedContainer(
          child: BottomActionsBar(
            playlistName: playlist.toString(),
            scaffoldKey: _scaffoldKey,
            playListDeleteSingle: DBHelper.deleteItem,
          ),
          duration: Duration(milliseconds: 400),
          curve: Curves.easeIn,
          height: songProvider.showBottomBar ? 59 : 0,
        );
      }),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // renders list of song on playlist
          PlaylistAndAlbumDetail(
            playlist: playlist,
          ),
          Positioned(
            bottom: 10,
            left: 3,
            right: 3,
            child: MiniPlayer(mediaQuery: mediaQuery),
          ),
        ],
      ),
    );
  }
}
