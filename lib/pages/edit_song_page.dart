/*
  * Author: Gerald Addo-Tetteh
  * StereoBeats Main
  * AllSongsPopUp
*/

// imports
import 'dart:io';

import 'package:flutter/material.dart';

import '../utils/text_util.dart';
import '../utils/color_util.dart';
import '../utils/default_util.dart';
import '../provider/songItem.dart';

class EditSongPage extends StatelessWidget {
  static const routeName = "/edit-song-page";
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _submit(SongProvider provider, Map<String, String> songDetails,
      BuildContext context) async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Row(
        children: [CircularProgressIndicator(), Text("Saving Changes...")],
      ),
      duration: Duration(minutes: 2),
    ));
    await provider.updateSong(songDetails);
    _scaffoldKey.currentState.removeCurrentSnackBar();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final parameters =
        ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
    final song = parameters["song"] as SongItem;
    final songProvider = parameters["songProvider"] as SongProvider;
    var songdDetails = {
      "title": DefaultUtil.checkNotNull(song.title)
          ? song.title
          : DefaultUtil.unknown,
      "artist": DefaultUtil.checkNotNull(song.artist)
          ? song.artist
          : DefaultUtil.unknown,
      "album": DefaultUtil.checkNotNull(song.album)
          ? song.album
          : DefaultUtil.unknown,
      "albumArtist": DefaultUtil.checkNotNull(song.albumArtist)
          ? song.albumArtist
          : DefaultUtil.unknown,
      "year":
          DefaultUtil.checkNotNull(song.year) ? song.year : DefaultUtil.unknown,
      "songId": song.songId,
    };
    var appBar = AppBar(
      backgroundColor: ColorUtil.dark,
      elevation: 0,
      iconTheme: Theme.of(context).iconTheme,
      title: Text(
        DefaultUtil.checkNotNull(song.title)
            ? "Edit: ${song.title}"
            : "Edit: ${DefaultUtil.unknown}",
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.save_outlined,
            size: TextUtil.medium,
          ),
          onPressed: () async =>
              await _submit(songProvider, songdDetails, context),
        ),
      ],
    );
    var mediaQuery = MediaQuery.of(context);
    var appBarHeight = appBar.preferredSize.height;
    var extraPadding = mediaQuery.padding.top;
    var viewHeight = mediaQuery.size.height;
    var actualHeight = viewHeight - (appBarHeight + extraPadding);
    return Scaffold(
      key: _scaffoldKey,
      appBar: appBar,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: actualHeight * 0.4,
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: DefaultUtil.checkNotNull(song.artPath)
                      ? FileImage(File(song.artPath))
                      : AssetImage(DefaultUtil.defaultImage),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
              ),
              child: Form(
                key: _formKey,
                child: Container(
                  height: actualHeight * 0.6,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        TextFormField(
                          initialValue: song.title ?? "",
                          decoration: InputDecoration(
                            labelText: "Title",
                            hintText: "Title",
                          ),
                          validator: (value) {
                            if (!(value is String)) {
                              return "Text not supported";
                            }
                          },
                          onSaved: (value) {
                            songdDetails["title"] =
                                DefaultUtil.checkNotNull(value.trim())
                                    ? value.trim()
                                    : DefaultUtil.unknown;
                          },
                        ),
                        TextFormField(
                          initialValue: song.artist ?? "",
                          decoration: InputDecoration(
                            labelText: "Artist",
                            hintText: "Artist",
                          ),
                          validator: (value) {
                            if (!(value is String)) {
                              return "Text not supported";
                            }
                          },
                          onSaved: (value) {
                            songdDetails["artist"] =
                                DefaultUtil.checkNotNull(value.trim())
                                    ? value.trim()
                                    : DefaultUtil.unknown;
                          },
                        ),
                        TextFormField(
                          initialValue: song.album ?? "",
                          decoration: InputDecoration(
                            labelText: "Album",
                            hintText: "Album",
                          ),
                          validator: (value) {
                            if (!(value is String)) {
                              return "Text not supported";
                            }
                          },
                          onSaved: (value) {
                            songdDetails["album"] =
                                DefaultUtil.checkNotNull(value.trim())
                                    ? value.trim()
                                    : DefaultUtil.unknown;
                          },
                        ),
                        TextFormField(
                          initialValue: song.albumArtist ?? "",
                          decoration: InputDecoration(
                            labelText: "Album Artist",
                            hintText: "Album Artist",
                          ),
                          validator: (value) {
                            if (!(value is String)) {
                              return "Text not supported";
                            }
                          },
                          onSaved: (value) {
                            songdDetails["albumArtist"] =
                                DefaultUtil.checkNotNull(value.trim())
                                    ? value.trim()
                                    : DefaultUtil.unknown;
                          },
                        ),
                        TextFormField(
                          initialValue: song.year ?? "",
                          decoration: InputDecoration(
                            labelText: "Year",
                            hintText: "Year",
                          ),
                          validator: (value) {
                            if (!(value is String)) {
                              return "Text not supported";
                            }
                          },
                          onSaved: (value) {
                            songdDetails["year"] =
                                DefaultUtil.checkNotNull(value.trim())
                                    ? value.trim()
                                    : DefaultUtil.unknown;
                          },
                        ),
                        RaisedButton(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                          ),
                          onPressed: () async => await _submit(
                              songProvider, songdDetails, context),
                          color: Colors.blue,
                          child: Text(
                            "Submit",
                            style: TextUtil.submitForm,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
