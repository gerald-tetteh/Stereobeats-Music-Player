/*
 * Author: Gerald Addo-Tetteh
 * Stereo Beats Music Player for Android mobile devices.
 * Addo Develop
 * Email: addodevelop@gmail.com
 * Album Class
*/

/*
  This file contains a blue print for 
  an album.
*/

import '../provider/songItem.dart';

class Album {
  String? name;
  String? albumArtist;
  List<SongItem>? paths;

  @override
  String toString() => this.name!;

  Album({
    this.name,
    this.albumArtist,
    this.paths,
  });
}
