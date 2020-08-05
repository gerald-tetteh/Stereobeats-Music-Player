import 'package:flutter/material.dart';

import '../provider/songItem.dart';

class ConfirmDeleteAlert extends StatelessWidget {
  const ConfirmDeleteAlert({
    Key key,
    @required this.deleteFunction,
    @required this.songProvider,
  }) : super(key: key);

  final void Function() deleteFunction;
  final SongProvider songProvider;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Are you sure ?"),
      content: Text("Do you want to remove selected items ?"),
      actions: [
        FlatButton(
          child: Text("No"),
          onPressed: () => Navigator.of(context).pop(),
        ),
        FlatButton(
          child: Text("Yes"),
          onPressed: () {
            deleteFunction();
            songProvider.changeBottomBar(false);
            songProvider.setQueueToNull();
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
