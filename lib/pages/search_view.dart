/*
  * Author: Gerald Addo-Tetteh
  * StereoBeats Music Player
  * Search View
*/

//imports

// package imports
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// local imports
import '../provider/songItem.dart';
import '../utils/color_util.dart';
import '../utils/text_util.dart';
import '../utils/default_util.dart';
import '../components/box_image.dart';

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

  @override
  void initState() {
    _controller = TextEditingController();
    _songs = [];
    _albums = [];
    _artists = [];
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final songProvider = Provider.of<SongProvider>(context, listen: false);
    var mediaQuery = MediaQuery.of(context);
    var viewHeight = mediaQuery.size.height;
    var extrapadding = mediaQuery.padding.top;
    var appBar = AppBar(
      iconTheme: Theme.of(context).iconTheme,
      title: TextField(
        controller: _controller,
        maxLines: 1,
        decoration: InputDecoration(
          hintText: "Search song, album or artist",
          border: InputBorder.none,
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
              _buildSearchResults("Songs", _songs, ListType.Songs),
              _buildSearchResults("Songs", _albums, ListType.Albums),
              _buildSearchResults("Songs", _artists, ListType.Artists),
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

  Widget _buildSearchResults(String title, List<dynamic> items, ListType type) {
    if (items.length == 0) {
      return Container();
    }
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
              child: Text(
                title,
                style: TextUtil.subHeading,
              ),
            ),
            Divider(),
            _listType(type),
            items.length > 10
                ? FlatButton(
                    child: Text(
                      "View More +${items.length - 10}",
                    ),
                    onPressed: () {},
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  Widget _listType(ListType type) {
    switch (type) {
      case ListType.Songs:
        return _buildSongList();
        break;
      case ListType.Albums:
        return Container();
        break;
      case ListType.Artists:
        return Container();
        break;
      default:
        return Container();
        break;
    }
  }

  Expanded _buildSongList() {
    List<dynamic> songs;
    if (_songs.length > 10) {
      songs = _songs.sublist(0, 10);
    } else {
      songs = _songs;
    }
    return Expanded(
      child: ListView.builder(
        itemCount: songs.length,
        itemBuilder: (context, index) {
          return Material(
            color: ColorUtil.white,
            child: InkWell(
              child: ListTile(
                leading: BoxImage(
                  path: songs[index] != null ? songs[index].artPath : null,
                ),
                title: Text(
                  songs[index] != null
                      ? songs[index].title
                      : DefaultUtil.unknown,
                ),
                subtitle: Text(
                  DefaultUtil.checkNotNull(songs[index]?.artist)
                      ? songs[index].artist
                      : DefaultUtil.unknown,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
