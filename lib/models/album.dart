import '../provider/songItem.dart';

class Album {
  String name;
  String albumArtist;
  List<SongItem> paths;

  @override
  String toString() => this.name;

  Album({
    this.name,
    this.albumArtist,
    this.paths,
  });
}
