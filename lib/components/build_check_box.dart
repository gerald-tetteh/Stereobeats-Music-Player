import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:circular_check_box/circular_check_box.dart';

import '../provider/songItem.dart';

class BuildCheckBox extends StatefulWidget {
  const BuildCheckBox({
    Key key,
    @required this.path,
  }) : super(key: key);

  final String path;
  @override
  _BuildCheckBoxState createState() => _BuildCheckBoxState();
}

class _BuildCheckBoxState extends State<BuildCheckBox> {
  bool _boxValue = false;
  @override
  Widget build(BuildContext context) {
    final songProvider = Provider.of<SongProvider>(context);
    return CircularCheckBox(
      value: _boxValue,
      onChanged: (value) {
        if (value) {
          songProvider.addToQueue(widget.path);
        } else {
          songProvider.removeFromQueue(widget.path);
        }
        setState(() => _boxValue = value);
      },
    );
  }
}
