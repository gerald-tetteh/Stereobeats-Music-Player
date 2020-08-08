import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  String artPath;

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
    this.artPath,
  });
}

class SongProvider with ChangeNotifier {
  List<SongItem> _songs = [];
  List<String> _favourites = [];
  List<String> _queue = [];

  List<SongItem> get songs {
    return [..._songs];
  }

  List<SongItem> get favourites {
    return _songs.where((song) => isFavourite(song.path)).toList();
  }

  List<SongItem> get queue {
    List<SongItem> selectedSongs = [];
    _queue.forEach((path) {
      selectedSongs.add(_songs.firstWhere((song) => song.path == path));
    });
    return selectedSongs;
  }

  SharedPreferences prefs;

  List<SongItem> get songsFraction {
    var fraction = [..._songs];
    if (songs.length < 20) {
      fraction.shuffle();
      return fraction;
    }
    fraction.shuffle();
    return fraction.sublist(0, 21);
  }

  bool showBottonBar = false;

  void changeBottomBar(bool value) {
    showBottonBar = value;
    notifyListeners();
  }

  Future<void> getAllAlbumArt() async {
    const platform = MethodChannel("stereo.beats/metadata");
    final path =
        await platform.invokeMethod("getAllAlbumArt") as Map<dynamic, dynamic>;
    _songs = _songs
        .map(
          (song) => SongItem(
            title: song.title,
            album: song.album,
            albumArtist: song.albumArtist,
            albumId: song.albumId,
            artist: song.artist,
            dateAdded: song.duration,
            duration: song.duration,
            year: song.year,
            path: song.path,
            artPath: path[song.albumId],
          ),
        )
        .toList();
    _songs.sort(
        (a, b) => a.title?.toUpperCase()?.compareTo(b.title?.toUpperCase()));
  }

  Future<void> getSongs() async {
    prefs = await SharedPreferences.getInstance();
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
    _favourites = prefs.getStringList("favourites") ?? [];
  }

  Future<void> toggleFavourite(String path) async {
    if (!_favourites.contains(path)) {
      _favourites.add(path);
    } else {
      _favourites.remove(path);
    }
    notifyListeners();
    await prefs.setStringList("favourites", _favourites);
  }

  void removeFromFavourites() async {
    _queue.forEach((path) {
      _favourites.remove(path);
    });
    notifyListeners();
    prefs.setStringList("favourites", _favourites);
  }

  Future<void> deleteSongs() async {
    const platform = MethodChannel("stereo.beats/metadata");
    _queue.forEach((path) async {
      _songs.removeWhere((song) => song.path == path);
      await platform.invokeMethod("deleteFile", {
        "path": path,
      });
    });
    removeFromFavourites();
  }

  Future<void> shareFile() async {
    const platform = MethodChannel("stereo.beats/metadata");
    await platform.invokeMethod("shareFile", {"paths": _queue});
  }

  bool isFavourite(String path) {
    if (_favourites.contains(path)) {
      return true;
    }
    return false;
  }

  void addToQueue(String path) {
    _queue.add(path);
  }

  void removeFromQueue(String path) {
    _queue.remove(path);
  }

  void setQueueToNull() => _queue = [];

  bool queueNotNull() => _queue.length > 0;

  String getArtPath(String path) =>
      _songs.firstWhere((song) => song.path == path).artPath;
}
