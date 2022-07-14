/*
 * Author: Gerald Addo-Tetteh
 * Stereo Beats Music Player for Android mobile devices.
 * Addo Develop
 * Email: addodevelop@gmail.com
 * Favourites Page
*/

/*
  This screen shows all the user's favourites.
  This page refreshes when the favourites list changes. 
*/

// imports

// package imports
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// lib file imports
import '../utils/text_util.dart';
import '../utils/default_util.dart';
import '../utils/color_util.dart';
import '../components/customDrawer.dart';
import '../components/quick_play_options.dart';
import '../provider/songItem.dart';
import '../provider/music_player.dart';
import '../provider/theme_mode.dart';
import '../components/mini_player.dart';
import '../components/favourite_songs_list_view.dart';
import '../components/bottom_actions_bar.dart';
import '../helpers/reviewHelper.dart';

import 'search_view.dart';
import 'play_page.dart';

class FavouritesPage extends StatelessWidget {
  // name of the route
  static const routeName = "/favourites-page";
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  final reviewHelper = ReviewHelper(DateTime.now());
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
    final favouriteSongs = songProvider.favourites;
    final audioProvider = Provider.of<AudioPlayer>(context, listen: false);
    final themeProvider = Provider.of<AppThemeMode>(context, listen: false);
    final mediaQuery = MediaQuery.of(context);
    // used to show review dialog.
    reviewHelper.showReview();
    return Scaffold(
      bottomNavigationBar: AnimatedContainer(
        child: BottomActionsBar(
          deleteFunction: songProvider.removeFromFavourites,
          scaffoldKey: _scaffoldKey,
        ),
        duration: Duration(milliseconds: 400),
        curve: Curves.easeIn,
        height: songProvider.showBottomBar ? 59 : 0,
      ),
      backgroundColor:
          themeProvider.isDarkMode ? ColorUtil.dark2 : Color(0xffeeeeee),
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
            icon: Icon(
              Icons.search,
              size: TextUtil.medium,
            ),
            onPressed: () =>
                Navigator.of(context).pushNamed(SearchView.routeName),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Column(
            children: [
              ListTile(
                title: Text(
                  "Favourites",
                  style: TextUtil.pageHeadingTop.copyWith(
                    color: themeProvider.isDarkMode ? ColorUtil.white : null,
                  ),
                ),
                subtitle: Text(
                  "by you",
                  style:
                      themeProvider.isDarkMode ? TextUtil.pageIntroSub : null,
                ),
                trailing: Icon(
                  Icons.favorite,
                  color: themeProvider.isDarkMode ? ColorUtil.darkTeal : null,
                ),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: themeProvider.isDarkMode
                        ? ColorUtil.dark
                        : ColorUtil.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: favouriteSongs != null && favouriteSongs.length != 0
                      ? _buildSongColumn(
                          mediaQuery, audioProvider, favouriteSongs)
                      : themeProvider.isDarkMode
                          ? Center(
                              child: DefaultUtil.emptyDarkMode(
                                  "No favourites yet..."))
                          : DefaultUtil.empty("No favourites yet..."),
                ),
              ),
            ],
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

  /*
    This method returns a column with the quick options 
    and the favourites list.
  */
  Column _buildSongColumn(MediaQueryData mediaQuery, AudioPlayer audioProvider,
      List<SongItem> favouriteSongs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          children: [
            Spacer(),
            QuickPlayOptions(
              provider: audioProvider,
              songs: favouriteSongs,
            ),
          ],
        ),
        Expanded(
          child: FavouriteSongListView(
            favouriteSongs: favouriteSongs,
            audioProvider: audioProvider,
          ),
        ),
        SizedBox(
          height: 73,
        ),
      ],
    );
  }
}
