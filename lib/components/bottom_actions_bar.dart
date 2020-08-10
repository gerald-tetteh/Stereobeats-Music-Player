import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../provider/songItem.dart';
import '../provider/music_player.dart';
import '../pages/add_to_page.dart';
import '../components/toast.dart';

import 'alert_dialog.dart';
import 'change_playlist_name.dart';

class BottomActionsBar extends StatelessWidget {
  BottomActionsBar({
    this.deleteFunction,
    this.scaffoldKey,
    this.playListDelete,
    this.renameFunction,
  });
  final void Function(String, List<String>) playListDelete;
  final void Function(String, String, String) renameFunction;
  final void Function() deleteFunction;
  final GlobalKey<ScaffoldState> scaffoldKey;
  List<BottomNavigationBarItem> _items = <BottomNavigationBarItem>[
    BottomNavigationBarItem(
      icon: Icon(Icons.play_arrow),
      title: Text("Play"),
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.add),
      title: Text("Add"),
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.share),
      title: Text("Share"),
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.delete),
      title: Text("Delete"),
    ),
  ];
  final renamePlaylistOption = BottomNavigationBarItem(
    icon: Icon(Icons.edit_outlined),
    title: Text("Rename"),
  );
  @override
  Widget build(BuildContext context) {
    if (renameFunction != null) {
      _items.add(renamePlaylistOption);
    }
    final songProvider = Provider.of<SongProvider>(context, listen: false);
    final audioProvider = Provider.of<AudioPlayer>(context, listen: false);
    final fToast = FToast(scaffoldKey.currentContext);
    return BottomNavigationBar(
      onTap: (value) async {
        if (value == 0) {
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
                await Navigator.of(context).pushNamed(AddToPage.routeName);
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
                return ConfirmDeleteAlert(
                  playListDelete: playListDelete,
                  songProvider: songProvider,
                  deleteFunction: deleteFunction,
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
      selectedItemColor: Colors.grey[700],
      unselectedItemColor: Colors.grey[700],
      selectedFontSize: 15,
      unselectedFontSize: 15,
    );
  }
}
