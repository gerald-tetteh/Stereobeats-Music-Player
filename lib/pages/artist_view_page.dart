/* 
 * Author: Gerald Addo-Tetteh
 * StereoBeats Music Player
 * Artist View Page
*/

// imports

import 'dart:io';

// package imports
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/box_image.dart';
import '../components/bottom_actions_bar.dart';
import '../components/customDrawer.dart';
import '../provider/songItem.dart';
import '../provider/music_player.dart';
import '../utils/default_util.dart';
import '../utils/text_util.dart';
import '../utils/color_util.dart';

class ArtistViewScreen extends StatelessWidget {
  static const routeName = "/artist-view-page";
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    final parameters =
        ModalRoute.of(context).settings.arguments as Map<String, String>;
    final artist = parameters["artist"];
    final coverArt = parameters["art"];
    final songProvider = Provider.of<SongProvider>(context);
    final player = Provider.of<AudioPlayer>(context, listen: false);
    final mediaQuery = MediaQuery.of(context);
    final viewHeight = mediaQuery.size.height;
    final extraPadding = mediaQuery.padding.top;
    final _appBar = AppBar(
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
    );
    final appBarHeight = _appBar.preferredSize.height;
    final actualheight = viewHeight - (extraPadding + appBarHeight);
    final artistSongs = songProvider.getArtistSongs(artist);
    final artistAlbums = songProvider.getArtistAlbums(artist);
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
      appBar: _appBar,
      body: Column(
        children: [
          Container(
            constraints: BoxConstraints(
              maxHeight: actualheight * 1 / 5,
            ),
            height: actualheight * 1 / 5,
            width: mediaQuery.size.width * 0.4,
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: DefaultUtil.checkNotAsset(coverArt)
                        ? FileImage(File(coverArt))
                        : AssetImage(coverArt),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ),
          Container(
            height: actualheight * 3 / 5,
            margin: const EdgeInsets.fromLTRB(5, 10, 5, 10),
            decoration: BoxDecoration(
              color: ColorUtil.white,
              borderRadius: BorderRadius.circular(35),
            ),
            child: Column(
              children: [
                _buildsubHeading(artistSongs.length, "Songs"),
                _buildSongsList(artistSongs, player),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Expanded _buildSongsList(List<SongItem> artistSongs, AudioPlayer player) {
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(35),
          bottomRight: Radius.circular(35),
        ),
        child: ListView.builder(
          itemCount: artistSongs.length,
          itemBuilder: (context, index) {
            return Material(
              color: ColorUtil.white,
              child: InkWell(
                onTap: () => player.play(artistSongs, index),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: ColorUtil.dark,
                    backgroundImage:
                        DefaultUtil.checkNotNull(artistSongs[index].artPath)
                            ? FileImage(File(artistSongs[index].artPath))
                            : AssetImage(DefaultUtil.defaultImage),
                  ),
                  title: Text(
                    DefaultUtil.checkNotNull(artistSongs[index].title)
                        ? artistSongs[index].title
                        : DefaultUtil.unknown,
                  ),
                  subtitle: Text(
                    DefaultUtil.checkNotNull(artistSongs[index].title)
                        ? artistSongs[index].title
                        : DefaultUtil.unknown,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Container _buildsubHeading(int length, String title) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      margin: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$title ($length)".toUpperCase(),
            style: TextUtil.subHeading,
          ),
          Divider(
            color: ColorUtil.dark,
          ),
        ],
      ),
    );
  }
}
