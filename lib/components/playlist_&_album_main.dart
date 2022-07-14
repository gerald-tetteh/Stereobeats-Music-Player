/*
 * Author: Gerald Addo-Tetteh
 * Stereo Beats Music Player for Android mobile devices.
 * Addo Develop
 * Email: addodevelop@gmail.com
 * Playlist & Album Main template (Component)
*/

/*
  This page is a template for the playlist and album 
  screens. The screens for both types are similar.
*/

// imports

// package imports
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';

// file imports
import '../pages/album_detail_screen.dart';
import '../models/playlist.dart';
import '../models/album.dart';
import '../provider/songItem.dart';
import '../provider/theme_mode.dart';
import '../utils/text_util.dart';
import '../utils/default_util.dart';
import '../utils/color_util.dart';
import '../pages/playlist_detail_screen.dart';

import 'build_check_box.dart';
import './circular_image.dart';

// enum to determine data type
enum Purpose { PlayListView, AlbumView }

class PlayListAndAlbum extends StatelessWidget {
  final String? title;
  final String? subTitle;
  final List<AlbumModel>? albums;
  final Purpose? purpose;

  PlayListAndAlbum({
    this.title,
    this.subTitle,
    this.albums,
    this.purpose,
  });

  /// this method returns the path of each song
  /// in the album
  List<String> albumPaths(Album album) {
    return album.paths!.map((song) => song.path!).toList();
  }

  /// This method deselectes all selected items.
  ///
  void _resetActions(SongProvider songProvider) {
    songProvider.changeBottomBar(false);
    songProvider.setQueueToNull();
    songProvider.setKeysToNull();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final songProvider = Provider.of<SongProvider>(context, listen: false);
    final themeProvider = Provider.of<AppThemeMode>(context, listen: false);
    /*
      creates a space beneath the list to prevent
      the mini player from obstructing it.
    */
    var extraSpace = Container(
      color: themeProvider.isDarkMode ? ColorUtil.dark : ColorUtil.white,
      height: 73,
    );
    /* 
      builds either the playlist view or album 
      view depending on the purpose.
    */
    if (purpose == Purpose.PlayListView) {
      return PageDefaults(
        title: title,
        subTitle: subTitle,
        extraSpace: extraSpace,
        themeProvider: themeProvider,
        child: _buildPlayList(mediaQuery, songProvider, themeProvider),
      );
    } else {
      return PageDefaults(
        title: title,
        subTitle: subTitle,
        extraSpace: extraSpace,
        themeProvider: themeProvider,
        isAlbum: true,
        child: _buildAlbumList(mediaQuery, songProvider, themeProvider),
      );
    }
  }

  /// returns the album list
  Widget _buildAlbumList(MediaQueryData mediaQuery, SongProvider songProvider,
      AppThemeMode themeProvider) {
    if (albums!.length == 0) {
      return themeProvider.isDarkMode
          ? DefaultUtil.emptyDarkMode("No Albums yet..")
          : DefaultUtil.empty("No Albums yet..");
    }
    return _listBuilder(
      songProvider: songProvider,
      isPlaylist: false,
      items: albums!,
      mediaQuery: mediaQuery,
      themeProvider: themeProvider,
    );
  }

  /// returns the playlist view
  Widget _buildPlayList(MediaQueryData mediaQuery, SongProvider songProvider,
      AppThemeMode themeProvider) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<PlayList>("playLists").listenable(),
      builder: (context, Box<PlayList> box, child) {
        var playLists = box.values.toList();
        if (playLists.length == 0) {
          return themeProvider.isDarkMode
              ? DefaultUtil.emptyDarkMode(
                  "No playlists yet..", "Click on purple icon (top most right)")
              : DefaultUtil.empty(
                  "No playlists yet..", "Click on blue icon (top right)");
        }
        return _listBuilder(
          songProvider: songProvider,
          mediaQuery: mediaQuery,
          items: playLists,
          themeProvider: themeProvider,
        );
      },
    );
  }

  /// This Method returns a list of items.
  /// Either all the playlists or all the albums.
  GestureDetector _listBuilder({
    SongProvider? songProvider,
    MediaQueryData? mediaQuery,
    bool isPlaylist = true,
    required AppThemeMode themeProvider,
    required List<dynamic> items,
  }) {
    final _scrollController = ScrollController();
    return GestureDetector(
      onTap: () {
        songProvider!.changeBottomBar(false);
        songProvider.setQueueToNull();
        songProvider.setKeysToNull();
      },
      child: DraggableScrollbar.semicircle(
        backgroundColor:
            themeProvider.isDarkMode ? ColorUtil.dark2 : Colors.white,
        controller: _scrollController,
        child: ListView.separated(
          controller: _scrollController,
          separatorBuilder: (context, index) => index != items.length - 1
              ? Divider(
                  endIndent: mediaQuery!.size.width * (1 / 4),
                )
              : "" as Widget,
          itemCount: items.length,
          itemBuilder: (context, index) {
            SongItem? listSong;

            if (isPlaylist &&
                items[index].paths != null &&
                items[index].paths.length > 0) {
              listSong =
                  songProvider!.getSongFromPath(items[index].paths.toList()[0]);
            }
            return Material(
              color:
                  themeProvider.isDarkMode ? ColorUtil.dark : ColorUtil.white,
              child: InkWell(
                onTap: () async {
                  await Navigator.of(context).pushNamed(
                    isPlaylist
                        ? PlaylistDetailScreen.routeName
                        : AlbumDetailScreen.routeName,
                    arguments: items[index],
                  );
                  _resetActions(songProvider!);
                },
                onLongPress: isPlaylist
                    ? () => songProvider!.changeBottomBar(true)
                    : null,
                child: Consumer<SongProvider>(
                  builder: (context, songProvider1, child) {
                    return GestureDetector(
                      onTap: songProvider1.showBottomBar
                          ? () {
                              songProvider!.changeBottomBar(false);
                              songProvider.setQueueToNull();
                              songProvider.setKeysToNull();
                            }
                          : null,
                      child: ListTile(
                        leading: songProvider1.showBottomBar
                            ? isPlaylist
                                ? BuildCheckBox(
                                    paths: items[index].paths ?? [],
                                    playListName: items[index].toString(),
                                  )
                                : null
                            : null,
                        title: Text(
                          isPlaylist
                              ? items[index].toString()
                              : items[index].album,
                          style: isPlaylist
                              ? TextUtil.playlistCardTitle.copyWith(
                                  color: themeProvider.isDarkMode
                                      ? ColorUtil.white
                                      : null,
                                )
                              : TextUtil.albumTitle.copyWith(
                                  color: themeProvider.isDarkMode
                                      ? ColorUtil.white
                                      : null,
                                ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          isPlaylist
                              ? "Tracks: ${items[index].paths == null ? 0 : items[index].paths.length}"
                              : "Tracks: ${items[index].numOfSongs}",
                          style: themeProvider.isDarkMode
                              ? TextUtil.allSongsArtist
                              : null, // ensures null is not returned
                        ),
                        trailing: Hero(
                          tag: items[index].toString(),
                          child: CircularImage(
                            songId: listSong?.songId ?? -1,
                            albumId: listSong?.albumId ?? -1,
                            artistId: !isPlaylist ? items[index]?.artistId : -1,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/*
  This widget returns a column with the page name 
  and some layout options that are common to both 
  the playlist and album view.
*/
class PageDefaults extends StatelessWidget {
  const PageDefaults({
    Key? key,
    required this.title,
    required this.subTitle,
    required this.extraSpace,
    required this.child,
    required this.themeProvider,
    this.isAlbum = false,
  }) : super(key: key);

  final String? title;
  final String? subTitle;
  final Container extraSpace;
  final Widget child;
  final AppThemeMode themeProvider;
  final bool isAlbum;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(
            title!,
            style: TextUtil.pageHeadingTop.copyWith(
              color: themeProvider.isDarkMode ? ColorUtil.white : null,
            ),
          ),
          subtitle: Text(
            subTitle!,
            style: themeProvider.isDarkMode ? TextUtil.pageIntroSub : null,
          ),
          trailing: Icon(
            isAlbum ? Icons.album_outlined : Icons.library_music_outlined,
            color: themeProvider.isDarkMode ? ColorUtil.darkTeal : null,
          ),
        ),
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color:
                  themeProvider.isDarkMode ? ColorUtil.dark : ColorUtil.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: child,
          ),
        ),
        extraSpace,
      ],
    );
  }
}
