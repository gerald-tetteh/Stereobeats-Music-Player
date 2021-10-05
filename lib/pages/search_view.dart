/*
 * Author: Gerald Addo-Tetteh
 * Stereo Beats Music Player for Android mobile devices.
 * Addo Develop
 * Email: addodevelop@gmail.com
 * Search View
*/

/*
  The search view serches for song, albums and artists that 
  match the input string. The reults are renderend in a single
  child scroll view.
*/

//imports

// package imports
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// lib file imports
import '../provider/songItem.dart';
import '../provider/music_player.dart';
import '../provider/theme_mode.dart';
import '../utils/color_util.dart';
import '../utils/text_util.dart';
import '../utils/default_util.dart';
import '../components/build_check_box.dart';
import '../models/album.dart';

import 'artist_view_page.dart';
import 'album_detail_screen.dart';
import 'search_view_more.dart';

// eneum to determine type of data
enum ListType { Songs, Albums, Artists }

class SearchView extends StatefulWidget {
  // name of route
  static const routeName = "/search-view";
  @override
  _SearchViewState createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  TextEditingController _controller;
  List<dynamic> _songs;
  List<dynamic> _albums;
  List<dynamic> _artists;
  SongProvider songProvider;
  AppThemeMode themeProvider;
  AudioPlayer player;

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
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    var viewHeight = mediaQuery.size.height;
    var extrapadding = mediaQuery.padding.top;
    /*
      The appBar contains a TextField that is used
      to recieve user input.
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
          onPressed: () => _controller.clear(),
        ),
      ],
    );
    var appBarHeight = appBar.preferredSize.height;
    var actualHeight = viewHeight - (extrapadding + appBarHeight);
    return Scaffold(
      backgroundColor:
          themeProvider.isDarkMode ? ColorUtil.dark : ColorUtil.white,
      appBar: appBar,
      /*
        The single child scroll view consists of  
        three other lists that are used to show the results
        of the search => songs, albums, artsis in that order.
      */
      body: SingleChildScrollView(
        child: Container(
          height: actualHeight,
          child: Column(
            children: [
              _buildSearchResults(
                "Songs",
                _songs,
                ListType.Songs,
                context,
              ),
              _buildSearchResults(
                "Albums",
                _albums,
                ListType.Albums,
                context,
              ),
              _buildSearchResults(
                "Artists",
                _artists,
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
    This method is called everytime the user types in the
    search box.
    Its serches through the list of SongItems to find the ones 
    that match the users input.
  */
  void _submit(SongProvider provider, String text) {
    var results = provider.search(text.trim());
    _songs = results["songs"];
    _artists = results["artists"];
    _albums = results["albums"];
    setState(() {});
  }

  /*
    This methods finds the album art that would be used 
    to identify an album
  */
  String getArtPath(Album album) {
    return album.paths
        .firstWhere(
          (song) => song.artPath != null && song.artPath.length != 0,
          orElse: () => SongItem(artPath: DefaultUtil.defaultImage),
        )
        .artPath;
  }

  Uint8List getArtPath2(Album album) {
    return album.paths
        .firstWhere(
          (song) => song.artPath2 != null && song.artPath2.length != 0,
          orElse: () => SongItem(artPath: DefaultUtil.defaultImage),
        )
        .artPath2;
  }

  // builds results list
  Widget _buildSearchResults(
      String title, List<dynamic> items, ListType type, BuildContext context) {
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
                FlatButton(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: themeProvider.isDarkMode
                          ? ColorUtil.purple
                          : Colors.blue,
                    ),
                    child: Text(
                      "View More +${items.length - 10}",
                      style: themeProvider.isDarkMode
                          ? TextUtil.allSongsTitle
                          : null,
                    ),
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
        break;
      case ListType.Albums:
        return _buildAlbumList(context, all);
        break;
      case ListType.Artists:
        return _buildArtistList(context, all);
        break;
      default:
        return Container();
        break;
    }
  }

  // builds a list of all songs that match the users search
  Widget _buildSongList(BuildContext context, bool all, bool selectable) {
    List<dynamic> songs;
    /*
      Depending on th current context the full list of results
      or a portion of it is shown.
    */
    if (_songs.length > 10 && !all) {
      songs = _songs.sublist(0, 5);
    } else {
      songs = _songs;
    }
    return Consumer<SongProvider>(
      builder: (context, provider, child) {
        return Expanded(
          child: GestureDetector(
            onTap: provider.showBottonBar && selectable
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
                      onTap: provider.showBottonBar && selectable
                          ? () {
                              provider.changeBottomBar(false);
                              provider.setQueueToNull();
                            }
                          : null,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: ColorUtil.dark,
                          backgroundImage:
                              DefaultUtil.checkNotNull(songs[index].artPath)
                                  ? FileImage(File(songs[index].artPath))
                                  : DefaultUtil.checkListNotNull(songs[index].artPath2) 
                                    ? MemoryImage(songs[index].artPath2) 
                                    : AssetImage(DefaultUtil.defaultImage),
                        ),
                        title: Text(
                          songs[index] != null
                              ? songs[index].title
                              : DefaultUtil.unknown,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: themeProvider.isDarkMode
                              ? TextUtil.allSongsTitle
                              : null,
                        ),
                        subtitle: Text(
                          DefaultUtil.checkNotNull(songs[index]?.artist)
                              ? songs[index].artist
                              : DefaultUtil.unknown,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: themeProvider.isDarkMode
                              ? TextUtil.allSongsTitle
                              : null,
                        ),
                        trailing: provider.showBottonBar && selectable
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
    List<dynamic> artists;
    if (_artists.length > 10 && !all) {
      artists = _artists.sublist(0, 10);
    } else {
      artists = _artists;
    }
    return Expanded(
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: artists.length,
        itemBuilder: (context, index) {
          String cover;
          final coverArt2 = songProvider.artistCoverArt2(artists[index]);
          if(coverArt2 == null || coverArt2.length < 1) {
            cover = songProvider.artistCoverArt(artists[index]);
          }
          return Material(
            color: themeProvider.isDarkMode ? ColorUtil.dark2 : ColorUtil.white,
            child: InkWell(
              onTap: () => Navigator.of(context)
                  .pushNamed(ArtistViewScreen.routeName, arguments: {
                "artist": artists[index] as String,
                "art": cover,
                "art2": coverArt2,
              }),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: ColorUtil.dark,
                  backgroundImage: DefaultUtil.checkNotAsset(cover)
                      ? FileImage(File(cover))
                      : DefaultUtil.checkListNotNull(coverArt2) 
                        ? MemoryImage(coverArt2) 
                        : AssetImage(cover),
                ),
                title: Text(
                  artists[index] != null ? artists[index] : DefaultUtil.unknown,
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
    List<dynamic> albums;
    if (_albums.length > 10 && !all) {
      albums = _albums.sublist(0, 10);
    } else {
      albums = _albums;
    }
    return Expanded(
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: albums.length,
        itemBuilder: (context, index) {
          String cover;
          final cover2 = getArtPath2(albums[index]);
          if(cover2 == null || cover2.length < 1) {
            cover = getArtPath(albums[index]);
          }
          return Material(
            color: themeProvider.isDarkMode ? ColorUtil.dark2 : ColorUtil.white,
            child: InkWell(
              onTap: () => Navigator.of(context).pushNamed(
                AlbumDetailScreen.routeName,
                arguments: albums[index],
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: ColorUtil.dark,
                  backgroundImage: DefaultUtil.checkNotAsset(cover)
                      ? FileImage(File(cover))
                      : DefaultUtil.checkListNotNull(cover2) 
                        ? MemoryImage(cover2) 
                        : AssetImage(cover),
                ),
                title: Text(
                  albums[index] != null
                      ? albums[index].toString()
                      : DefaultUtil.unknown,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      themeProvider.isDarkMode ? TextUtil.allSongsTitle : null,
                ),
                subtitle: Text(
                  albums[index] != null
                      ? albums[index].albumArtist
                      : DefaultUtil.unknown,
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
