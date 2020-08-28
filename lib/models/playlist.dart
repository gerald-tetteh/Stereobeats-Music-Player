/*
 * Author: Gerald Addo-Tetteh
 * Stereo Beats Music Player for Android mobile devices.
 * Addo Develop
 * Email: addodevelop@gmail.com
 * PlayList Class
*/

/*
  This class represents the structure of 
  a playlist.
  The decorators => @Hive are used to 
  create the TypeAdapters. 
*/

import 'package:hive/hive.dart';

part 'playlist.g.dart';

@HiveType(typeId: 0)
class PlayList {
  @HiveField(0)
  String name;

  @HiveField(1)
  List<String> paths;

  @override
  String toString() => this.name;
}
