import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/text_util.dart';
import '../utils/default_util.dart';
import '../utils/color_util.dart';
import '../components/customDrawer.dart';
import '../components/quick_play_options.dart';
import '../provider/songItem.dart';
import '../provider/music_player.dart';
import '../components/mini_player.dart';
import '../components/favourite_songs_list_view.dart';
import '../components/bottom_actions_bar.dart';

class FavouritesPage extends StatelessWidget {
  static const routeName = "/favourites-page";
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    final songProvider = Provider.of<SongProvider>(context);
    final favouriteSongs = songProvider.favourites;
    final audioProvider = Provider.of<AudioPlayer>(context, listen: false);
    final mediaQuery = MediaQuery.of(context);
    return Scaffold(
      bottomNavigationBar: AnimatedContainer(
        child: BottomActionsBar(
          deleteFunction: songProvider.removeFromFavourites,
          scaffoldKey: _scaffoldKey,
        ),
        duration: Duration(milliseconds: 400),
        curve: Curves.easeIn,
        height: songProvider.showBottonBar ? 59 : 0,
      ),
      backgroundColor: Color(0xffeeeeee),
      drawer: CustomDrawer(),
      key: _scaffoldKey,
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
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Column(
            children: [
              ListTile(
                title: Text(
                  "Favourites",
                  style: TextUtil.pageHeadingTop,
                ),
                subtitle: Text("by you"),
                trailing: Icon(Icons.favorite),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: ColorUtil.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      QuickPlayOptions(
                        mediaQuery: mediaQuery,
                        provider: audioProvider,
                        songs: favouriteSongs,
                      ),
                      Expanded(
                        child: FavouriteSongListView(
                          favouriteSongs: favouriteSongs,
                          audioProvider: audioProvider,
                        ),
                      ),
                      Consumer<AudioPlayer>(
                        builder: (context, value, child) =>
                            value.miniPlayerPresent
                                ? SizedBox(
                                    height: 73,
                                  )
                                : Container(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
