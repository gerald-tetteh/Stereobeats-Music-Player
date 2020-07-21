import 'package:flutter/material.dart';

import '../provider/songItem.dart';
import '../components/image_builder.dart';

class PageViewCard extends StatelessWidget {
  final SongItem song;
  PageViewCard(this.song);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(5),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 5,
        child: Hero(
          tag: song.path,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: ImageBuilder(
              path: song.artPath,
            ),
          ),
        ),
      ),
    );
  }
}
