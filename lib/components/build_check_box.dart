import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:circular_check_box/circular_check_box.dart';

import '../provider/songItem.dart';

class BuildCheckBox extends StatefulWidget {
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
        setState(() => _boxValue = value);
      },
    );
  }
}
