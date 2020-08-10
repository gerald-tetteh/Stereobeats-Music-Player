import 'package:flutter/material.dart';

import '../provider/songItem.dart';
import '../extensions/string_extension.dart';

class ChangePlaylistName extends StatefulWidget {
  final SongProvider songProvider;
  final void Function(String, String, String) renameFunction;
  ChangePlaylistName({
    this.songProvider,
    this.renameFunction,
  });
  @override
  _ChangePlaylistNameState createState() => _ChangePlaylistNameState();
}

class _ChangePlaylistNameState extends State<ChangePlaylistName> {
  TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    _controller.text = widget.songProvider.keys[0].trim().capitalize();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: "Playlist Name",
              contentPadding: const EdgeInsets.all(8),
            ),
          ),
          RaisedButton(
            color: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadiusDirectional.circular(20),
            ),
            onPressed: _submit,
            child: Text("Submit"),
          ),
        ],
      ),
    );
  }

  void _submit() {
    widget.renameFunction(
        "playLists", widget.songProvider.keys[0], _controller.text);
    Navigator.of(context).pop();
  }
}
