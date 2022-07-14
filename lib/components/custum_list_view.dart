/*
 * Author: Gerald Addo-Tetteh
 * Stereo Beats Music Player for Android mobile devices.
 * Addo Develop
 * Email: addodevelop@gmail.com
 * Custom List View (Component)
*/

/*
  This widget returns list title with :
  leading => BoxImage()
  title => song title
  subTitle => song artist

  Clicking on the list tile plays the song at that index.
*/

// imports

// package imports
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// lib file imports
import '../provider/songItem.dart';
import '../provider/theme_mode.dart';
import '../utils/default_util.dart';
import '../components/box_image.dart';
import '../provider/music_player.dart';
import '../utils/text_util.dart';

class CustomListView extends StatelessWidget {
  const CustomListView({
    Key? key,
    required this.song,
    required this.songs,
    required this.index,
  }) : super(key: key);

  final SongItem song;
  final int index;
  final List<SongItem> songs;

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<AppThemeMode>(context, listen: false);
    return ListTile(
      leading: BoxImage(
        albumId: song.albumId ?? -1,
        songId: song.songId ?? -1,
      ),
      title: Text(
        DefaultUtil.checkNotNull(song.title)
            ? song.title!
            : DefaultUtil.unknown,
        style: themeProvider.isDarkMode ? TextUtil.quickPickSongDetails : null,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        DefaultUtil.checkNotNull(song.artist)
            ? song.artist!
            : DefaultUtil.unknown,
        style: themeProvider.isDarkMode ? TextUtil.quickPickSongDetails : null,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () =>
          Provider.of<AudioPlayer>(context, listen: false).play(songs, index),
    );
  }
}
