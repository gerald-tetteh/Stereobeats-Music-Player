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
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// lib file imports
import '../components/playlist_&_album_detail.dart';
import '../components/mini_player.dart';
import '../models/playlist.dart';
import '../components/bottom_actions_bar.dart';
import '../provider/songItem.dart';
import '../provider/music_player.dart';
import '../helpers/db_helper.dart';

class PlaylistDetailScreen extends StatelessWidget {
  // name of route
  static const routeName = "/playlist-detail";
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final playlist = ModalRoute.of(context).settings.arguments as PlayList;
    return Scaffold(
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
          height: songProvider.showBottonBar ? 59 : 0,
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
            child: Consumer<AudioPlayer>(
              builder: (context, value, child) => value.miniPlayerPresent
                  ? MiniPlayer(mediaQuery: mediaQuery)
                  : Container(),
            ),
          ),
        ],
      ),
    );
  }
}
