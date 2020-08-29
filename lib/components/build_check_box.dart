/*
 * Author: Gerald Addo-Tetteh
 * Stereo Beats Music Player for Android mobile devices.
 * Addo Develop
 * Email: addodevelop@gmail.com
 * Build Check Box (Component)
*/

/*
  This widget creates a circular check box which is used to select items.
  Based on the item that is selected different data is passed to this widget
  so that it can perform functions specific to that item.
*/

// imports

// package imports
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:circular_check_box/circular_check_box.dart';

// lib file imports
import '../provider/songItem.dart';

class BuildCheckBox extends StatefulWidget {
  /*
    The parameters path & paths can not be non-null at the same
    time.
    PlayListName can be non-null at all times.
  */
  const BuildCheckBox({
    Key key,
    this.path,
    this.paths,
    this.playListName,
  }) : super(key: key);

  final String path;
  final List<String> paths;
  final String playListName;
  @override
  _BuildCheckBoxState createState() => _BuildCheckBoxState();
}

class _BuildCheckBoxState extends State<BuildCheckBox> {
  bool _boxValue = false;
  @override
  Widget build(BuildContext context) {
    final songProvider = Provider.of<SongProvider>(context, listen: false);
    return CircularCheckBox(
      value: _boxValue,
      onChanged: (value) {
        if (value) {
          if (widget.playListName != null) {
            songProvider.addToKeys(widget.playListName);
          }
          if (widget.path != null) {
            songProvider.addToQueue(widget.path);
          } else {
            songProvider.addListToQueue(widget.paths);
          }
        } else {
          if (widget.playListName != null) {
            songProvider.removeFromKeys(widget.playListName);
          }
          if (widget.path != null) {
            songProvider.removeFromQueue(widget.path);
          } else {
            songProvider.removeListFromQueue(widget.paths);
          }
        }
        // rebuilds the widget to reflect changes
        setState(() => _boxValue = value);
      },
    );
  }
}
