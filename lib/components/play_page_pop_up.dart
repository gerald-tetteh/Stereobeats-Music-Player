/*
 * Author: Gerald Addo-Tetteh
 * Stereo Beats Music Player for Android mobile devices.
 * Addo Develop
 * Email: addodevelop@gmail.com
 * Play Page PopUp (Component)
*/

/*
  This widget opens a pop up 
  menu when it is clicked. The menu
  contains options open the equalizer,
  view song details and share the song.
*/

// imports

// package imports
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// lib file imports
import '../pages/song_detail_page.dart';
import '../provider/songItem.dart';
import '../provider/music_player.dart';
import '../provider/theme_mode.dart';
import '../utils/color_util.dart';
import '../utils/text_util.dart';

class PlayPagePopUp extends StatelessWidget {
  final AudioPlayer audioProvider;
  final SongProvider songProvider;

  final _menuItemsText = [
    "Equalizer",
    "Details",
    "Share",
  ];

  PlayPagePopUp({
    required this.audioProvider,
    required this.songProvider,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<AppThemeMode>(context, listen: false);
    final _menuItems = [
      ListTile(
        leading: Icon(
          Icons.equalizer_sharp,
          color:
              themeProvider.isDarkMode ? ColorUtil.darkTeal : Color(0xff1565c0),
        ),
        title: Text(
          _menuItemsText[0],
          style: themeProvider.isDarkMode ? TextUtil.allSongsTitle : null,
        ),
      ),
      ListTile(
        leading: Icon(
          Icons.notes_outlined,
          color:
              themeProvider.isDarkMode ? ColorUtil.darkTeal : Color(0xff1565c0),
        ),
        title: Text(
          _menuItemsText[1],
          style: themeProvider.isDarkMode ? TextUtil.allSongsTitle : null,
        ),
      ),
      ListTile(
        leading: Icon(
          Icons.share,
          color:
              themeProvider.isDarkMode ? ColorUtil.darkTeal : Color(0xff1565c0),
        ),
        title: Text(
          _menuItemsText[2],
          style: themeProvider.isDarkMode ? TextUtil.allSongsTitle : null,
        ),
      ),
    ];
    // creats the menu items with the list tile above.
    final _items = _menuItems.map((item) {
      var textWidget = item.title as Text;
      return PopupMenuItem<String>(
        value: textWidget.data,
        child: item,
      );
    }).toList();
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        color: themeProvider.isDarkMode ? ColorUtil.purple : Color(0xff1565c0),
      ),
      color: themeProvider.isDarkMode ? ColorUtil.dark : ColorUtil.white,
      itemBuilder: (context) => _items,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      onSelected: (value) async {
        var path = audioProvider.playing.path;
        if (value == _menuItemsText[0]) {
          print("show equalizer");
        } else if (value == _menuItemsText[1]) {
          Navigator.of(context)
              .pushNamed(SongDetailPage.routeName, arguments: path);
        } else if (value == _menuItemsText[2]) {
          songProvider.addToQueue(path);
          await songProvider.shareFile();
          songProvider.setQueueToNull();
        }
      },
    );
  }
}
