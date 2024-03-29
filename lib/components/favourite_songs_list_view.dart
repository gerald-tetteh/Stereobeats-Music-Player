/*
 * Author: Gerald Addo-Tetteh
 * Stereo Beats Music Player for Android mobile devices.
 * Addo Develop
 * Email: addodevelop@gmail.com
 * Favourites Songs List View (Component)
*/

/*
  This Widget returns a list of all the users favourite songs.
*/

// imports

// package imports
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// lib file imports
import '../provider/songItem.dart';
import '../provider/music_player.dart';
import '../provider/theme_mode.dart';
import '../utils/default_util.dart';
import '../utils/color_util.dart';
import '../utils/text_util.dart';

import './build_check_box.dart';
import './circular_image.dart';

class FavouriteSongListView extends StatelessWidget {
  FavouriteSongListView({
    required this.favouriteSongs,
    required this.audioProvider,
  });

  final List<SongItem> favouriteSongs;
  final AudioPlayer audioProvider;

  @override
  Widget build(BuildContext context) {
    final songProvider = Provider.of<SongProvider>(context, listen: false);
    final themeProvider = Provider.of<AppThemeMode>(context, listen: false);
    return GestureDetector(
      onTap: () {
        songProvider.changeBottomBar(false);
        songProvider.setQueueToNull();
      },
      child: ListView.builder(
        itemCount: favouriteSongs.length,
        itemBuilder: (context, index) {
          final song = favouriteSongs[index];
          return Material(
            color: themeProvider.isDarkMode ? ColorUtil.dark : ColorUtil.white,
            child: InkWell(
              onTap: () {
                audioProvider.setShuffle(false);
                audioProvider.play(favouriteSongs, index);
              },
              onLongPress: () => songProvider.changeBottomBar(true),
              child: GestureDetector(
                onTap: songProvider.showBottomBar
                    ? () {
                        songProvider.changeBottomBar(false);
                        songProvider.setQueueToNull();
                      }
                    : null,
                child: ListTile(
                  leading: songProvider.showBottomBar
                      ? BuildCheckBox(path: song.path)
                      : null,
                  title: Text(
                    DefaultUtil.checkNotNull(song.title)
                        ? song.title!
                        : DefaultUtil.unknown,
                    overflow: TextOverflow.ellipsis,
                    style: themeProvider.isDarkMode
                        ? TextUtil.allSongsTitle
                        : null,
                  ),
                  subtitle: Text(
                    DefaultUtil.checkNotNull(song.artist)
                        ? song.artist!
                        : DefaultUtil.unknown,
                    overflow: TextOverflow.ellipsis,
                    style: themeProvider.isDarkMode
                        ? TextUtil.allSongsArtist
                        : null,
                  ),
                  trailing: CircularImage(
                    albumId: song.albumId,
                    songId: song.songId,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
