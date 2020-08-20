import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/bottom_actions_bar.dart';
import '../components/playlist_&_album_main.dart';
import '../components/customDrawer.dart';
import '../components/mini_player.dart';
import '../provider/songItem.dart';
import '../provider/music_player.dart';
import '../utils/default_util.dart';
import '../utils/text_util.dart';

import 'search_view.dart';

class AlbumListScreen extends StatelessWidget {
  static const routeName = "/album-screen";
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    final songProvider = Provider.of<SongProvider>(context);
    final mediaQuery = MediaQuery.of(context);
    return Scaffold(
      key: _scaffoldKey,
      bottomNavigationBar: AnimatedContainer(
        child: BottomActionsBar(
          scaffoldKey: _scaffoldKey,
          deleteFunction: songProvider.deleteSongs,
        ),
        duration: Duration(milliseconds: 400),
        curve: Curves.easeIn,
        height: songProvider.showBottonBar ? 59 : 0,
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
          PlayListAndAlbum(
            title: "Albums",
            subTitle: "for you",
            purpose: Purpose.AlbumView,
            albums: songProvider.getAlbumsFromSongs(),
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
