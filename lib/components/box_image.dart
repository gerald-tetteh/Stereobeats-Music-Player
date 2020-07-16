import 'package:flutter/material.dart';

import '../provider/songItem.dart';
import '../components/image_builder.dart';

class BoxImage extends StatelessWidget {
  const BoxImage({
    Key key,
    @required this.songProvider,
    @required this.song,
  }) : super(key: key);

  final SongProvider songProvider;
  final SongItem song;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: ImageBuilder(
          songProvider: songProvider,
          song: song,
        ),
      ),
    );
  }
}
