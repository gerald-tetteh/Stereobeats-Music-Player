/*
 * Author: Gerald Addo-Tetteh
 * Stereo Beats Music Player for Android mobile devices.
 * Addo Develop
 * Email: addodevelop@gmail.com
 * Add to Playlist Page
*/

/*
  This screen shows all songs on the device
  that can be added to the current playlist.
  a circular check box on the left of each list
  tile is used to select the song and store it in 
  _queue.
*/

// imports

// package imports
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// lib file imports
import '../utils/text_util.dart';
import '../utils/color_util.dart';
import '../utils/default_util.dart';
import '../provider/songItem.dart';
import '../provider/theme_mode.dart';
import '../components/build_check_box.dart';

import 'play_page.dart';

class AddToPlayListPage extends StatelessWidget {
  // name of route
  static const routeName = "/add_to_playlist";
  @override
  Widget build(BuildContext context) {
    AssetsAudioPlayer.addNotificationOpenAction((notification) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        PlayMusicScreen.routeName,
        (route) => route.isFirst,
      );
      return true;
    });
    final songProvider = Provider.of<SongProvider>(context, listen: false);
    final themeProvider = Provider.of<AppThemeMode>(context, listen: false);
    final songs = songProvider.songs;
    return Scaffold(
      backgroundColor:
          themeProvider.isDarkMode ? ColorUtil.dark : ColorUtil.white,
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme,
        backgroundColor:
            themeProvider.isDarkMode ? ColorUtil.dark2 : Color(0xffeeeeee),
        title: Text(
          "Add To Playlist",
          style: TextStyle(
            color: themeProvider.isDarkMode ? ColorUtil.white : Colors.black,
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
      // if there are no songs on the device the empty
      // widget is retured instead.
      body: songs != null && songs.length != 0
          ? _buildSongList(songs, themeProvider)
          : DefaultUtil.empty("No songs found..."),
    );
  }

  ListView _buildSongList(List<SongItem> songs, AppThemeMode themeProvider) {
    return ListView.builder(
      itemCount: songs.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: BuildCheckBox(
            path: songs[index].path,
          ),
          title: Text(
            DefaultUtil.checkNotNull(songs[index].title)
                ? songs[index].title!
                : DefaultUtil.unknown,
            style: themeProvider.isDarkMode ? TextUtil.allSongsTitle : null,
          ),
          subtitle: Text(
            DefaultUtil.checkNotNull(songs[index].artist)
                ? songs[index].artist!
                : DefaultUtil.unknown,
            style: themeProvider.isDarkMode ? TextUtil.allSongsArtist : null,
          ),
        );
      },
    );
  }
}
