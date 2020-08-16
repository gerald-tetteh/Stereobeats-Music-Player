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

import '../components/mini_player.dart';
import '../provider/songItem.dart';
import '../provider/music_player.dart';
import '../utils/default_util.dart';
import '../utils/text_util.dart';
import '../utils/color_util.dart';
import '../models/album.dart';
import '../pages/album_detail_screen.dart';

class ArtistViewScreen extends StatelessWidget {
  static const routeName = "/artist-view-page";
  String getArtPath(Album album) {
    return album.paths
        .firstWhere(
          (song) => song.artPath != null && song.artPath.length != 0,
          orElse: () => SongItem(artPath: DefaultUtil.defaultImage),
        )
        .artPath;
  }

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
      title: Text(
        artist,
        style: TextUtil.artistAppBar,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
    );
    final appBarHeight = _appBar.preferredSize.height;
    final actualheight = viewHeight - (extraPadding + appBarHeight);
    final artistSongs = songProvider.getArtistSongs(artist);
    final artistAlbums = songProvider.getArtistAlbums(artist);
    return Scaffold(
      backgroundColor: Color(0xffeeeeee),
      appBar: _appBar,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Column(
            children: [
              Container(
                constraints: BoxConstraints(
                  maxHeight: actualheight * 1 / 5,
                ),
                height: actualheight * 1 / 5,
                width: mediaQuery.size.width * 0.5,
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
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(5, 10, 5, 0),
                  decoration: BoxDecoration(
                    color: ColorUtil.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    child: CustomScrollView(
                      slivers: [
                        _buildsubHeading(artistSongs.length, "Songs"),
                        _buildSongsList(player, artistSongs),
                        _buildsubHeading(artistAlbums.length, "Albums"),
                        _buildAlbumList(artistAlbums, context),
                        _extraSpace(),
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

  Consumer<AudioPlayer> _extraSpace() {
    return Consumer<AudioPlayer>(
      builder: (context, value, child) => value.miniPlayerPresent
          ? SliverList(
              delegate: SliverChildListDelegate.fixed([SizedBox(height: 73)]),
            )
          : SliverList(delegate: SliverChildListDelegate([])),
    );
  }

  SliverList _buildAlbumList(List<Album> artistAlbums, BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext ctx, int index) {
          final artPath = getArtPath(artistAlbums[index]);
          return Material(
            color: ColorUtil.white,
            child: InkWell(
              onTap: () => Navigator.of(context).pushNamed(
                AlbumDetailScreen.routeName,
                arguments: artistAlbums[index],
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: ColorUtil.dark,
                  backgroundImage: DefaultUtil.checkNotAsset(artPath)
                      ? FileImage(File(artPath))
                      : AssetImage(artPath),
                ),
                title: Text(
                  DefaultUtil.checkNotNull(artistAlbums[index].name)
                      ? artistAlbums[index].name
                      : DefaultUtil.unknown,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  "Tracks: ${artistAlbums[index].paths != null ? artistAlbums[index].paths.length : 0}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          );
        },
        childCount: artistAlbums.length,
      ),
    );
  }

  SliverList _buildSongsList(AudioPlayer player, List<SongItem> artistSongs) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext ctx, int index) {
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  DefaultUtil.checkNotNull(artistSongs[index].album)
                      ? artistSongs[index].album
                      : DefaultUtil.unknown,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          );
        },
        childCount: artistSongs.length,
      ),
    );
  }

  SliverList _buildsubHeading(int length, String title) {
    return SliverList(
      delegate: SliverChildListDelegate.fixed(
        [
          Container(
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
          ),
        ],
      ),
    );
  }
}
