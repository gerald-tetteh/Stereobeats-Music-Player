/*
 * Author: Gerald Addo-Tetteh
 * Stereo Beats Music Player for Android mobile devices.
 * Addo Develop
 * Email: addodevelop@gmail.com
 * Bottom Actions Bar (Component)
*/

/*
  The bottom actions bar is shown when the user
  presses on an item for a long time.
  This bar presents the user with options to delete
  songs, rename playlists or add them to a collection.

  It is available on most screens in the app.
  It is animated in using an animated container.

  Depending on the screen diffrent functions for options sunch
  as delete are passed to this widget.

  The delete option could simply remove an item from a playlist or
  remove the song from the device file permanently.
*/

// imports

// package imports
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

// lib file imports
import '../provider/songItem.dart';
import '../provider/theme_mode.dart';
import '../provider/music_player.dart';
import '../pages/add_to_page.dart';
import '../components/toast.dart';
import '../utils/color_util.dart';

import 'alert_dialog.dart';
import 'change_playlist_name.dart';

class BottomActionsBar extends StatelessWidget {
  BottomActionsBar({
    this.deleteFunction,
    this.scaffoldKey,
    this.playListDelete,
    this.renameFunction,
    this.playListDeleteSingle,
    this.playlistName,
  });
  final void Function(String, List<String>) playListDelete;
  final void Function(String, String, List<String>) playListDeleteSingle;
  final void Function(String, String, String) renameFunction;
  final void Function() deleteFunction;
  final String playlistName;
  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<AppThemeMode>(context, listen: false);

    // the buttons shown on the bottom bar
    List<BottomNavigationBarItem> _items = <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: Icon(
          Icons.play_arrow,
          color: themeProvider.isDarkMode ? ColorUtil.purple : null,
        ),
        label: "Play",
      ),
      BottomNavigationBarItem(
        icon: Icon(
          Icons.add,
          color: themeProvider.isDarkMode ? ColorUtil.purple : null,
        ),
        label: "Add",
      ),
      BottomNavigationBarItem(
        icon: Icon(
          Icons.share,
          color: themeProvider.isDarkMode ? ColorUtil.purple : null,
        ),
        label: "Share",
      ),
      BottomNavigationBarItem(
        icon: Icon(
          Icons.delete,
          color: themeProvider.isDarkMode ? ColorUtil.purple : null,
        ),
        label: "Delete",
      ),
    ];
    // this option is only visible on the playlist page
    final renamePlaylistOption = BottomNavigationBarItem(
      icon: Icon(
        Icons.edit_outlined,
        color: themeProvider.isDarkMode ? ColorUtil.purple : null,
      ),
      label: "Rename",
    );

    if (renameFunction != null) {
      _items.add(renamePlaylistOption);
    }
    final songProvider = Provider.of<SongProvider>(context, listen: false);
    final audioProvider = Provider.of<AudioPlayer>(context, listen: false);
    final fToast = FToast(scaffoldKey.currentContext);
    return BottomNavigationBar(
      backgroundColor: themeProvider.isDarkMode ? ColorUtil.dark2 : null,
      onTap: (value) async {
        if (value == 0) {
          // the functions only work when the user has selected an item
          if (songProvider.queueNotNull()) {
            audioProvider.play(songProvider.queue, 0, false);
            audioProvider.setShuffle(false);
            songProvider.changeBottomBar(false);
            songProvider.setQueueToNull();
            songProvider.setKeysToNull();
          }
        } else if (value == 1) {
          if (songProvider.queueNotNull()) {
            var result =
                await Navigator.of(context).pushNamed(AddToPage.routeName) ??
                    false;
            if (result) {
              // creats a toast to show action was completed
              fToast.showToast(
                child: ToastComponent(
                  color: Colors.green[100],
                  icon: Icons.check,
                  message: "Item Added",
                  iconColor: Colors.green[200],
                ),
                gravity: ToastGravity.BOTTOM,
                toastDuration: Duration(seconds: 3),
              );
            }
          }
        } else if (value == 2) {
          if (songProvider.queueNotNull()) {
            await songProvider.shareFile();
            songProvider.changeBottomBar(false);
            songProvider.setQueueToNull();
            songProvider.setKeysToNull();
          }
        } else if (value == 3) {
          if (songProvider.queueNotNull() || songProvider.keysNotNull()) {
            var value = await showDialog<bool>(
              barrierDismissible: false,
              context: scaffoldKey.currentContext,
              builder: (context) {
                // displays a dialog box to warn the user before deleting
                return ConfirmDeleteAlert(
                  playListDelete: playListDelete,
                  songProvider: songProvider,
                  deleteFunction: deleteFunction,
                  playListDeleteSingle: playListDeleteSingle,
                  playlistName: playlistName,
                );
              },
            );
            if (value) {
              fToast.showToast(
                child: ToastComponent(
                  color: Colors.green[100],
                  icon: Icons.check,
                  message: "Item(s) removed",
                  iconColor: Colors.green[200],
                ),
                gravity: ToastGravity.BOTTOM,
                toastDuration: Duration(seconds: 3),
              );
            }
          }
        } else if (value == 4) {
          if (songProvider.keysNotNull() && songProvider.keys.length == 1) {
            // displays a modal sheet with a text field to change the
            // playlist name
            await showModalBottomSheet(
              context: scaffoldKey.currentContext,
              builder: (ctx) {
                return ChangePlaylistName(
                  songProvider: songProvider,
                  renameFunction: renameFunction,
                );
              },
            );
            songProvider.changeBottomBar(false);
            songProvider.setQueueToNull();
            songProvider.setKeysToNull();
          } else if (songProvider.keys.length > 1) {
            fToast.showToast(
              child: ToastComponent(
                color: Colors.redAccent,
                icon: Icons.cancel_outlined,
                message: "Select only one item to rename",
                iconColor: Colors.red,
              ),
              gravity: ToastGravity.BOTTOM,
              toastDuration: Duration(seconds: 3),
            );
          }
        }
      },
      items: _items,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      selectedIconTheme: IconThemeData(
        color: Colors.grey[700],
      ),
      selectedItemColor:
          themeProvider.isDarkMode ? ColorUtil.white : Colors.grey[700],
      unselectedItemColor:
          themeProvider.isDarkMode ? ColorUtil.white : Colors.grey[700],
      selectedFontSize: 15,
      unselectedFontSize: 15,
    );
  }
}
