/*
 * Author: Gerald Addo-Tetteh
 * Stereo Beats Music Player for Android mobile devices.
 * Addo Develop
 * Email: addodevelop@gmail.com
 * Artist View Page
*/

/// This page shows all songs and albums
/// that have been produced by a particular artist.

// imports
// package imports
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';

// lib file imports
import '../components/mini_player.dart';
import '../provider/songItem.dart';
import '../provider/music_player.dart';
import '../provider/theme_mode.dart';
import '../utils/default_util.dart';
import '../utils/text_util.dart';
import '../utils/color_util.dart';
import '../pages/album_detail_screen.dart';
import '../components/circular_image.dart';

import 'play_page.dart';

class ArtistViewScreen extends StatelessWidget {
  /// name of route
  static const routeName = "/artist-view-page";

  @override
  Widget build(BuildContext context) {
    AssetsAudioPlayer.addNotificationOpenAction((notification) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        PlayMusicScreen.routeName,
        (route) => route.isFirst,
      );
      return true;
    });
    /*
      This screen requires data from the previous 
      route to build.
      It receives the name of the artist and the
      image associated with the artist
    */
    final parameters =
        ModalRoute.of(context)!.settings.arguments as Map<String, ArtistModel>;
    final artist = parameters["artist"];
    final songProvider = Provider.of<SongProvider>(context);
    final player = Provider.of<AudioPlayer>(context, listen: false);
    final themeProvider = Provider.of<AppThemeMode>(context, listen: false);
    final mediaQuery = MediaQuery.of(context);
    final viewHeight = mediaQuery.size.height;
    final extraPadding = mediaQuery.padding.top;
    final _appBar = AppBar(
      iconTheme: Theme.of(context).iconTheme,
      title: Text(
        artist!.artist,
        style: TextUtil.artistAppBar.copyWith(
          color: themeProvider.isDarkMode ? ColorUtil.white : null,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
    );
    final appBarHeight = _appBar.preferredSize.height;
    final actualHeight = viewHeight - (extraPadding + appBarHeight);
    final artistSongs = songProvider.getArtistSongs(artist.artist);
    final artistAlbums = songProvider.getArtistAlbums(artist.artist);
    return Scaffold(
      backgroundColor:
          themeProvider.isDarkMode ? ColorUtil.dark2 : Color(0xffeeeeee),
      appBar: _appBar,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Column(
            children: [
              Container(
                constraints: BoxConstraints(
                  maxHeight: actualHeight * 1 / 5,
                ),
                height: actualHeight * 1 / 5,
                width: mediaQuery.size.width * 0.5,
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Hero(
                    tag: artist,
                    child: Container(
                      child: QueryArtworkWidget(
                        id: artist.id,
                        type: ArtworkType.ARTIST,
                        artworkFit: BoxFit.cover,
                        artworkBorder: BorderRadius.circular(25),
                        nullArtworkWidget: Image.asset(
                          DefaultUtil.defaultImage,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(5, 10, 5, 0),
                  decoration: BoxDecoration(
                    color: themeProvider.isDarkMode
                        ? ColorUtil.dark
                        : ColorUtil.white,
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
                    /*
                      This widgets creates a scroll views
                      which contains the artist cover image,
                      the artist songs and albums. 
                    */
                    child: CustomScrollView(
                      slivers: [
                        _buildSubHeading(
                          artistSongs.length,
                          "Songs",
                          themeProvider,
                        ),
                        _buildSongsList(
                          player,
                          artistSongs,
                          themeProvider,
                        ),
                        _buildSubHeading(
                          artistAlbums.length,
                          "Albums",
                          themeProvider,
                        ),
                        _buildAlbumList(
                          artistAlbums,
                          context,
                          themeProvider,
                        ),
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
            // shows the mini player if present
            child: MiniPlayer(mediaQuery: mediaQuery),
          ),
        ],
      ),
    );
  }

  /// Creates a space beneath the custom scroll view to prevent
  /// the mini player from obstructing it.
  SliverList _extraSpace() {
    return SliverList(
      delegate: SliverChildListDelegate.fixed([SizedBox(height: 73)]),
    );
  }

  /// builds the list of all albums that were made by the
  /// artist provided
  SliverList _buildAlbumList(List<AlbumModel> artistAlbums,
      BuildContext context, AppThemeMode themeProvider) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext ctx, int index) {
          return Material(
            color: themeProvider.isDarkMode ? ColorUtil.dark : ColorUtil.white,
            child: InkWell(
              onTap: () => Navigator.of(context).pushNamed(
                AlbumDetailScreen.routeName,
                arguments: artistAlbums[index],
              ),
              child: ListTile(
                leading: CircularImage(
                  albumId: artistAlbums[index].id,
                  songId: -1,
                  artistId: -1,
                ),
                title: Text(
                  artistAlbums[index].album,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      themeProvider.isDarkMode ? TextUtil.allSongsTitle : null,
                ),
                subtitle: Text(
                  "Tracks: ${artistAlbums[index].numOfSongs}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      themeProvider.isDarkMode ? TextUtil.allSongsArtist : null,
                ),
              ),
            ),
          );
        },
        childCount: artistAlbums.length,
      ),
    );
  }

  /// builds the list of all songs that were made by the
  /// artist provided
  SliverList _buildSongsList(
    AudioPlayer player,
    List<SongItem> artistSongs,
    AppThemeMode themeProvider,
  ) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext ctx, int index) {
          return Material(
            color: themeProvider.isDarkMode ? ColorUtil.dark : ColorUtil.white,
            child: InkWell(
              onTap: () => player.play(artistSongs, index),
              child: ListTile(
                leading: CircularImage(
                  albumId: artistSongs[index].albumId,
                  songId: -1,
                  artistId: -1,
                ),
                title: Text(
                  DefaultUtil.checkNotNull(artistSongs[index].title)
                      ? artistSongs[index].title!
                      : DefaultUtil.unknown,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      themeProvider.isDarkMode ? TextUtil.allSongsTitle : null,
                ),
                subtitle: Text(
                  DefaultUtil.checkNotNull(artistSongs[index].album)
                      ? artistSongs[index].album!
                      : DefaultUtil.unknown,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      themeProvider.isDarkMode ? TextUtil.allSongsArtist : null,
                ),
              ),
            ),
          );
        },
        childCount: artistSongs.length,
      ),
    );
  }

  /// build a heading to identify different sections
  SliverList _buildSubHeading(
    int length,
    String title,
    AppThemeMode themeProvider,
  ) {
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
                  style: TextUtil.subHeading.copyWith(
                    color: themeProvider.isDarkMode ? ColorUtil.darkTeal : null,
                  ),
                ),
                Divider(
                  color: themeProvider.isDarkMode
                      ? ColorUtil.white
                      : ColorUtil.dark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
