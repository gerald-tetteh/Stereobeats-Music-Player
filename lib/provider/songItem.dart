/*
 * Author: Gerald Addo-Tetteh
 * Stereo Beats Music Player for Android mobile devices.
 * Addo Develop
 * Email: addodevelop@gmail.com
 * SongProvider & SongItem
*/

/// This file contains two class.
/// SongItem : This class represents the structure of a
/// song that is retrieved from the device storage.
/// SongProvider: The song provider is responsible for retrieving
/// and creating a SongItem to reflect each song in the device
/// storage. It also stores the songs into albums, artists, favourites and playlists.
/// It also retrieves album art.

// imports

// package imports
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';

// lib file imports
import '../models/playlist.dart';
import '../models/album.dart';
import '../helpers/db_helper.dart';
import '../utils/default_util.dart';

class SongItem {
  final int? songId;
  final String? title;
  final String? artist;
  final String? album;
  final String? albumArtist;
  final int? albumId;
  final String? year;
  final int? dateAdded;
  final int? duration;
  final String? path;
  String? artPath; // artPath is not final because it is determined after
  // the item is created.
  Uint8List? artPath2;
  final int size;
  final bool isMusic;

  SongItem({
    this.songId,
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
    this.artPath2,
    required this.size,
    required this.isMusic,
  });
}

class SongProvider with ChangeNotifier {
  List<SongItem> _songs = [];
  List<String> _favourites = [];
  List<String> _queue = [];
  List<AlbumModel> _albums = [];
  List<ArtistModel> _artists = [];
  List<String> _playlistKey = [];
  SharedPreferences? prefs;
  bool showBottomBar = false;
  final deviceInfo = DeviceInfoPlugin();
  final _audioQuery = OnAudioQuery();

  /// returns a copy of all SongItems
  List<SongItem> get songs {
    return [..._songs];
  }

  /// returns a copy of all albums
  List<AlbumModel> get albums {
    return [..._albums];
  }

  /// returns a copy of all artists
  List<ArtistModel> get artists {
    return [..._artists];
  }

  /// returns a copy of all playlistKeys: Used to identify
  /// playlists in the db.
  List<String> get keys {
    return [..._playlistKey];
  }

  /// return all SongItems that are marked as favourite
  List<SongItem> get favourites {
    return _songs.where((song) => isFavourite(song.path)).toList();
  }

  /// returns all selected SongItems.
  List<SongItem> get queue {
    List<SongItem> selectedSongs = [];
    _queue.forEach((path) {
      selectedSongs.add(_songs.firstWhere((song) => song.path == path));
    });
    return selectedSongs;
  }

  /// returns the path of all selected SongItems
  List<String> get queuePath {
    return [..._queue];
  }

  /// Returns a fraction or all SongItems depending on the the length
  /// of the _songs.
  List<SongItem> get songsFraction {
    var fraction = [..._songs];
    if (songs.length < 20) {
      fraction.shuffle();
      return fraction;
    }
    fraction.shuffle();
    return fraction.sublist(0, 20);
  }

  /// returns the SongItems whose path matches the string provided
  SongItem getSongFromPath(String? path) {
    return _songs.firstWhere((song) => song.path == path);
  }

  /// Changes the visibility of the bottom action bar(showButtonBar)
  /// based on the value provided.
  void changeBottomBar(bool value) {
    showBottomBar = value;
    notifyListeners();
  }

  /// Retrieves all songs available on the device and all favourites from
  /// the shared preference.
  /// This completed using java code through the platform channel.
  Future<void> getSongs() async {
    prefs = await SharedPreferences.getInstance();
    var granted = await _audioQuery.permissionsStatus();
    while (!granted) {
      granted = await _audioQuery.permissionsRequest();
    }
    final songList = await _audioQuery.querySongs();
    _songs = songList
        .map(
          (song) => SongItem(
            title: song.title,
            album: song.album,
            albumArtist: song.artist,
            albumId: song.albumId,
            artist: song.artist,
            dateAdded: song.dateAdded,
            duration: song.duration,
            path: song.uri,
            songId: song.id,
            isMusic: song.isMusic!,
            size: song.size,
          ),
        )
        .toList();
    _favourites = prefs!.getStringList("favourites") ?? [];
  }

  /// Retrieves all albums and artists
  Future<void> getAlbumsAndArtists() async {
    var granted = await _audioQuery.permissionsStatus();
    while (!granted) {
      granted = await _audioQuery.permissionsRequest();
    }
    _albums = await _audioQuery.queryAlbums();
    _artists = await _audioQuery.queryArtists();
  }

  /// returns album songs
  List<SongItem> getAlbumSongs(String albumName, String albumArtist) {
    return _songs
        .where(
          (song) => song.album == albumName,
        )
        .toList();
  }

  /// retrieves all songs whose artist == input
  List<SongItem> getArtistSongs(String artist) {
    return _songs.where((song) => song.artist == artist).toList();
  }

  /// retrieves all albums whose albumArtist == input
  List<AlbumModel> getArtistAlbums(String albumArtist) {
    return _albums.where((album) => album.artist == albumArtist).toList();
  }

  /// returns a list of SongItems whose
  /// title contains or is equal to the
  /// the text provided
  List<SongItem> searchSongs(String text) {
    return _songs
        .where(
          (song) =>
              song.title != null &&
              song.title!.toLowerCase().contains(text.toLowerCase()),
        )
        .toList();
  }

  /// returns a list of all albums whose
  /// name contains or is == the text provided
  List<AlbumModel> searchAlbums(String text) {
    return _albums
        .where(
          (album) => album.album.toLowerCase().contains(text.toLowerCase()),
        )
        .toList();
  }

  /// Provides a list of all artists
  /// which contains or is == the text provided.
  List<ArtistModel> searchArtist(String text) {
    return _artists
        .where(
          (artist) => artist.artist.toLowerCase().contains(text.toLowerCase()),
        )
        .toList();
  }

  /// This function searches through the songs, artist and
  /// albums to find the items that match the input string.
  /// It calls three other functions to complete the search
  Map<String, List<dynamic>> search(String text) {
    var results = Map<String, List<dynamic>>();
    results["songs"] = searchSongs(text);
    results["albums"] = searchAlbums(text);
    results["artists"] = searchArtist(text);
    return results;
  }

  /// The function adds or removes items from the favourite
  /// list depending on its favourite status.
  Future<void> toggleFavourite(String? path) async {
    if (!_favourites.contains(path)) {
      _favourites.add(path!);
    } else {
      _favourites.remove(path);
    }
    notifyListeners();
    await prefs!.setStringList("favourites", _favourites);
  }

  /// removes each item in _queue from the favourites list
  void removeFromFavourites() async {
    _queue.forEach((path) {
      _favourites.remove(path);
    });
    notifyListeners();
    prefs!.setStringList("favourites", _favourites);
  }

  /// Adds each item in _queue to the favourites list
  void addToFavourites() {
    _favourites.addAll(_queue);
    notifyListeners();
    prefs!.setStringList("favourites", _favourites);
  }

  /// When a song is deleted this method removes it from the playlist
  /// if it exits.
  void removeFromPlayList() {
    _queue.forEach((path) {
      DBHelper.randomDeleteItem("playLists", path);
    });
  }

  /// Deletes all songs in _queue permanently from the device
  /// and clears all entries from the MediaStore.
  /// This completed using java code through the platform channel.
  Future<void> deleteSongs() async {
    const platform = MethodChannel("stereo.beats/metadata");
    _queue.forEach((path) async {
      _songs.removeWhere((song) => song.path == path);
      await platform.invokeMethod("deleteFile", {
        "path": path,
      });
    });
    removeFromPlayList();
    removeFromFavourites();
  }

  /// This function opens a share dialog
  /// which would enable the user to share a song item.
  /// This completed using java code through the platform channel.
  Future<void> shareFile() async {
    const platform = MethodChannel("stereo.beats/metadata");
    await platform.invokeMethod("shareFile", {"paths": _queue});
  }

  /// checks the favourite status of a song
  /// returns true if it is a favourite, false otherwise
  bool isFavourite(String? path) {
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

  void setQueueToNull() => _queue = [];
  void setKeysToNull() => _playlistKey = [];

  bool queueNotNull() => _queue.length > 0;
  bool keysNotNull() => _playlistKey.length > 0;

  /// removes a list of items from _queue
  void removeListFromQueue(List<String?>? paths) {
    List<String?> toRemove = [];
    _queue.forEach((item) {
      if (paths!.contains(item)) {
        toRemove.add(item);
      }
    });
    _queue.removeWhere((item) => toRemove.contains(item));
  }

  /// Returns a list of SongItems whose path is == to the
  /// list of paths provided from the db
  List<SongItem> playListSongs(List<String?> paths) {
    return _songs.where((song) => paths.contains(song.path)).toList();
  }

  /// adds items in _queue to the db
  void addToPlayList(PlayList playList) =>
      DBHelper.addItem("playLists", playList, _queue);
}
