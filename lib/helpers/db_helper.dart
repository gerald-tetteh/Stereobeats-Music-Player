import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/playlist.dart';

class DBHelper {
  static addItem(String boxName, PlayList playList, List<String> paths) {
    var box = Hive.box<PlayList>(boxName);
    var savedPlayList = box.get(playList.toString());
    savedPlayList.paths.addAll(paths);
    box.put(playList.toString(), savedPlayList);
  }

  static createItem(String boxName, String playListName, [List<String> paths]) {
    var box = Hive.box<PlayList>(boxName);
    var playList = PlayList()
      ..name = playListName
      ..paths = paths;
    box.put(playList.toString(), playList);
  }
}
