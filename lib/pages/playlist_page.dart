/*
 * Author: Gerald Addo-Tetteh
 * Stereo Beats Music Player for Android mobile devices.
 * Addo Develop
 * Email: addodevelop@gmail.com
 * Playlist Page
*/

/*
  This page shows all available playlists and 
  also gives the user an option to create a new playlist.
*/

//imports

// package imports
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// lib file imports
import '../utils/default_util.dart';
import '../utils/text_util.dart';
import '../components/customDrawer.dart';
import '../components/playlist_&_album_main.dart';
import '../helpers/db_helper.dart';
import '../provider/songItem.dart';
import '../components/mini_player.dart';
import '../components/bottom _sheet.dart';
import '../components/bottom_actions_bar.dart';
import '../provider/music_player.dart';

class PlayListScreen extends StatelessWidget {
  static const routeName = "/playlist-screen";
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final songProvider = Provider.of<SongProvider>(context, listen: false);
    return Scaffold(
      key: _scaffoldKey,
      bottomNavigationBar: Consumer<SongProvider>(
        builder: (context, songProvider, child) {
          return AnimatedContainer(
            child: BottomActionsBar(
              playListDelete: DBHelper.deleteBox,
              scaffoldKey: _scaffoldKey,
              renameFunction: DBHelper.changeItemName,
            ),
            duration: Duration(milliseconds: 400),
            curve: Curves.easeIn,
            height: songProvider.showBottonBar ? 59 : 0,
          );
        },
      ),
      backgroundColor: Color(0xffeeeeee),
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme,
        leading: IconButton(
          icon: Icon(
            Icons.menu,
            size: TextUtil.medium,
          ),
          onPressed: () {
            _scaffoldKey.currentState.openDrawer();
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
            icon: Icon(
              Icons.library_add_outlined,
              size: TextUtil.medium,
            ),
            onPressed: () {
              final _formKey = GlobalKey<FormState>();
              Provider.of<SongProvider>(context, listen: false)
                  .setQueueToNull();
              showModalBottomSheet(
                context: _scaffoldKey.currentState.context,
                builder: (ctx) {
                  return ModalSheet(_formKey);
                },
                isScrollControlled: true,
              );
            },
          ),
        ],
      ),
      drawer: CustomDrawer(),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // renders playlist list
          PlayListAndAlbum(
            title: "Playlists",
            subTitle: "by you",
            purpose: Purpose.PlayListView,
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
