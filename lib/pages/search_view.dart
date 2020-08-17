/*
  * Author: Gerald Addo-Tetteh
  * StereoBeats Music Player
  * Search View
*/

//imports

// package imports
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// local imports
import '../provider/songItem.dart';
import '../provider/music_player.dart';
import '../utils/color_util.dart';
import '../utils/text_util.dart';
import '../utils/default_util.dart';
import '../components/box_image.dart';
import '../models/album.dart';

import 'artist_view_page.dart';
import 'album_detail_screen.dart';
import 'search_view_more.dart';

enum ListType { Songs, Albums, Artists }

class SearchView extends StatefulWidget {
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
  AudioPlayer player;

  @override
  void initState() {
    _controller = TextEditingController();
    _songs = [];
    _albums = [];
    _artists = [];
    songProvider = Provider.of<SongProvider>(context, listen: false);
    player = Provider.of<AudioPlayer>(context, listen: false);
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
    var appBar = AppBar(
      backgroundColor: ColorUtil.dark,
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
          icon: Icon(Icons.search_outlined),
          onPressed: () {},
        ),
      ],
    );
    var appBarHeight = appBar.preferredSize.height;
    var actualHeight = viewHeight - (extrapadding + appBarHeight);
    return Scaffold(
      backgroundColor: ColorUtil.white,
      appBar: appBar,
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

  void _submit(SongProvider provider, String text) {
    print(text);
    var results = provider.search(text.trim());
    _songs = results["songs"];
    _artists = results["artists"];
    _albums = results["albums"];
    setState(() {});
  }

  String getArtPath(Album album) {
    return album.paths
        .firstWhere(
          (song) => song.artPath != null && song.artPath.length != 0,
          orElse: () => SongItem(artPath: DefaultUtil.defaultImage),
        )
        .artPath;
  }

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
            color: ColorUtil.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                child: Text(
                  title,
                  style: TextUtil.subHeading,
                ),
              ),
              Divider(),
              _listType(type, context),
              if (items.length > 10)
                FlatButton(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Colors.blue,
                    ),
                    child: Text(
                      "View More +${items.length - 10}",
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pushNamed(
                    SearchViewMore.routeName,
                    arguments: {
                      "title": title,
                      "widget": _listType(type, context, true),
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _listType(ListType type, BuildContext context, [bool all = false]) {
    switch (type) {
      case ListType.Songs:
        return _buildSongList(context, all);
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

  Widget _buildSongList(BuildContext context, bool all) {
    List<dynamic> songs;
    if (_songs.length > 10 && !all) {
      songs = _songs.sublist(0, 5);
    } else {
      songs = _songs;
    }
    return Expanded(
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: songs.length,
        itemBuilder: (context, index) {
          return Material(
            color: ColorUtil.white,
            child: InkWell(
              onTap: () => player.play(songs, index),
              child: ListTile(
                leading: BoxImage(
                  path: songs[index] != null ? songs[index].artPath : null,
                ),
                title: Text(
                  songs[index] != null
                      ? songs[index].title
                      : DefaultUtil.unknown,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  DefaultUtil.checkNotNull(songs[index]?.artist)
                      ? songs[index].artist
                      : DefaultUtil.unknown,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

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
          final cover = songProvider.artistCoverArt(artists[index]);
          return Material(
            color: ColorUtil.white,
            child: InkWell(
              onTap: () => Navigator.of(context)
                  .pushNamed(ArtistViewScreen.routeName, arguments: {
                "artist": artists[index] as String,
                "art": cover,
              }),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: ColorUtil.dark,
                  backgroundImage: DefaultUtil.checkNotAsset(cover)
                      ? FileImage(File(cover))
                      : AssetImage(cover),
                ),
                title: Text(
                  artists[index] != null ? artists[index] : DefaultUtil.unknown,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

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
          final cover = getArtPath(albums[index]);
          return Material(
            color: ColorUtil.white,
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
                      : AssetImage(cover),
                ),
                title: Text(
                  albums[index] != null
                      ? albums[index].toString()
                      : DefaultUtil.unknown,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  albums[index] != null
                      ? albums[index].albumArtist
                      : DefaultUtil.unknown,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
