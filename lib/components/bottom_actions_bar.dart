import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/songItem.dart';
import '../provider/music_player.dart';

class BottomActionsBar extends StatelessWidget {
  BottomActionsBar(
    this.deleteFunction,
  );
  final void Function() deleteFunction;
  final _items = <BottomNavigationBarItem>[
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
  @override
  Widget build(BuildContext context) {
    final songProvider = Provider.of<SongProvider>(context, listen: false);
    final audioProvider = Provider.of<AudioPlayer>(context, listen: false);
    return BottomNavigationBar(
      onTap: (value) {
        if (value == 0) {
          if (songProvider.queueNotNull()) {
            audioProvider.play(songProvider.queue, 0, false);
            audioProvider.setShuffle(false);
            songProvider.changeBottomBar(false);
            songProvider.setQueueToNull();
          }
        } else if (value == 3) {
          if (songProvider.queueNotNull()) {
            deleteFunction();
            songProvider.changeBottomBar(false);
            songProvider.setQueueToNull();
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
