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

// lib file imports
import '../provider/songItem.dart';

class CustomDropDown extends StatefulWidget {
  final List<SongItem> songs;
  final ItemScrollController controller;

  CustomDropDown(this.songs, this.controller);

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
    const alphabets = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    // genarates a list from the string of alphabets
    List<DropdownMenuItem<String>> alphabetList = List.generate(
      alphabets.length,
      (index) => DropdownMenuItem<String>(
        child: Text(alphabets[index]),
        value: alphabets[index],
      ),
    );
    return DropdownButton(
      items: alphabetList,
      onChanged: ((String value) {
        widget.controller.jumpTo(index: findSongPosition(value));
        setState(() {
          _selectedValue = value;
        });
      }),
      value: _selectedValue,
      hint: Text("A-Z"),
    );
  }
}
