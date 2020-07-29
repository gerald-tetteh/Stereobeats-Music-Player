import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../provider/songItem.dart';

class CustomDropDown extends StatefulWidget {
  final List<SongItem> songs;
  final ItemScrollController controller;

  CustomDropDown(this.songs, this.controller);

  @override
  _CustomDropDownState createState() => _CustomDropDownState();
}

class _CustomDropDownState extends State<CustomDropDown> {
  int findSongPosition(String value) {
    return widget.songs
        .indexWhere((song) => song.title[0].toUpperCase() == value);
  }

  String _selectedValue;
  @override
  Widget build(BuildContext context) {
    const alphabets = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
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
