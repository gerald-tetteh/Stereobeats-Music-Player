/*
 * Author: Gerald Addo-Tetteh
 * Stereo Beats Music Player for Android mobile devices.
 * Addo Develop
 * Email: addodevelop@gmail.com
 * Bottom Sheet (Component)
*/

/*
  This widget returns a column that contains a textfield to enter the 
  playlist name and a button to add songs to the playlist on creation.
  Finally the submit button.
*/

// imports

// package imports
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// lib file imports
// import '../provider/music_player.dart';
import '../helpers/db_helper.dart';
import '../provider/songItem.dart';
import '../provider/theme_mode.dart';
import '../utils/color_util.dart';
import '../utils/text_util.dart';
import '../pages/add_to_playlist.dart';
import '../extensions/string_extension.dart';

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
    final themeProvider = Provider.of<AppThemeMode>(context, listen: false);
    // final audioProvider = Provider.of<AudioPlayer>(context, listen: false);
    final mediaQuery = MediaQuery.of(context);
    return Container(
      color: themeProvider.isDarkMode ? ColorUtil.dark2 : null,
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
                style: themeProvider.isDarkMode ? TextUtil.allSongsTitle : null,
                decoration: InputDecoration(
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: themeProvider.isDarkMode
                          ? ColorUtil.purple
                          : Color(0xff000000),
                    ),
                  ),
                  labelText: "Playlist Name",
                  labelStyle: themeProvider.isDarkMode
                      ? TextUtil.addPlaylistForm
                      : null,
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
              /*
                The check box next to the button is filled
                when the user has selected songs to add to the playlist.
              */
              FlatButton.icon(
                label: Text(
                  "Add Songs",
                  style:
                      themeProvider.isDarkMode ? TextUtil.allSongsTitle : null,
                ),
                icon: songProvider.queueNotNull()
                    ? Icon(
                        Icons.check_box_rounded,
                        color:
                            themeProvider.isDarkMode ? ColorUtil.white : null,
                      )
                    : Icon(
                        Icons.check_box_outline_blank_rounded,
                        color:
                            themeProvider.isDarkMode ? ColorUtil.white : null,
                      ),
                onPressed: () async {
                  await Navigator.of(context)
                      .pushNamed(AddToPlayListPage.routeName);
                  setState(() {});
                },
              ),
              Spacer(),
              RaisedButton(
                child: Text(
                  "Submit",
                  style:
                      themeProvider.isDarkMode ? TextUtil.allSongsTitle : null,
                ),
                color:
                    themeProvider.isDarkMode ? ColorUtil.darkTeal : Colors.blue,
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

  /*
    The submit method checks if the name entered is valid 
    and call creatItem form the DBHelper.
  */
  void _submit(SongProvider provider) {
    if (!widget.formKey.currentState.validate()) {
      return;
    }
    widget.formKey.currentState.save();
    DBHelper.createItem(
        "playLists", playListName.trim().capitalize(), provider.queuePath);
    Navigator.of(context).pop();
    provider.setQueueToNull();
  }
}
