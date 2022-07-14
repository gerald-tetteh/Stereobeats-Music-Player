/*
 * Author: Gerald Addo-Tetteh
 * Stereo Beats Music Player for Android mobile devices.
 * Addo Develop
 * Email: addodevelop@gmail.com
 * Circular Image (component)
*/

import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

import '../utils/default_util.dart';

class CircularImage extends StatelessWidget {
  const CircularImage({
    Key? key,
    required this.albumId,
    required this.songId,
    this.artistId = -1,
  }) : super(key: key);

  final int? albumId;
  final int? songId;
  final int? artistId;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        image: DecorationImage(
          image: AssetImage(
            DefaultUtil.defaultImage,
          ),
          fit: BoxFit.cover,
        ),
      ),
      height: 50,
      width: 50,
      child: AlbumArtBuilder(
        albumId: albumId,
        songId: songId,
        artistId: artistId,
      ),
    );
  }
}

class AlbumArtBuilder extends StatelessWidget {
  const AlbumArtBuilder({
    Key? key,
    required this.albumId,
    required this.songId,
    this.artistId = -1,
    this.circular = true,
  }) : super(key: key);

  final int? albumId;
  final int? songId;
  final int? artistId;
  final bool circular;

  @override
  Widget build(BuildContext context) {
    return QueryArtworkWidget(
      id: albumId ?? -1,
      type: ArtworkType.ALBUM,
      artworkFit: BoxFit.cover,
      artworkBorder: circular ? BorderRadius.circular(100) : BorderRadius.zero,
      artworkClipBehavior: Clip.hardEdge,
      nullArtworkWidget: QueryArtworkWidget(
        id: songId ?? -1,
        type: ArtworkType.AUDIO,
        artworkFit: BoxFit.cover,
        artworkBorder:
            circular ? BorderRadius.circular(100) : BorderRadius.zero,
        artworkClipBehavior: Clip.hardEdge,
        nullArtworkWidget: QueryArtworkWidget(
          id: artistId ?? -1,
          type: ArtworkType.ARTIST,
          artworkFit: BoxFit.cover,
          artworkBorder:
              circular ? BorderRadius.circular(100) : BorderRadius.zero,
          artworkClipBehavior: Clip.hardEdge,
          nullArtworkWidget: ClipRRect(
            borderRadius:
                circular ? BorderRadius.circular(100) : BorderRadius.zero,
            child: Image.asset(
              DefaultUtil.defaultImage,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
