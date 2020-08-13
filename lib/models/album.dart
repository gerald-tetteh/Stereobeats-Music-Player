import '../provider/songItem.dart';

class Album {
  String name;
  String albumArtist;
  List<SongItem> songs;

  @override
  String toString() => this.name;

  Album({
    this.name,
    this.albumArtist,
    this.songs,
  });
}
