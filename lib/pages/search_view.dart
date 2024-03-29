/*
 * Author: Gerald Addo-Tetteh
 * Stereo Beats Music Player for Android mobile devices.
 * Addo Develop
 * Email: addodevelop@gmail.com
 * Search View
*/

/// The search view searches for song, albums and artists that
/// match the input string. The results are rendered in a single
/// child scroll view.

//imports

// package imports
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';

// lib file imports
import '../provider/songItem.dart';
import '../provider/music_player.dart';
import '../provider/theme_mode.dart';
import '../utils/color_util.dart';
import '../utils/text_util.dart';
import '../components/build_check_box.dart';
import '../components/circular_image.dart';

import 'artist_view_page.dart';
import 'album_detail_screen.dart';
import 'search_view_more.dart';

// enum to determine type of data
enum ListType { Songs, Albums, Artists }

class SearchView extends StatefulWidget {
  // name of route
  static const routeName = "/search-view";
  @override
  _SearchView createState() => _SearchView();
}

class _SearchView extends State<SearchView> {
  TextEditingController? _controller;
  List<SongItem>? _songs;
  List<AlbumModel>? _albums;
  List<ArtistModel>? _artists;
  late SongProvider songProvider;
  late AppThemeMode themeProvider;
  late AudioPlayer player;

  @override
  void initState() {
    _controller = TextEditingController();
    _songs = [];
    _albums = [];
    _artists = [];
    songProvider = Provider.of<SongProvider>(context, listen: false);
    player = Provider.of<AudioPlayer>(context, listen: false);
    themeProvider =
        Provider.of<AppThemeMode>(context, listen: false); // audio player
    super.initState();
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    var viewHeight = mediaQuery.size.height;
    var extraPadding = mediaQuery.padding.top;
    /*
      The appBar contains a TextField that is used
      to receive user input.
    */
    var appBar = AppBar(
      backgroundColor:
          themeProvider.isDarkMode ? ColorUtil.dark2 : ColorUtil.dark,
      iconTheme: Theme.of(context).iconTheme,
      title: TextField(
        style: TextUtil.search,
        controller: _controller,
        maxLines: 1,
        decoration: InputDecoration(
          hintText: "Search song, album or artist",
          border: InputBorder.none,
          hintStyle: TextUtil.search,
        ),
        autofocus: true,
        onChanged: (value) => _submit(songProvider, value),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.cancel_outlined),
          onPressed: () => _controller!.clear(),
        ),
      ],
    );
    var appBarHeight = appBar.preferredSize.height;
    var actualHeight = viewHeight - (extraPadding + appBarHeight);
    return Scaffold(
      backgroundColor:
          themeProvider.isDarkMode ? ColorUtil.dark : ColorUtil.white,
      appBar: appBar,
      /*
        The single child scroll view consists of  
        three other lists that are used to show the results
        of the search => songs, albums, artists in that order.
      */
      body: SingleChildScrollView(
        child: Container(
          height: actualHeight,
          child: Column(
            children: [
              _buildSearchResults(
                "Songs",
                _songs!,
                ListType.Songs,
                context,
              ),
              _buildSearchResults(
                "Albums",
                _albums!,
                ListType.Albums,
                context,
              ),
              _buildSearchResults(
                "Artists",
                _artists!,
                ListType.Artists,
                context,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /*
    This method is called every time the user types in the
    search box.
    Its searches through the list of SongItems to find the ones 
    that match the users input.
  */
  void _submit(SongProvider provider, String text) {
    var results = provider.search(text.trim());
    _songs = results["songs"] as List<SongItem>;
    _artists = results["artists"] as List<ArtistModel>;
    _albums = results["albums"] as List<AlbumModel>;
    setState(() {});
  }

  // builds results list
  Widget _buildSearchResults(
    String title,
    List<dynamic> items,
    ListType type,
    BuildContext context,
  ) {
    if (items.length == 0) {
      return Container();
    }
    return Expanded(
      child: Card(
        margin: const EdgeInsets.all(10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        child: Container(
          height: items.length * 80.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: themeProvider.isDarkMode ? ColorUtil.dark2 : ColorUtil.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                child: Text(
                  title,
                  style: TextUtil.subHeading.copyWith(
                    color: themeProvider.isDarkMode ? ColorUtil.darkTeal : null,
                  ),
                ),
              ),
              Divider(
                color: themeProvider.isDarkMode ? ColorUtil.darkTeal : null,
              ),
              _listType(type, context),
              if (items.length > 10)
                TextButton(
                  child: Text(
                    "View More +${items.length - 10}",
                    style: themeProvider.isDarkMode
                        ? TextUtil.allSongsTitle
                        : null,
                  ),
                  onPressed: () async {
                    await Navigator.of(context).pushNamed(
                      SearchViewMore.routeName,
                      arguments: {
                        "title": title,
                        "widget": _listType(type, context, true, true),
                      },
                    );
                    songProvider.changeBottomBar(false);
                    songProvider.setQueueToNull();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  /*
   This method determines how the results of the search should be 
   shown.
  */
  Widget _listType(ListType type, BuildContext context,
      [bool all = false, bool selectable = false]) {
    switch (type) {
      case ListType.Songs:
        return _buildSongList(context, all, selectable);
      case ListType.Albums:
        return _buildAlbumList(context, all);
      case ListType.Artists:
        return _buildArtistList(context, all);
      default:
        return Container();
    }
  }

  // builds a list of all songs that match the users search
  Widget _buildSongList(
    BuildContext context,
    bool all,
    bool selectable,
  ) {
    late List<SongItem> songs;
    /*
      Depending on th current context the full list of results
      or a portion of it is shown.
    */
    if (_songs!.length > 10 && !all) {
      songs = (_songs as List<SongItem>).sublist(0, 5);
    } else {
      songs = _songs as List<SongItem>;
    }
    return Consumer<SongProvider>(
      builder: (context, provider, child) {
        return Expanded(
          child: GestureDetector(
            onTap: provider.showBottomBar && selectable
                ? () {
                    provider.changeBottomBar(false);
                    provider.setQueueToNull();
                  }
                : null,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: songs.length,
              itemBuilder: (context, index) {
                return Material(
                  color: themeProvider.isDarkMode
                      ? ColorUtil.dark2
                      : ColorUtil.white,
                  child: InkWell(
                    onTap: () => player.play(songs, index),
                    onLongPress: selectable
                        ? () => provider.changeBottomBar(true)
                        : null,
                    child: GestureDetector(
                      onTap: provider.showBottomBar && selectable
                          ? () {
                              provider.changeBottomBar(false);
                              provider.setQueueToNull();
                            }
                          : null,
                      child: ListTile(
                        leading: CircularImage(
                          albumId: -1,
                          songId: songs[index].songId,
                        ),
                        title: Text(
                          songs[index].title!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: themeProvider.isDarkMode
                              ? TextUtil.allSongsTitle
                              : null,
                        ),
                        subtitle: Text(
                          songs[index].artist!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: themeProvider.isDarkMode
                              ? TextUtil.allSongsTitle
                              : null,
                        ),
                        trailing: provider.showBottomBar && selectable
                            ? BuildCheckBox(
                                path: songs[index].path,
                              )
                            : null,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  // build a list of all artists that match the users input
  Widget _buildArtistList(BuildContext context, bool all) {
    late List<ArtistModel> artists;
    if (_artists!.length > 10 && !all) {
      artists = _artists!.sublist(0, 10);
    } else {
      artists = _artists!;
    }
    return Expanded(
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: artists.length,
        itemBuilder: (context, index) {
          return Material(
            color: themeProvider.isDarkMode ? ColorUtil.dark2 : ColorUtil.white,
            child: InkWell(
              onTap: () => Navigator.of(context)
                  .pushNamed(ArtistViewScreen.routeName, arguments: {
                "artist": artists[index],
              }),
              child: ListTile(
                leading: CircularImage(
                  albumId: -1,
                  songId: -1,
                  artistId: artists[index].id,
                ),
                title: Text(
                  artists[index].artist,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      themeProvider.isDarkMode ? TextUtil.allSongsTitle : null,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // builds a list of albums that match the users input
  Widget _buildAlbumList(BuildContext context, bool all) {
    late List<AlbumModel> albums;
    if (_albums!.length > 10 && !all) {
      albums = _albums!.sublist(0, 10);
    } else {
      albums = _albums!;
    }
    return Expanded(
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: albums.length,
        itemBuilder: (context, index) {
          return Material(
            color: themeProvider.isDarkMode ? ColorUtil.dark2 : ColorUtil.white,
            child: InkWell(
              onTap: () => Navigator.of(context).pushNamed(
                AlbumDetailScreen.routeName,
                arguments: albums[index],
              ),
              child: ListTile(
                leading: CircularImage(
                  albumId: albums[index].id,
                  songId: -1,
                  artistId: -1,
                ),
                title: Text(
                  albums[index].album,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      themeProvider.isDarkMode ? TextUtil.allSongsTitle : null,
                ),
                subtitle: Text(
                  albums[index].artist!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      themeProvider.isDarkMode ? TextUtil.allSongsTitle : null,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
