import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/playlist.dart';
import '../models/album.dart';
import '../helpers/db_helper.dart';
import '../utils/default_util.dart';

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
  List<String> _playlistKey = [];

  List<SongItem> get songs {
    return [..._songs];
  }

  List<String> get keys {
    return [..._playlistKey];
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

  List<String> get queuePath {
    return [..._queue];
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

  Map<String, List<SongItem>> getAlbumsFromSongs() {
    Map<String, List<SongItem>> albums = Map();
    _songs.map((song) {
      var albumName = song.album ?? "Unknown";
      if (albums.containsKey(albumName)) {
        var songList = albums[albumName];
        songList.add(song);
        albums[albumName] = songList;
      } else {
        albums[albumName] = [song];
      }
    }).toList();
    return albums;
  }

  List<Album> changeToAlbum(Map<String, List<SongItem>> albums) {
    return albums
        .map(
          (key, value) {
            return MapEntry(
              key,
              Album(
                albumArtist: value
                    .firstWhere((song) => song.albumArtist != null,
                        orElse: () =>
                            SongItem(albumArtist: DefaultUtil.unknown))
                    .albumArtist,
                name: key,
                paths: value,
              ),
            );
          },
        )
        .values
        .toList()
          ..sort((a, b) =>
              a.name?.toUpperCase()?.compareTo(b.name?.toUpperCase()));
  }

  List<SongItem> getArtistSongs(String artist) {
    return _songs.where((song) => song.artist == artist).toList();
  }

  List<Album> getArtistAlbums(String albumArtist) {
    Map<String, Album> albums = Map();
    _songs.map((song) {
      if ((song.albumArtist ?? DefaultUtil.unknown) == albumArtist) {
        if (song.album != null && song.album.length != 0) {
          if (albums.keys.contains(song.album)) {
            albums[song.album].paths.add(song);
          } else {
            albums[song.album] = Album(
              albumArtist: song.albumArtist,
              name: song.album,
              paths: [song],
            );
          }
        }
      }
    }).toList();
    return albums.values.toList();
  }

  List<String> artists() {
    return _songs
        .map((song) => song.artist ?? DefaultUtil.unknown)
        .toSet()
        .toList()
          ..sort((a, b) => a?.toUpperCase()?.compareTo(b?.toUpperCase()));
  }

  String artistCoverArt(String artist) {
    return _songs
        .firstWhere(
            (song) =>
                song.artist == artist &&
                song.artPath != null &&
                song.artPath.length != 0,
            orElse: () => SongItem(artPath: DefaultUtil.defaultImage))
        .artPath;
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

  void addToFavourites() {
    _favourites.addAll(_queue);
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

  void addToQueue(String path) => _queue.add(path);
  void addToKeys(String name) => _playlistKey.add(name);

  void addListToQueue(List<String> paths) => _queue.addAll(paths);

  void removeFromQueue(String path) => _queue.remove(path);
  void removeFromKeys(String name) => _playlistKey.add(name);

  void removeListFromQueue(List<String> paths) {
    List<String> toRemove = [];
    _queue.forEach((item) {
      if (paths.contains(item)) {
        toRemove.add(item);
      }
    });
    _queue.removeWhere((item) => toRemove.contains(item));
  }

  void setQueueToNull() => _queue = [];
  void setKeysToNull() => _playlistKey = [];

  bool queueNotNull() => _queue.length > 0;
  bool keysNotNull() => _playlistKey.length > 0;

  String getArtPath(String path) =>
      _songs.firstWhere((song) => song.path == path).artPath;

  List<SongItem> playListSongs(List<String> paths) {
    return _songs.where((song) => paths.contains(song.path)).toList();
  }

  void addToPlayList(PlayList playList) =>
      DBHelper.addItem("playLists", playList, _queue);
}
