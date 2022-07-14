/*
 * Author: Gerald Addo-Tetteh
 * Stereo Beats Music Player for Android mobile devices.
 * Addo Develop
 * Email: addodevelop@gmail.com
 * Alert Dialog (Component)
*/

/*
  This widget returns a dialog box to warn the 
  user about a decision they are about to make.
  Eg: deleting a file
*/

//imports

// package imports
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// lib file imports
import '../provider/songItem.dart';
import '../provider/theme_mode.dart';
import '../utils/color_util.dart';
import '../utils/text_util.dart';

class ConfirmDeleteAlert extends StatelessWidget {
  const ConfirmDeleteAlert({
    Key? key,
    this.deleteFunction,
    required this.songProvider,
    this.playListDelete,
    this.playListDeleteSingle,
    this.playlistName,
  }) : super(key: key);

  final void Function()? deleteFunction;
  final void Function(String, List<String>)? playListDelete;
  final void Function(String, String, List<String>)? playListDeleteSingle;
  final SongProvider songProvider;
  final String? playlistName;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<AppThemeMode>(context, listen: false);
    return AlertDialog(
      backgroundColor: themeProvider.isDarkMode ? ColorUtil.dark : null,
      title: Text(
        "Are you sure ?",
        style: themeProvider.isDarkMode ? TextUtil.allSongsTitle : null,
      ),
      content: Text(
        "Do you want to remove selected items ?",
        style: themeProvider.isDarkMode ? TextUtil.allSongsTitle : null,
      ),
      actions: [
        TextButton(
          child: Text(
            "No",
            style: themeProvider.isDarkMode ? TextUtil.addPlaylistForm : null,
          ),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        TextButton(
          child: Text(
            "Yes",
            style: themeProvider.isDarkMode ? TextUtil.addPlaylistForm : null,
          ),
          onPressed: () {
            if (deleteFunction != null) {
              deleteFunction!();
            } else if (playListDeleteSingle != null) {
              playListDeleteSingle!(
                  "playLists", playlistName!, songProvider.queuePath);
            } else {
              playListDelete!("playLists", songProvider.keys);
            }
            songProvider.changeBottomBar(false);
            songProvider.setQueueToNull();
            songProvider.setKeysToNull();
            Navigator.of(context).pop(true);
          },
        ),
      ],
    );
  }
}
