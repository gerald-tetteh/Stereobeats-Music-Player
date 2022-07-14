/*
 * Author: Gerald Addo-Tetteh
 * Stereo Beats Music Player for Android mobile devices.
 * Addo Develop
 * Email: addodevelop@gmail.com
 * Album Detail Screen
*/

/*
  This screen shows all the songs on the album
*/

// imports

// package imports
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';

// lib file imports
import '../components/playlist_&_album_detail.dart';
import '../components/mini_player.dart';
import '../components/bottom_actions_bar.dart';
import '../provider/songItem.dart';
import '../provider/theme_mode.dart';
import '../utils/color_util.dart';

import 'play_page.dart';

class AlbumDetailScreen extends StatelessWidget {
  // name of route
  static const routeName = "/album-detail";
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
    final album = ModalRoute.of(context)!.settings.arguments as AlbumModel?;
    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? ColorUtil.dark : null,
      key: _scaffoldKey,
      bottomNavigationBar:
          Consumer<SongProvider>(builder: (context, songProvider, _) {
        return AnimatedContainer(
          child: BottomActionsBar(
            scaffoldKey: _scaffoldKey,
            deleteFunction: songProvider.deleteSongs,
          ),
          duration: Duration(milliseconds: 400),
          curve: Curves.easeIn,
          height: songProvider.showBottomBar ? 59 : 0,
        );
      }),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // renders the list of songs
          PlaylistAndAlbumDetail(
            album: album,
          ),
          Positioned(
            bottom: 10,
            left: 3,
            right: 3,
            // shows mini player if available
            child: MiniPlayer(mediaQuery: mediaQuery),
          ),
        ],
      ),
    );
  }
}
