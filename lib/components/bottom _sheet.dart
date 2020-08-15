import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// import '../provider/music_player.dart';
import '../helpers/db_helper.dart';
import '../provider/songItem.dart';
import '../pages/add_to_playlist.dart';

class ModalSheet extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  ModalSheet(this.formKey);

  @override
  _ModalSheetState createState() => _ModalSheetState();
}

class _ModalSheetState extends State<ModalSheet> {
  final keys = DBHelper.getkeys("playLists");

  String playListName;

  @override
  Widget build(BuildContext context) {
    final songProvider = Provider.of<SongProvider>(context, listen: false);
    // final audioProvider = Provider.of<AudioPlayer>(context, listen: false);
    final mediaQuery = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.only(
        bottom: mediaQuery.viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: widget.formKey,
              child: TextFormField(
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: "Playlist Name",
                ),
                validator: (value) {
                  if (keys.contains(value)) {
                    return "A Playlist with the name entered already exists";
                  } else if (value.isEmpty) {
                    return "Nothing was entered for this field";
                  }
                },
                onSaved: (newValue) {
                  playListName = newValue;
                },
              ),
            ),
          ),
          Row(
            children: [
              FlatButton.icon(
                label: Text("Add Songs"),
                icon: songProvider.queueNotNull()
                    ? Icon(Icons.check_box_rounded)
                    : Icon(Icons.check_box_outline_blank_rounded),
                onPressed: () async {
                  await Navigator.of(context)
                      .pushNamed(AddToPlayListPage.routeName);
                  setState(() {});
                },
              ),
              Spacer(),
              RaisedButton(
                child: Text("Submit"),
                color: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                onPressed: () {
                  _submit(songProvider);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _submit(SongProvider provider) {
    if (!widget.formKey.currentState.validate()) {
      return;
    }
    widget.formKey.currentState.save();
    print(provider.queuePath);
    DBHelper.createItem("playLists", playListName, provider.queuePath);
    Navigator.of(context).pop();
    provider.setQueueToNull();
  }
}
