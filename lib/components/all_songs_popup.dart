/*
  * Author: Gerald Addo-Tetteh
  * StereoBeats Main
  * AllSongsPopUp
*/

// imports
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../provider/songItem.dart';
import '../provider/music_player.dart';
import '../pages/add_to_page.dart';
import '../pages/song_detail_page.dart';

import 'alert_dialog.dart';
import 'toast.dart';

class AllSongsPopUp extends StatelessWidget {
  AllSongsPopUp({
    @required this.index,
    @required this.song,
    @required this.songs,
    @required this.scaffoldKey,
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
  final _items = _menuItems
      .map((item) => PopupMenuItem<String>(
            value: item,
            child: Text(item),
          ))
      .toList();
  @override
  Widget build(BuildContext context) {
    final player = Provider.of<AudioPlayer>(context, listen: false);
    final songProvider = Provider.of<SongProvider>(context, listen: false);
    final fToast = FToast(scaffoldKey.currentContext);
    return PopupMenuButton<String>(
      itemBuilder: (context) => _items,
      onSelected: (String value) async {
        if (value == _menuItems[0]) {
          player.play(songs, index);
        } else if (value == _menuItems[1]) {
          songProvider.addToQueue(song.path);
          var value = await showDialog<bool>(
            barrierDismissible: false,
            context: scaffoldKey.currentContext,
            builder: (context) {
              return ConfirmDeleteAlert(
                deleteFunction: songProvider.deleteSongs,
                songProvider: songProvider,
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
          } else {
            songProvider.setQueueToNull();
          }
        } else if (value == _menuItems[2]) {
          songProvider.addToQueue(song.path);
          var result =
              await Navigator.of(context).pushNamed(AddToPage.routeName) ??
                  false;
          if (result) {
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
          songProvider.addToQueue(song.path);
          songProvider.shareFile();
          songProvider.setQueueToNull();
        }
      },
    );
  }
}
