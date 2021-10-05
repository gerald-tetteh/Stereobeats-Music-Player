/*
 * Author: Gerald Addo-Tetteh
 * Stereo Beats Music Player for Android mobile devices.
 * Addo Develop
 * Email: addodevelop@gmail.com
 * Artist page
*/

// this page shows all the artists available on the device

// imports

// package imports
import 'dart:io';

import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// lib file imports
import '../components/customDrawer.dart';
import '../components/bottom_actions_bar.dart';
import '../provider/songItem.dart';
import '../provider/theme_mode.dart';
import '../utils/text_util.dart';
import '../utils/default_util.dart';
import '../utils/color_util.dart';
import '../components/mini_player.dart';

import 'artist_view_page.dart';
import 'search_view.dart';

class ArtistScreen extends StatelessWidget {
  // name of route
  static const routeName = "/artist-page";
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    final songProvider = Provider.of<SongProvider>(context);
    final themeProvider = Provider.of<AppThemeMode>(context, listen: false);
    final mediaQuery = MediaQuery.of(context);
    final artists = songProvider.artists();
    return Scaffold(
      key: _scaffoldKey,
      bottomNavigationBar: AnimatedContainer(
        child: BottomActionsBar(
          deleteFunction: songProvider.removeFromFavourites,
          scaffoldKey: _scaffoldKey,
        ),
        duration: Duration(milliseconds: 400),
        curve: Curves.easeIn,
        height: songProvider.showBottonBar ? 59 : 0,
      ),
      backgroundColor:
          themeProvider.isDarkMode ? ColorUtil.dark2 : Color(0xffeeeeee),
      drawer: CustomDrawer(),
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
              Icons.search,
              size: TextUtil.medium,
            ),
            onPressed: () =>
                Navigator.of(context).pushNamed(SearchView.routeName),
          ),
        ],
      ),
      // shows empty widget if there are no artists
      body: artists != null && artists.length != 0
          ? Stack(
              fit: StackFit.expand,
              children: [
                BuildColumn(
                  scrollController: _scrollController,
                  artists: artists,
                  mediaQuery: mediaQuery,
                  themeProvider: themeProvider,
                  songProvider: songProvider,
                ),
                Positioned(
                  bottom: 10,
                  left: 3,
                  right: 3,
                  // shows miniplayer if available
                  child: MiniPlayer(mediaQuery: mediaQuery),
                ),
              ],
            )
          : Center(
              child: themeProvider.isDarkMode
                  ? DefaultUtil.emptyDarkMode("Could not find any...")
                  : DefaultUtil.empty("Could not find any..."),
            ),
    );
  }
}

/*
  This widget shows the list of all artist on the device.
  It creats a list view with each item have the artist name
  and an image to represent the artist in a circular widget.
*/
class BuildColumn extends StatelessWidget {
  const BuildColumn({
    Key key,
    @required ScrollController scrollController,
    @required this.artists,
    @required this.mediaQuery,
    @required this.themeProvider,
    @required this.songProvider,
  })  : _scrollController = scrollController,
        super(key: key);

  final ScrollController _scrollController;
  final List<String> artists;
  final MediaQueryData mediaQuery;
  final SongProvider songProvider;
  final AppThemeMode themeProvider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(
            "Artists",
            style: TextUtil.pageHeadingTop.copyWith(
              color: themeProvider.isDarkMode ? ColorUtil.white : null,
            ),
          ),
          subtitle: Text(
            "for you",
            style: themeProvider.isDarkMode ? TextUtil.pageIntroSub : null,
          ),
          trailing: Icon(
            Icons.person_outline_sharp,
            color: themeProvider.isDarkMode ? ColorUtil.darkTeal : null,
          ),
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color:
                  themeProvider.isDarkMode ? ColorUtil.dark : ColorUtil.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            padding: const EdgeInsets.all(10),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              /*
                The draggable scrollbar creats a list view with a 
                scroll bar to enable the user to jump to different points
                in the list view.
              */
              child: DraggableScrollbar.semicircle(
                backgroundColor:
                    themeProvider.isDarkMode ? ColorUtil.dark2 : null,
                child: ListView.separated(
                  controller: _scrollController,
                  itemCount: artists.length,
                  separatorBuilder: (context, index) =>
                      index != artists.length - 1
                          ? Divider(
                              endIndent: mediaQuery.size.width * (1 / 4),
                            )
                          : "",
                  itemBuilder: (context, index) {
                    final coverArt2 = songProvider.artistCoverArt2(artists[index]);
                    final coverArt = songProvider.artistCoverArt(artists[index]);
                    return Material(
                      color: themeProvider.isDarkMode
                          ? ColorUtil.dark
                          : ColorUtil.white,
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).pushNamed(
                              ArtistViewScreen.routeName,
                              arguments: {
                                "artist": artists[index],
                                "art": coverArt,
                                "art2": coverArt2,
                              });
                        },
                        child: ListTile(
                          title: Text(
                            artists[index],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: themeProvider.isDarkMode
                                ? TextUtil.allSongsTitle
                                : null,
                          ),
                          trailing: Hero(
                            tag: artists[index],
                            child: CircleAvatar(
                              backgroundColor: ColorUtil.dark,
                              backgroundImage:
                                  DefaultUtil.checkNotAsset(coverArt)
                                      ? FileImage(File(coverArt))
                                      : DefaultUtil.checkListNotNull(coverArt2) 
                                        ? MemoryImage(coverArt2) 
                                        : AssetImage(coverArt),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                controller: _scrollController,
              ),
            ),
          ),
        ),
        Container(
          color: themeProvider.isDarkMode ? ColorUtil.dark : null,
          height: 73,
        ),
      ],
    );
  }
}
