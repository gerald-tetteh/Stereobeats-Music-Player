/*
 * Author: Gerald Addo-Tetteh
 * StereoBeats Music Player
 * Artist Page
*/

// imports

// package imports
import 'dart:io';

import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// local imports
import '../components/customDrawer.dart';
import '../components/bottom_actions_bar.dart';
import '../provider/songItem.dart';
import '../provider/music_player.dart';
import '../utils/text_util.dart';
import '../utils/default_util.dart';
import '../utils/color_util.dart';
import '../components/mini_player.dart';

import 'artist_view_page.dart';
import 'search_view.dart';

class ArtistScreen extends StatelessWidget {
  static const routeName = "/artist-page";
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    final songProvider = Provider.of<SongProvider>(context);
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
      backgroundColor: Color(0xffeeeeee),
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
      body: artists != null && artists.length != 0
          ? Stack(
              fit: StackFit.expand,
              children: [
                BuildColumn(
                    scrollController: _scrollController,
                    artists: artists,
                    mediaQuery: mediaQuery,
                    songProvider: songProvider),
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
            )
          : Center(
              child: DefaultUtil.empty("Could not find any..."),
            ),
    );
  }
}

class BuildColumn extends StatelessWidget {
  const BuildColumn({
    Key key,
    @required ScrollController scrollController,
    @required this.artists,
    @required this.mediaQuery,
    @required this.songProvider,
  })  : _scrollController = scrollController,
        super(key: key);

  final ScrollController _scrollController;
  final List<String> artists;
  final MediaQueryData mediaQuery;
  final SongProvider songProvider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(
            "Artists",
            style: TextUtil.pageHeadingTop,
          ),
          subtitle: Text("for you"),
          trailing: Icon(Icons.person_outline_sharp),
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
            padding: const EdgeInsets.all(10),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              child: DraggableScrollbar.semicircle(
                child: ListView.separated(
                  controller: _scrollController,
                  itemCount: artists.length,
                  separatorBuilder: (context, index) =>
                      index != artists.length - 1
                          ? Divider(
                              indent: mediaQuery.size.width * (1 / 4),
                            )
                          : "",
                  itemBuilder: (context, index) {
                    final coverArt =
                        songProvider.artistCoverArt(artists[index]);
                    return Material(
                      color: ColorUtil.white,
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).pushNamed(
                              ArtistViewScreen.routeName,
                              arguments: {
                                "artist": artists[index],
                                "art": coverArt,
                              });
                        },
                        child: ListTile(
                          title: Text(
                            artists[index],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: CircleAvatar(
                            backgroundColor: ColorUtil.dark,
                            backgroundImage: DefaultUtil.checkNotAsset(coverArt)
                                ? FileImage(File(coverArt))
                                : AssetImage(coverArt),
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
        Consumer<AudioPlayer>(
          builder: (context, value, child) => value.miniPlayerPresent
              ? SizedBox(
                  height: 73,
                )
              : Container(),
        ),
      ],
    );
  }
}
