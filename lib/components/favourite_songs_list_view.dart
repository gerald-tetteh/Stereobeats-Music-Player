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
  bool _showCheckBox = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() {
        _showCheckBox = false;
        Provider.of<SongProvider>(context, listen: false)
            .changeBottomBar(false);
      }),
      child: ListView.builder(
        itemCount: widget.favouriteSongs.length,
        itemBuilder: (context, index) {
          final song = widget.favouriteSongs[index];
          return Material(
            color: ColorUtil.white,
            child: InkWell(
              onTap: () =>
                  widget.audioProvider.play(widget.favouriteSongs, index),
              onLongPress: () => setState(() {
                _showCheckBox = true;
                Provider.of<SongProvider>(context, listen: false)
                    .changeBottomBar(true);
              }),
              child: GestureDetector(
                onTap: _showCheckBox
                    ? () => setState(() {
                          _showCheckBox = false;
                          Provider.of<SongProvider>(context, listen: false)
                              .changeBottomBar(false);
                        })
                    : null,
                child: ListTile(
                  leading: _showCheckBox ? _buildCheckBox() : null,
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
  }) : super(key: key);

  @override
  __buildCheckBoxState createState() => __buildCheckBoxState();
}

class __buildCheckBoxState extends State<_buildCheckBox> {
  bool _boxValue = false;
  @override
  Widget build(BuildContext context) {
    return CircularCheckBox(
      value: _boxValue,
      onChanged: (value) => setState(() => _boxValue = value),
    );
  }
}
