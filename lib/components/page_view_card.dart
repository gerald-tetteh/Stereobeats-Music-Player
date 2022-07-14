/*
 * Author: Gerald Addo-Tetteh
 * Stereo Beats Music Player for Android mobile devices.
 * Addo Develop
 * Email: addodevelop@gmail.com
 * Page View Card (Corousel Slider Component)
*/

/*
  The widget returns a square with rounded edges
  with the album art of the current song as its background.
*/

// imports

// package imports
import 'package:flutter/material.dart';

// lib file imports
import '../provider/songItem.dart';
import '../components/image_builder.dart';

class PageViewCard extends StatelessWidget {
  final SongItem song;
  PageViewCard(this.song);
  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: song.path!,
      child: Container(
        height: double.infinity,
        width: double.infinity,
        margin: const EdgeInsets.all(5),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 5,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: ImageBuilder(
              albumId: song.albumId ?? -1,
              songId: song.songId ?? -1,
            ),
          ),
        ),
      ),
    );
  }
}
