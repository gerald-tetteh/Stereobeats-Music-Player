/*
 * Author: Gerald Addo-Tetteh
 * Stereo Beats Music Player for Android mobile devices.
 * Addo Develop
 * Email: addodevelop@gmail.com
 * Image Builder (Component)
*/

/// This widget returns the appropriated image based
/// on the path to the album art provided.

// imports

// package imports
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

// lib file imports
import '../utils/default_util.dart';

class ImageBuilder extends StatelessWidget {
  ImageBuilder({
    Key? key,
    required this.albumId,
    required this.songId,
  }) : super(key: key);

  final int albumId;
  final int songId;

  @override
  Widget build(BuildContext context) {
    return QueryArtworkWidget(
      id: albumId,
      type: ArtworkType.ALBUM,
      artworkFit: BoxFit.cover,
      artworkBorder: BorderRadius.zero,
      artworkClipBehavior: Clip.hardEdge,
      nullArtworkWidget: QueryArtworkWidget(
        id: songId,
        type: ArtworkType.AUDIO,
        artworkFit: BoxFit.cover,
        artworkBorder: BorderRadius.zero,
        artworkClipBehavior: Clip.hardEdge,
        nullArtworkWidget: Image.asset(
          DefaultUtil.defaultImage,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
