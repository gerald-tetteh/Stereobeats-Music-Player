/*
 * Author: Gerald Addo-Tetteh
 * Stereo Beats Music Player for Android mobile devices.
 * Addo Develop
 * Email: addodevelop@gmail.com
 * Album Page
*/

/*
  This page shows all albums that are available on the 
  device.
*/

// imports

// package imports
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// lib file imports
import '../components/bottom_actions_bar.dart';
import '../components/playlist_&_album_main.dart';
import '../components/customDrawer.dart';
import '../components/mini_player.dart';
import '../provider/songItem.dart';
import '../provider/theme_mode.dart';
import '../utils/default_util.dart';
import '../utils/text_util.dart';
import '../utils/color_util.dart';

import 'search_view.dart';
import 'play_page.dart';

class AlbumListScreen extends StatelessWidget {
  // name of route
  static const routeName = "/album-screen";
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
    final songProvider = Provider.of<SongProvider>(context);
    final themeProvider = Provider.of<AppThemeMode>(context, listen: false);
    final mediaQuery = MediaQuery.of(context);
    return Scaffold(
      key: _scaffoldKey,
      // bottomNavigationBar: AnimatedContainer(
      //   child: BottomActionsBar(
      //     scaffoldKey: _scaffoldKey,
      //     deleteFunction: songProvider.deleteSongs,
      //   ),
      //   duration: Duration(milliseconds: 400),
      //   curve: Curves.easeIn,
      //   height: songProvider.showBottomBar ? 59 : 0,
      // ),
      backgroundColor:
          themeProvider.isDarkMode ? ColorUtil.dark2 : Color(0xffeeeeee),
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme,
        leading: IconButton(
          icon: Icon(
            Icons.menu,
            size: TextUtil.medium,
          ),
          onPressed: () {
            _scaffoldKey.currentState!.openDrawer();
            songProvider.changeBottomBar(false);
            songProvider.setQueueToNull();
            songProvider.setKeysToNull();
          },
        ),
        title: DefaultUtil.appName,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(Icons.search, size: TextUtil.medium),
            onPressed: () =>
                Navigator.of(context).pushNamed(SearchView.routeName),
          ),
        ],
      ),
      drawer: CustomDrawer(),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // renders the list of albums
          PlayListAndAlbum(
            title: "Albums",
            subTitle: "for you",
            purpose: Purpose.AlbumView,
            albums: songProvider.albums,
          ),
          Positioned(
            bottom: 10,
            left: 3,
            right: 3,
            // shows mini player if present
            child: MiniPlayer(
              mediaQuery: mediaQuery,
            ),
          ),
        ],
      ),
    );
  }
}
