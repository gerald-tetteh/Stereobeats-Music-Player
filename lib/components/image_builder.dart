import 'dart:io';

import 'package:flutter/material.dart';

import '../utils/default_util.dart';
import '../provider/songItem.dart';

class ImageBuilder extends StatefulWidget {
  ImageBuilder({
    Key key,
    @required this.songProvider,
    @required this.song,
  }) : super(key: key);

  final SongProvider songProvider;
  final SongItem song;

  @override
  _ImageBuilderState createState() => _ImageBuilderState();
}

class _ImageBuilderState extends State<ImageBuilder>
    with AutomaticKeepAliveClientMixin<ImageBuilder> {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    String path;
    return FutureBuilder(
      future:
          widget.songProvider.getAlbumArt(widget.song.albumId).then((value) {
        path = value;
        widget.song.artPath = path;
      }),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return DefaultUtil.checkNotNull(path)
              ? Image.file(
                  File(path),
                  fit: BoxFit.cover,
                )
              : Image.asset(
                  DefaultUtil.defaultImage,
                  fit: BoxFit.cover,
                );
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
