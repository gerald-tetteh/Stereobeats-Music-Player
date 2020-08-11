import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/text_util.dart';
import '../utils/color_util.dart';
import '../utils/default_util.dart';
import '../provider/songItem.dart';
import '../components/build_check_box.dart';

class AddToPlayListPage extends StatelessWidget {
  static const routeName = "/add_to_playlist";
  @override
  Widget build(BuildContext context) {
    final songProvider = Provider.of<SongProvider>(context, listen: false);
    final songs = songProvider.songs;
    return Scaffold(
      backgroundColor: ColorUtil.white,
      appBar: AppBar(
        backgroundColor: Color(0xffeeeeee),
        title: Text(
          "Add To Playlist",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            size: TextUtil.medium,
          ),
          onPressed: () {
            songProvider.setQueueToNull();
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.save,
              size: TextUtil.medium,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: songs != null && songs.length != 0
          ? _buildSongList(songs)
          : DefaultUtil.empty("No songs found..."),
    );
  }

  ListView _buildSongList(List<SongItem> songs) {
    return ListView.builder(
      itemCount: songs.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: BuildCheckBox(
            path: songs[index].path,
          ),
          title: Text(
            DefaultUtil.checkNotNull(songs[index].title)
                ? songs[index].title
                : DefaultUtil.unknown,
          ),
          subtitle: Text(
            DefaultUtil.checkNotNull(songs[index].artist)
                ? songs[index].artist
                : DefaultUtil.unknown,
          ),
        );
      },
    );
  }
}
