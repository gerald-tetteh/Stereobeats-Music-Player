import 'dart:io';

import 'package:flutter/material.dart';
import 'package:circular_check_box/circular_check_box.dart';
import 'package:provider/provider.dart';

import '../provider/songItem.dart';
import '../provider/music_player.dart';
import '../utils/default_util.dart';
import '../utils/color_util.dart';

class FavouriteSongListView extends StatefulWidget {
  FavouriteSongListView({
    @required this.favouriteSongs,
    @required this.audioProvider,
  });

  final List<SongItem> favouriteSongs;
  final AudioPlayer audioProvider;

  @override
  _FavouriteSongListViewState createState() => _FavouriteSongListViewState();
}

class _FavouriteSongListViewState extends State<FavouriteSongListView> {
  @override
  Widget build(BuildContext context) {
    final songProvider = Provider.of<SongProvider>(context);
    return GestureDetector(
      onTap: () => setState(() {
        songProvider.changeBottomBar(false);
        songProvider.setQueueToNull();
      }),
      child: ListView.builder(
        itemCount: widget.favouriteSongs.length,
        itemBuilder: (context, index) {
          final song = widget.favouriteSongs[index];
          return Material(
            color: ColorUtil.white,
            child: InkWell(
              onTap: () {
                widget.audioProvider.setShuffle(false);
                widget.audioProvider.play(widget.favouriteSongs, index);
              },
              onLongPress: () => setState(() {
                songProvider.changeBottomBar(true);
              }),
              child: GestureDetector(
                onTap: songProvider.showBottonBar
                    ? () => setState(() {
                          songProvider.changeBottomBar(false);
                          songProvider.setQueueToNull();
                        })
                    : null,
                child: ListTile(
                  leading: songProvider.showBottonBar
                      ? _buildCheckBox(path: song.path)
                      : null,
                  title: Text(
                    DefaultUtil.checkNotNull(song.title)
                        ? song.title
                        : DefaultUtil.unknown,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    DefaultUtil.checkNotNull(song.artist)
                        ? song.artist
                        : DefaultUtil.unknown,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: CircleAvatar(
                    backgroundColor: Colors.black,
                    backgroundImage: DefaultUtil.checkNotNull(song.artPath)
                        ? FileImage(File(song.artPath))
                        : AssetImage(DefaultUtil.defaultImage),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _buildCheckBox extends StatefulWidget {
  const _buildCheckBox({
    Key key,
    @required this.path,
  }) : super(key: key);

  final String path;

  @override
  __buildCheckBoxState createState() => __buildCheckBoxState();
}

class __buildCheckBoxState extends State<_buildCheckBox> {
  bool _boxValue = false;
  @override
  Widget build(BuildContext context) {
    final songProvider = Provider.of<SongProvider>(context);
    return CircularCheckBox(
      value: _boxValue,
      onChanged: (value) {
        if (value) {
          songProvider.addToQueue(widget.path);
        } else {
          songProvider.removeFromQueue(widget.path);
        }
        setState(() => _boxValue = value);
      },
    );
  }
}
