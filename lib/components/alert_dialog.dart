import 'package:flutter/material.dart';

import '../provider/songItem.dart';

class ConfirmDeleteAlert extends StatelessWidget {
  const ConfirmDeleteAlert({
    Key key,
    this.deleteFunction,
    @required this.songProvider,
    this.playListDelete,
  }) : super(key: key);

  final void Function() deleteFunction;
  final void Function(String, List<String>) playListDelete;
  final SongProvider songProvider;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Are you sure ?"),
      content: Text("Do you want to remove selected items ?"),
      actions: [
        FlatButton(
          child: Text("No"),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        FlatButton(
          child: Text("Yes"),
          onPressed: () {
            if (deleteFunction != null) {
              deleteFunction();
            } else {
              playListDelete("playLists", songProvider.keys);
            }
            songProvider.changeBottomBar(false);
            songProvider.setQueueToNull();
            songProvider.setKeysToNull();
            Navigator.of(context).pop(true);
          },
        ),
      ],
    );
  }
}
