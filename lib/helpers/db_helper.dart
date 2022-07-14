/*
 * Author: Gerald Addo-Tetteh
 * Stereo Beats Music Player for Android mobile devices.
 * Addo Develop
 * Email: addodevelop@gmail.com
 * DB Helper
*/

/*
  This file contains the class DBHelper which contains
  static methods to perform CRUD operations.
*/

// imports

// package imports
import 'package:hive/hive.dart';
// import 'package:hive_flutter/hive_flutter.dart';

// lib file imports
import '../models/playlist.dart';

class DBHelper {
  // this method adds items to an entry in the database
  static void addItem(String boxName, PlayList playList, List<String?> paths) {
    var box = Hive.box<PlayList>(boxName);
    var savedPlayList = box.get(playList.toString())!;
    if (savedPlayList.paths == null) {
      savedPlayList.paths = paths;
    } else {
      savedPlayList.paths!.addAll(paths);
    }
    box.put(playList.toString(), savedPlayList);
  }

  // this method creats new entries in the database
  static void createItem(String boxName, String playListName,
      [List<String?>? paths]) {
    var box = Hive.box<PlayList>(boxName);
    var playList = PlayList()
      ..name = playListName
      ..paths = paths;
    box.put(playList.toString(), playList);
  }

  // this methods removes items from a database entry
  static void deleteItem(
      String boxName, String playlistName, List<String> paths) {
    var box = Hive.box<PlayList>(boxName);
    var playList = box.get(playlistName)!;
    playList.paths!.removeWhere((path) => paths.contains(path));
    box.put(playlistName, playList);
  }

  // this method deletes items from the data base when the items have
  // been deleted from the device
  static void randomDeleteItem(String boxName, String? path) {
    var box = Hive.box<PlayList>(boxName);
    List<PlayList> playLists =
        box.values.where((playlist) => playlist.paths!.contains(path)).toList();
    playLists.forEach((list) {
      list.paths!.remove(path);
      box.put(list.toString(), list);
    });
  }

  // this method deletes a database entry
  static void deleteBox(String boxName, List<String> playListNames) {
    var box = Hive.box<PlayList>(boxName);
    box.deleteAll(playListNames);
  }

  // this items returns a list of string used to identify a db entry
  static List<dynamic> getkeys(String boxName) {
    var box = Hive.box<PlayList>(boxName);
    return box.keys.toList();
  }

  // this method changes the name of a db entry
  static void changeItemName(
      String boxName, String playlistName, String newName) {
    var box = Hive.box<PlayList>(boxName);
    var oldPlaylist = box.get(playlistName)!;
    box.delete(oldPlaylist.toString());
    oldPlaylist.name = newName;
    box.put(oldPlaylist.name, oldPlaylist);
  }
}
