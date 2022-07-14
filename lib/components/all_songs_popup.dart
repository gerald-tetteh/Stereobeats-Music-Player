/*
 * Author: Gerald Addo-Tetteh
 * Stereo Beats Music Player for Android mobile devices.
 * Addo Develop
 * Email: addodevelop@gmail.com
 * All Songs PopUp (Component)
*/

/*
  This widget a PopUpMenu when show actions that could be 
  performed on the selected item.

  This is specific to the all songs page.
*/

// imports

// package imports
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:stereo_beats_main/utils/text_util.dart';

// lib file imports
import '../provider/songItem.dart';
import '../provider/music_player.dart';
import '../provider/theme_mode.dart';
import '../pages/add_to_page.dart';
import '../pages/song_detail_page.dart';
import '../utils/color_util.dart';

import 'alert_dialog.dart';
import 'toast.dart';

class AllSongsPopUp extends StatelessWidget {
  AllSongsPopUp({
    required this.index,
    required this.song,
    required this.songs,
    required this.scaffoldKey,
  });
  final List<SongItem> songs;
  final int index;
  final SongItem song;
  final GlobalKey<ScaffoldState> scaffoldKey;
  static const _menuItems = [
    "Play",
    "Delete",
    "Add To",
    "Details",
    "Share",
  ];
  // generates a list of popUpMenuItems
  @override
  Widget build(BuildContext context) {
    final player = Provider.of<AudioPlayer>(context, listen: false);
    final themeProvider = Provider.of<AppThemeMode>(context, listen: false);
    final songProvider = Provider.of<SongProvider>(context, listen: false);
    final _items = _menuItems
        .map((item) => PopupMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: themeProvider.isDarkMode ? TextUtil.allSongsPopUp : null,
              ),
            ))
        .toList();
    final fToast = FToast();
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        color:
            themeProvider.isDarkMode ? ColorUtil.darkTeal : ColorUtil.darkGrey,
      ),
      color: themeProvider.isDarkMode ? ColorUtil.dark : null,
      itemBuilder: (context) => _items,
      onSelected: (String value) async {
        if (value == _menuItems[0]) {
          player.play(songs, index);
        } else if (value == _menuItems[1]) {
          songProvider.addToQueue(song.path!);
          var value = await (showDialog<bool>(
            barrierDismissible: false,
            context: scaffoldKey.currentContext!,
            builder: (context) {
              return ConfirmDeleteAlert(
                deleteFunction: songProvider.deleteSongs,
                songProvider: songProvider,
              );
            },
          ) as Future<bool>);
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
          } else {
            songProvider.setQueueToNull();
          }
        } else if (value == _menuItems[2]) {
          songProvider.addToQueue(song.path!);
          var result =
              await Navigator.of(context).pushNamed(AddToPage.routeName) ??
                  false;
          if (result as bool) {
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
          } else {
            songProvider.setQueueToNull();
          }
        } else if (value == _menuItems[3]) {
          Navigator.of(context)
              .pushNamed(SongDetailPage.routeName, arguments: song.path);
        } else if (value == _menuItems[4]) {
          songProvider.addToQueue(song.path!);
          songProvider.shareFile();
          songProvider.setQueueToNull();
        }
      },
    );
  }
}
