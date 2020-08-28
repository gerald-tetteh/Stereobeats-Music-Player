/*
 * Author: Gerald Addo-Tetteh
 * Stereo Beats Music Player for Android mobile devices.
 * Addo Develop
 * Email: addodevelop@gmail.com
 * Home Page
*/

// imports

// package imports
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stereo_beats_main/provider/music_player.dart';
import 'package:stereo_beats_main/utils/default_util.dart';

// lib file imports
import '../provider/songItem.dart';
import '../utils/color_util.dart';
import '../utils/text_util.dart';
import '../utils/default_util.dart';
import '../components/image_builder.dart';
import '../components/mini_player.dart';
import '../components/custum_list_view.dart';
import '../components/customDrawer.dart';

import 'search_view.dart';

class HomeScreen extends StatelessWidget {
  // name of route
  static const routeName = "/home-page";
  final _scaffoldkey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    var songProvider = Provider.of<SongProvider>(context);
    List<SongItem> songs = songProvider.songsFraction;
    final mediaQuery = MediaQuery.of(context);
    var viewHeight = mediaQuery.size.height;
    var extraPadding = mediaQuery.padding.top;
    var actualHeight = viewHeight - extraPadding;
    var _isLandScape = mediaQuery.orientation == Orientation.landscape;
    return Scaffold(
      key: _scaffoldkey,
      drawer: CustomDrawer(),
      backgroundColor: Color(0xffeeeeee),
      // returns empty widget if there are songs on the device
      body: songs != null && songs.length != 0
          ? _buildSongList(_isLandScape, actualHeight, songs, _scaffoldkey,
              mediaQuery, songProvider, context)
          : _noSongs(context),
    );
  }

  /*
    This method returns a column that contains an AppBar 
    and the empty widget.
  */
  Column _noSongs(BuildContext ctx) {
    return Column(
      children: [
        AppBar(
          title: DefaultUtil.appName,
          iconTheme: Theme.of(ctx).iconTheme,
          leading: IconButton(
            icon: Icon(
              Icons.menu,
              size: TextUtil.medium,
            ),
            onPressed: () => _scaffoldkey.currentState.openDrawer(),
          ),
        ),
        Center(child: DefaultUtil.empty("No songs found...")),
      ],
    );
  }

  /*
    This method build the home page widgets.
    The top half of the page contains the search
    button, the app name and a button to open the drawer
    The background of the top half is the album art of the first 
    song in the songs fraction.
    The bottom half is a list view showing all the songs in the
    song fraction.
  */
  Stack _buildSongList(
      bool _isLandScape,
      double actualHeight,
      List<SongItem> songs,
      GlobalKey<ScaffoldState> _scaffoldkey,
      MediaQueryData mediaQuery,
      SongProvider songProvider,
      BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Column(
          children: [
            Container(
              height: _isLandScape ? actualHeight * 0.4 : actualHeight * 0.5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ImageBuilder(path: songs[0].artPath),
                  Positioned(
                    right: 10,
                    top: 15,
                    left: 10,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.menu,
                            size: TextUtil.large,
                          ),
                          onPressed: () {
                            _scaffoldkey.currentState.openDrawer();
                          },
                        ),
                        DefaultUtil.appName,
                        IconButton(
                          icon: Icon(
                            Icons.search,
                            size: TextUtil.large,
                          ),
                          onPressed: () => Navigator.of(context)
                              .pushNamed(SearchView.routeName),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 0,
                    bottom: 0,
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: mediaQuery.size.width * 0.6,
                      ),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(40),
                        ),
                        color: Color(0xffeeeeee),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            songs[0].title,
                            style: TextUtil.homeSongTitle,
                            maxLines: 2,
                            overflow: TextOverflow.fade,
                          ),
                          Text(
                            songs[0].artist,
                            maxLines: 1,
                            overflow: TextOverflow.fade,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _BottomSheet(
                songs: songs,
                songProvider: songProvider,
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
    );
  }
}

/*
  The bottom sheet renders a list view showing the songs 
  fraction.
*/
class _BottomSheet extends StatelessWidget {
  const _BottomSheet({
    Key key,
    @required this.songs,
    @required this.songProvider,
  }) : super(key: key);

  final List<SongItem> songs;
  final SongProvider songProvider;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      maxChildSize: 1,
      initialChildSize: 1,
      expand: false,
      builder: (context, scrollController) => Container(
        padding: EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(100),
          ),
          color: ColorUtil.white,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(100),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 40,
                      top: 10,
                    ),
                    child: Text(
                      "Quick Pick",
                      style: TextUtil.quickPick,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.play_circle_outline,
                      size: TextUtil.large,
                    ),
                    onPressed: () =>
                        Provider.of<AudioPlayer>(context, listen: false)
                            .play(songs),
                  ),
                ],
              ),
              Expanded(
                child: ListView.builder(
                  addAutomaticKeepAlives: true,
                  itemCount: songs.length,
                  itemBuilder: (context, index) {
                    return CustomListView(
                      song: songs[index],
                      songs: songs,
                      index: index,
                    );
                  },
                ),
              ),
              Consumer<AudioPlayer>(
                builder: (context, value, child) => value.miniPlayerPresent
                    ? SizedBox(
                        height: 73,
                      )
                    : Container(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
