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
