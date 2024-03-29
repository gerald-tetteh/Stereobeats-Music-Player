/*
 * Author: Gerald Addo-Tetteh
 * Stereo Beats Music Player for Android mobile devices.
 * Addo Develop
 * Email: addodevelop@gmail.com
 * All Songs Page
*/

// the page shows all songs available on the device

//imports

// package imports
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

// lib file imports
import '../provider/songItem.dart';
import '../provider/theme_mode.dart';
import '../utils/color_util.dart';
import '../utils/text_util.dart';
import '../utils/default_util.dart';
import '../components/customDrawer.dart';
import '../provider/music_player.dart';
import '../components/mini_player.dart';
import '../components/dropdown_menu.dart';
import '../components/quick_play_options.dart';
import '../components/bottom_actions_bar.dart';
import '../components/separated_positioned_list.dart';

import 'search_view.dart';
import 'play_page.dart';

class AllSongsScreen extends StatelessWidget {
  // name of route
  static const routeName = "/all-songs";
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
    final provider =
        Provider.of<AudioPlayer>(context, listen: false); // audio player
    final songProvider3 = Provider.of<SongProvider>(context, listen: false);
    GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
    final ItemScrollController itemScrollController =
        ItemScrollController(); // list view controller
    return Scaffold(
      bottomNavigationBar: Consumer<SongProvider>(
        builder: (context, songProvider, child) {
          return AnimatedContainer(
            child: BottomActionsBar(
              deleteFunction: songProvider.deleteSongs,
              scaffoldKey: _scaffoldKey,
            ),
            duration: Duration(milliseconds: 300),
            curve: Curves.easeIn,
            height: songProvider.showBottomBar ? 59 : 0,
          );
        },
      ),
      backgroundColor:
          themeProvider.isDarkMode ? ColorUtil.dark2 : Color(0xffeeeeee),
      drawer: CustomDrawer(),
      key: _scaffoldKey,
      appBar: AppBar(
        title: DefaultUtil.appName,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  color: themeProvider.isDarkMode ? ColorUtil.dark : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.menu,
                          size: TextUtil.medium,
                        ),
                        onPressed: () {
                          songProvider3.changeBottomBar(false);
                          songProvider3.setQueueToNull();
                          songProvider3.setKeysToNull();
                          _scaffoldKey.currentState!.openDrawer();
                        },
                      ),
                      Text(
                        "All Tracks",
                        style: TextUtil.pageHeadingTop.copyWith(
                          color:
                              themeProvider.isDarkMode ? ColorUtil.white : null,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.search,
                          size: TextUtil.medium,
                        ),
                        onPressed: () => Navigator.of(context)
                            .pushNamed(SearchView.routeName),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: themeProvider.isDarkMode
                        ? ColorUtil.dark
                        : ColorUtil.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: const Radius.circular(30),
                      topRight: const Radius.circular(30),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: const Radius.circular(30),
                      topRight: const Radius.circular(30),
                    ),
                    child: Column(
                      children: [
                        Consumer<SongProvider>(
                          builder: (context, songProvider2, child) {
                            return songProvider2.songs != null &&
                                    songProvider2.songs.length != 0
                                ? _topActionsBar(
                                    songProvider2,
                                    itemScrollController,
                                    mediaQuery,
                                    _scaffoldKey,
                                    provider)
                                : Container();
                          },
                        ),
                        Expanded(
                          // renders song list
                          child: SeparatedPositionedList(
                            itemScrollController: itemScrollController,
                            mediaQuery: mediaQuery,
                            scaffoldKey: _scaffoldKey,
                          ),
                        ),
                        // creates a space beneath the list so that
                        // it is not obstructed by the mini player
                        SizedBox(
                          height: 73,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
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

  /*
    This method returns a row containing the quick options
    (play all or shuffle) and a drop down sheet to jump to specific 
    points in the list view
  */
  Row _topActionsBar(
      SongProvider songProvider2,
      ItemScrollController itemScrollController,
      MediaQueryData mediaQuery,
      GlobalKey<ScaffoldState> scaffoldKey,
      AudioPlayer provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
          child: CustomDropDown(
            songProvider2.songs,
            itemScrollController,
            scaffoldKey,
          ),
        ),
        QuickPlayOptions(
          provider: provider,
          songs: songProvider2.songs,
        ),
      ],
    );
  }
}
