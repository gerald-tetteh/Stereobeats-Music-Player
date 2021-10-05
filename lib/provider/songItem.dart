/*
 * Author: Gerald Addo-Tetteh
 * Stereo Beats Music Player for Android mobile devices.
 * Addo Develop
 * Email: addodevelop@gmail.com
 * SongProvider & SongItem
*/

/*
  This file containes two class.
  => SongItem : This class represents the structure
                of a song that is retrieved from the 
                device storage.
  => SongProvider: The song provider is reponsible for retrieving
                  and creating a SongItem to reflect each song in the device
                  storage. It also stores the songs into albums, artists, favourites
                  and playlists. It also retrieves album art.
*/

// imports

// package imports
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';

// lib file imports
import '../models/playlist.dart';
import '../models/album.dart';
import '../helpers/db_helper.dart';
import '../utils/default_util.dart';

class SongItem {
  final String songId;
  final String title;
  final String artist;
  final String album;
  final String albumArtist;
  final String albumId;
  final String year;
  final String dateAdded;
  final String duration;
  final String path;
  String artPath; // artPath is not final because it is determined after
  // the item is created.
  Uint8List artPath2;

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
  });
}

class SongProvider with ChangeNotifier {
  List<SongItem> _songs = [];
  List<String> _favourites = [];
  List<String> _queue = [];
  List<String> _playlistKey = [];
  SharedPreferences prefs;
  bool showBottonBar = false;

  // returns a copy of all SongItems
  List<SongItem> get songs {
    return [..._songs];
  }

  // returns a copy of all playlistKeys: Used to identify
  // playlists in the db.
  List<String> get keys {
    return [..._playlistKey];
  }

  // return all SongItems that are marked as favourite
  List<SongItem> get favourites {
    return _songs.where((song) => isFavourite(song.path)).toList();
  }

  // returns all selected SongItems.
  List<SongItem> get queue {
    List<SongItem> selectedSongs = [];
    _queue.forEach((path) {
      selectedSongs.add(_songs.firstWhere((song) => song.path == path));
    });
    return selectedSongs;
  }

  // returns the path of all selected SongItems
  List<String> get queuePath {
    return [..._queue];
  }

  /*
    Returns a fraction or all SongItems depending on the the length 
    of the _songs.
  */
  List<SongItem> get songsFraction {
    var fraction = [..._songs];
    if (songs.length < 20) {
      fraction.shuffle();
      return fraction;
    }
    fraction.shuffle();
    return fraction.sublist(0, 20);
  }

  // returns the SongItems whose path matches the string provided
  SongItem getSongFromPath(String path) {
    return _songs.firstWhere((song) => song.path == path);
  }

  /*
    Changes the visibilty of the bottom action bar(showButtonBar) 
    based on the value provided.
  */
  void changeBottomBar(bool value) {
    showBottonBar = value;
    notifyListeners();
  }

  /*
    Retrievs all the album art related to each SongItem.
    and sorts the songs in alphabetical order.
    This completed using java code through the platform channel.
  */
  Future<void> getAllAlbumArt() async {
    const platform = MethodChannel("stereo.beats/metadata");
    final path =
        await platform.invokeMethod("getAllAlbumArt") as Map<dynamic, dynamic>;
    _songs = _songs
        .map(
          (song) => SongItem(
            songId: song.songId,
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

  /*
    Retrieves all songs available on the device and all favourites from
    the shared preference.
    This completed using java code through the platform channel.
  */
  Future<void> getSongs() async {
    prefs = await SharedPreferences.getInstance();
    // const platform = MethodChannel("stereo.beats/metadata");
    // final songList =
    //     await platform.invokeMethod("getDeviceAudio") as List<dynamic>;
    final audioQuery = FlutterAudioQuery();
    final songList = await audioQuery.getSongs();
    _songs = songList
        .map(
          (song) {
            return SongItem(
              title: song.title,
              album: song.album,
              albumArtist: song.artist,
              albumId: song.albumId,
              artist: song.artist,
              dateAdded: song.year,
              duration: song.duration,
              year: song.year,
              path: song.filePath,
              songId: song.id,
              artPath: song.albumArtwork,
            );
          },
        )
        .toList();
    await Future.forEach(_songs, (SongItem song) async {
      try {
        if(song.artPath == null) {
          song.artPath2 = await audioQuery.getArtwork(type: ResourceType.ALBUM, id: song.albumId);
        }
        if(song.artPath2 == null) {
          song.artPath2 = await audioQuery.getArtwork(type: ResourceType.ARTIST, id: song.artist);
        }
        if(song.artPath2 == null) {
          song.artPath2 = await audioQuery.getArtwork(type: ResourceType.SONG, id: song.songId);
        }
      } catch(e) {
      }
    });
    // _songs = songList
    //     .map(
    //       (song) => SongItem(
    //         title: song["title"],
    //         album: song["album"],
    //         albumArtist: song["albumArtist"],
    //         albumId: song["albumId"],
    //         artist: song["artist"],
    //         dateAdded: song["dateAdded"],
    //         duration: song["duration"],
    //         year: song["year"],
    //         path: song["path"],
    //         songId: song["songId"],
    //       ),
    //     )
    //     .toList();
    _favourites = prefs.getStringList("favourites") ?? [];
  }

  /*
    Updates the id3 tags of a particular audio file
    using UTF-8 encoding.
    This completed using java code through the platform channel.
    The local SongItem is also updated.
  */
  Future<int> updateSong(Map<String, String> songDetails) async {
    const platform = MethodChannel("stereo.beats/metadata");
    int result = await platform.invokeMethod("updateSong", {
      "songDetails": {
        "title": songDetails["title"],
        "artist": songDetails["artist"],
        "album": songDetails["album"],
        "albumArtist": songDetails["albumArtist"],
        "year": songDetails["year"],
        "songId": songDetails["songId"],
        "path": songDetails["path"],
      }
    });
    if (result == 1) {
      var oldSong =
          _songs.firstWhere((song) => song.path == songDetails["path"]);
      var index = _songs.indexWhere((song) => song.path == songDetails["path"]);
      var newSong = SongItem(
        album: songDetails["album"],
        title: songDetails["title"],
        artist: songDetails["artist"],
        albumArtist: songDetails["albumArtist"],
        artPath: oldSong.artPath,
        albumId: oldSong.albumId,
        dateAdded: oldSong.dateAdded,
        duration: oldSong.duration,
        path: oldSong.path,
        songId: oldSong.songId,
        year: songDetails["year"],
      );
      _songs.replaceRange(index, index + 1, [newSong]);
      notifyListeners();
    }
    return result;
  }

  // retrieves all albums from _songs.
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

  /*
    Converts Map<String,List<<SongItem>>(key,value) to List<Album>
    with the name of each album being the key and the album
    songs the value.
  */
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

  // retrives all songs whose artist == input
  List<SongItem> getArtistSongs(String artist) {
    return _songs.where((song) => song.artist == artist).toList();
  }

  // retrieves all albums whose albumArtist == input
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

  // returns list of all artists
  List<String> artists() {
    return _songs
        .map((song) => song.artist ?? DefaultUtil.unknown)
        .toSet()
        .toList()
          ..sort((a, b) => a?.toUpperCase()?.compareTo(b?.toUpperCase()));
  }

  // returns the path to an image
  // used on one of the songs made
  // by the artist provided.
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

  // returns the path to an image
  // used on one of the songs made
  // by the artist provided.
  Uint8List artistCoverArt2(String artist) {
    return _songs
        .firstWhere(
            (song) =>
                song.artist == artist &&
                song.artPath2 != null &&
                song.artPath2.length != 0,
            orElse: () => SongItem(artPath: DefaultUtil.defaultImage))
        .artPath2;
  }

  /*
    returns a list of SongItems whose
    title contains or is eqaul to the
    the text provided
  */
  List<SongItem> searchSongs(String text) {
    return _songs
        .where((song) =>
            song.title != null &&
            song.title.toLowerCase().contains(text.toLowerCase()))
        .toList();
  }

  /*
    returns a list of all albums whose 
    name containes or is == the text provided
  */
  List<Album> searchAlbums(String text) {
    Map<String, Album> albums = Map();
    _songs.map((song) {
      if ((song.album ?? DefaultUtil.unknown).contains(text)) {
        if (song.album != null && song.album.length != 0) {
          if (albums.keys.contains(song.album)) {
            albums[song.album].paths.add(song);
          } else {
            albums[song.album] = Album(
              albumArtist: song.albumArtist ?? DefaultUtil.unknown,
              name: song.album,
              paths: [song],
            );
          }
        }
      }
    }).toList();
    return albums.values.toList();
  }

  /*
    Provides a list of all artists
    which contains or is == the text provided.
  */
  List<String> searchArtist(String text) {
    var artist = List<String>();
    _songs
        .map((song) {
          if (song.artist != null &&
              song.artist.toLowerCase().contains(text.toLowerCase())) {
            if (!artist.contains(song.artist)) {
              artist.add(song.artist);
            }
          }
        })
        .toSet()
        .toList();
    return artist;
  }

  /*
    This fuction searchs through the songs, artist and 
    albums to find the items that match the input string.
    It calls three other functions to complete the search
  */
  Map<String, List<dynamic>> search(String text) {
    var results = Map<String, List<dynamic>>();
    results["songs"] = searchSongs(text);
    results["albums"] = searchAlbums(text);
    results["artists"] = searchArtist(text);
    return results;
  }

  /*
    The function adds or removes items from the favourite
    list depending on its favourite status.
  */
  Future<void> toggleFavourite(String path) async {
    if (!_favourites.contains(path)) {
      _favourites.add(path);
    } else {
      _favourites.remove(path);
    }
    notifyListeners();
    await prefs.setStringList("favourites", _favourites);
  }

  /*
    removes each item in _queue from the favourites list
  */
  void removeFromFavourites() async {
    _queue.forEach((path) {
      _favourites.remove(path);
    });
    notifyListeners();
    prefs.setStringList("favourites", _favourites);
  }

  /*
    Adds each item in _queue to the favourites list
  */
  void addToFavourites() {
    _favourites.addAll(_queue);
    notifyListeners();
    prefs.setStringList("favourites", _favourites);
  }

  /*
    When a song is deleted this method removes it from the playlist
    if it exits.
  */
  void removeFromPlayList() {
    _queue.forEach((path) {
      DBHelper.randomDeleteItem("playLists", path);
    });
  }

  /*
    Deletes all songs in _queue permanently from the device
    and clears all entries from the MediaStrore.
    This completed using java code through the platform channel. 
  */
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

  /*
    This function opens a share dialog 
    which would enable the user to share a song item.
    This completed using java code through the platform channel.
  */
  Future<void> shareFile() async {
    const platform = MethodChannel("stereo.beats/metadata");
    await platform.invokeMethod("shareFile", {"paths": _queue});
  }

  // checks the favourite status of a song
  // returns true if it is a favourite, false otherwise
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

  void setQueueToNull() => _queue = [];
  void setKeysToNull() => _playlistKey = [];

  bool queueNotNull() => _queue.length > 0;
  bool keysNotNull() => _playlistKey.length > 0;

  // removes a list of items from _queue
  void removeListFromQueue(List<String> paths) {
    List<String> toRemove = [];
    _queue.forEach((item) {
      if (paths.contains(item)) {
        toRemove.add(item);
      }
    });
    _queue.removeWhere((item) => toRemove.contains(item));
  }

  // returns the artPath for a song with the path == input
  String getArtPath(String path) =>
      _songs.firstWhere((song) => song.path == path).artPath;

  // returns the artPath for a song with the path == input
  Uint8List getArtPath2(String path) =>
      _songs.firstWhere((song) => song.path == path).artPath2;

  /*
    Returns a list of SongItems whose path is == to the 
    list of paths provided from the db 
  */
  List<SongItem> playListSongs(List<String> paths) {
    return _songs.where((song) => paths.contains(song.path)).toList();
  }

  // adds items in _queue to the db
  void addToPlayList(PlayList playList) =>
      DBHelper.addItem("playLists", playList, _queue);
}
