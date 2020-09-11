/*
 * Author: Gerald Addo-Tetteh
 * Stereo Beats Music Player for Android mobile devices.
 * Addo Develop
 * Email: addodevelop@gmail.com
 * Dropdown Menu (Component)
*/

/*
  This widget returns a dropdown list of the alphabets.
  Clicking on an alphabet would move the songs list view to the position
  of the first song whose title has the fisrt letter == alphabet.
*/

// imports

// package imports
import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:provider/provider.dart';
import 'package:stereo_beats_main/utils/color_util.dart';
import 'package:fluttertoast/fluttertoast.dart';

// lib file imports
import '../provider/songItem.dart';
import '../provider/theme_mode.dart';
import '../utils/text_util.dart';

import 'toast.dart';

class CustomDropDown extends StatefulWidget {
  final List<SongItem> songs;
  final ItemScrollController controller;
  final GlobalKey<ScaffoldState> scaffoldKey;

  CustomDropDown(this.songs, this.controller, this.scaffoldKey);

  @override
  _CustomDropDownState createState() => _CustomDropDownState();
}

class _CustomDropDownState extends State<CustomDropDown> {
  /*
    This methods finds the index of the first song 
    whose title has the first letter == input.
  */
  int findSongPosition(String value) {
    return widget.songs
        .indexWhere((song) => song.title[0].toUpperCase() == value);
  }

  String _selectedValue;
  @override
  Widget build(BuildContext context) {
    final fToast = FToast(widget.scaffoldKey.currentContext);
    var themeProvider = Provider.of<AppThemeMode>(context, listen: false);
    const alphabets = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    // genarates a list from the string of alphabets
    List<DropdownMenuItem<String>> alphabetList = List.generate(
      alphabets.length,
      (index) => DropdownMenuItem<String>(
        child: Text(
          alphabets[index],
          style: themeProvider.isDarkMode ? TextUtil.dropDownHint : null,
        ),
        value: alphabets[index],
      ),
    );
    return DropdownButton(
      dropdownColor: themeProvider.isDarkMode ? ColorUtil.dark : null,
      items: alphabetList,
      onChanged: ((String value) {
        var index = findSongPosition(value);
        if (index != -1) {
          widget.controller.jumpTo(index: findSongPosition(value));
          setState(() {
            _selectedValue = value;
          });
        } else {
          fToast.showToast(
            child: ToastComponent(
              color: Colors.amber,
              icon: Icons.not_interested,
              iconColor: Colors.yellow,
              message: "No song found...",
            ),
          );
        }
      }),
      value: _selectedValue,
      hint: Text(
        "A-Z",
        style: themeProvider.isDarkMode ? TextUtil.dropDownHint : null,
      ),
    );
  }
}
