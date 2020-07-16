// import 'dart:typed_data';
// import 'dart:convert';

import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../utils/default_util.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:stereo_beats_main/helpers/db_helper.dart';
// import 'package:flutter_file_meta_data/flutter_file_meta_data.dart';
// import 'package:storage_path/storage_path.dart';
// import 'package:uuid/uuid.dart';

class SongItem {
  final String title;
  final String artist;
  final String album;
  final String albumArtist;
  final String albumId;
  final String year;
  final String dateAdded;
  final String duration;
  final String path;

  SongItem({
    this.album,
    this.albumArtist,
    this.artist,
    this.dateAdded,
    this.duration,
    this.albumId,
    this.title,
    this.year,
    this.path,
  });
}

class SongProvider with ChangeNotifier {
  List<SongItem> _songs = [];

  List<SongItem> get songs {
    return [..._songs];
  }

  List<SongItem> get songsFraction {
    var currentYear = DateTime.now().year;
    var songs = _songs
        .where((element) =>
            DefaultUtil.checkNotNull(element.year) &&
            (currentYear - int.parse(element.year) < 2))
        .toList();
    return songs;
  }

  Future<String> getAlbumArt(String id) async {
    const platform = MethodChannel("stereo.beats/metadata");
    final path =
        await platform.invokeMethod("getAlbumArt", {"id": id}) as String;
    return path;
  }

  Future<void> getSongs() async {
    const platform = MethodChannel("stereo.beats/metadata");
    final songList =
        await platform.invokeMethod("getDeviceAudio") as List<dynamic>;
    _songs = songList
        .map(
          (song) => SongItem(
            title: song["title"],
            album: song["album"],
            albumArtist: song["albumArtist"],
            albumId: song["albumId"],
            artist: song["artist"],
            dateAdded: song["dateAdded"],
            duration: song["duration"],
            year: song["year"],
            path: song["path"],
          ),
        )
        .toList();
  }
}
