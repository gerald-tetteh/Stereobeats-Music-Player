import 'package:flutter/material.dart';

import '../provider/songItem.dart';
import '../components/image_builder.dart';

class PageViewCard extends StatelessWidget {
  final SongItem song;
  PageViewCard(this.song);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(15),
      child: Card(
        elevation: 10,
        child: ImageBuilder(
          path: song.artPath,
        ),
      ),
    );
  }
}
