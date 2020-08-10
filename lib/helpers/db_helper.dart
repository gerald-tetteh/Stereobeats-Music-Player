import 'package:hive/hive.dart';
// import 'package:hive_flutter/hive_flutter.dart';

import '../models/playlist.dart';

class DBHelper {
  static void addItem(String boxName, PlayList playList, List<String> paths) {
    var box = Hive.box<PlayList>(boxName);
    var savedPlayList = box.get(playList.toString());
    if (savedPlayList.paths == null) {
      savedPlayList.paths = paths;
    } else {
      savedPlayList.paths.addAll(paths);
    }
    box.put(playList.toString(), savedPlayList);
  }

  static void createItem(String boxName, String playListName,
      [List<String> paths]) {
    var box = Hive.box<PlayList>(boxName);
    var playList = PlayList()
      ..name = playListName
      ..paths = paths;
    box.put(playList.toString(), playList);
  }

  static void deleteBox(String boxName, List<String> playListNames) {
    var box = Hive.box<PlayList>(boxName);
    box.deleteAll(playListNames);
  }

  static List<dynamic> getkeys(String boxName) {
    var box = Hive.box<PlayList>(boxName);
    return box.keys.toList();
  }

  static void changeItemName(
      String boxName, String playlistName, String newName) {
    var box = Hive.box<PlayList>(boxName);
    var oldPlaylist = box.get(playlistName);
    box.delete(oldPlaylist.toString());
    oldPlaylist.name = newName;
    box.put(oldPlaylist.name, oldPlaylist);
  }
}
