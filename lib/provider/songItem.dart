import 'dart:typed_data';
// import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:stereo_beats_main/helpers/db_helper.dart';
// import 'package:flutter_file_meta_data/flutter_file_meta_data.dart';
// import 'package:storage_path/storage_path.dart';
import 'package:uuid/uuid.dart';

class SongItem {
  final String title;
  final String artist;
  final String album;
  final String albumArtist;
  final Uint8List albumArt;
  final String year;
  final String dateAdded;
  final String duration;
  final String id;

  SongItem({
    this.album,
    this.albumArtist,
    this.artist,
    this.dateAdded,
    this.duration,
    this.albumArt,
    this.title,
    this.year,
    this.id,
  });
}

class SongProvider with ChangeNotifier {
  List<SongItem> _songs = [];

  List<SongItem> get songs {
    return [..._songs];
  }

  Map<dynamic, dynamic> song;

  final uuid = Uuid();

  Future<String> getAlbumArt(String id) async {
    const platform = MethodChannel("stereo.beats/metadata");
    final path =
        await platform.invokeMethod("getAlbumArt", {"id": id}) as String;
    print(path);
    return path;
  }

  Future<void> getSongs() async {
    const platform = MethodChannel("stereo.beats/metadata");
    final songList =
        await platform.invokeMethod("getDeviceAudio") as List<dynamic>;
    // final artPaths = await getAlbumArt();
    print(songList.length);
    print(songList[0]);
    print(songList[1]);
    print(songList[2]);
    print(songList[20]);
    print(songList[40]);
    print(songList[500]);
    print(songList[30]);
    // print(artPaths[0]);
    // print(artPaths[10]);
    // print(artPaths);
    song = songList[20];
  }

  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   if (prefs.getInt("data") == null) {
  //     var dataString = await StoragePath.audioPath;
  //     var songLocations = json.decode(dataString) as List<dynamic>;
  //     const platform = MethodChannel("stereo.beats/metadata");

  //     try {
  //       for (int i = 0; i < songLocations.length; i++) {
  //         var folder = songLocations[i] as Map<String, dynamic>;
  //         var files = folder["files"] as List<dynamic>;
  //         for (int i = 0; i < files.length; i++) {
  //           final audioData = await platform
  //                   .invokeMethod("getMetadata", {"song": files[i]["path"]})
  //               as Map<dynamic, dynamic>;
  //           _songs.add(
  //             SongItem(
  //               id: uuid.v4(),
  //               title: audioData["title"],
  //               album: audioData["album"],
  //               albumArtist: audioData["albumArtist"],
  //               duration: audioData["duration"],
  //               year: audioData["year"],
  //               dateAdded: audioData["dateAdded"],
  //               artist: audioData["artist"],
  //               albumArt: audioData["albumArt"],
  //             ),
  //           );
  //         }
  //       }
  //     } on PlatformException catch (e) {
  //       throw e;
  //     }
  //   } else {
  //     try {
  //       final readSongs = await DBHelper.getData("allSongs");
  //       readSongs.forEach((element) {
  //         _songs.add(
  //           SongItem(
  //             id: uuid.v4(),
  //             title: element["title"],
  //             album: element["album"],
  //             albumArtist: element["albumArtist"],
  //             duration: element["duration"],
  //             year: element["year"],
  //             dateAdded: element["dateAdded"],
  //             artist: element["artist"],
  //             albumArt: element["albumArt"],
  //           ),
  //         );
  //       });
  //     } catch (e) {
  //       throw e;
  //     }
  //   }
  // }

  // Future<void> initailSave() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   if (prefs.getInt("data") != null) {
  //     return;
  //   }
  //   _songs.forEach((song) {
  //     DBHelper.insert("allSongs", {
  //       "title": song.title,
  //       "album": song.album,
  //       "artist": song.artist,
  //       "albumArt": song.albumArt,
  //       "year": song.year,
  //       "duration": song.duration,
  //       "dateAdded": song.dateAdded,
  //       "albumArtist": song.albumArtist,
  //       "id": song.id,
  //     });
  //   });
  //   prefs.setInt("data", 1);
  // }
}
