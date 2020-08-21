import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../utils/text_util.dart';
import '../utils/default_util.dart';
import '../utils/color_util.dart';
import '../models/playlist.dart';
import '../models/album.dart';
import '../provider/songItem.dart';
import '../extensions/string_extension.dart';
import '../provider/music_player.dart';

import 'box_image.dart';
import 'build_check_box.dart';

class PlaylistAndAlbumDetail extends StatelessWidget {
  final PlayList playlist;
  final Album album;
  PlaylistAndAlbumDetail({this.playlist, this.album});
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final audioProvider = Provider.of<AudioPlayer>(context, listen: false);
    var viewHeight = mediaQuery.size.height;
    var extraPadding = mediaQuery.padding.top;
    var actualHeight = viewHeight - extraPadding;
    var isLandScape = mediaQuery.orientation == Orientation.landscape;
    if (playlist == null) {
      final songProvider = Provider.of<SongProvider>(context);
      return album.paths != null && album.paths.length != 0
          ? _buildList(actualHeight, context, album.toString(), album.paths,
              songProvider, audioProvider, isLandScape, mediaQuery)
          : _noSongs(context);
    } else {
      final songProvider = Provider.of<SongProvider>(context, listen: false);
      return ValueListenableBuilder(
        valueListenable: Hive.box<PlayList>("playLists")
            .listenable(keys: [playlist.toString()]),
        builder: (context, Box<PlayList> box, child) {
          final currentPlayList = box.get(playlist.toString());
          final songs = songProvider
              .playListSongs(currentPlayList.paths ?? [])
              .reversed
              .toList();
          return songs != null && songs.length != 0
              ? _buildList(actualHeight, context, playlist.toString(), songs,
                  songProvider, audioProvider, isLandScape, mediaQuery)
              : _noSongs(context);
        },
      );
    }
  }

  Widget _noSongs(BuildContext context) {
    return Column(
      children: [
        AppBar(
          title: DefaultUtil.appName,
          iconTheme: Theme.of(context).iconTheme,
        ),
        DefaultUtil.empty("No songs in playlist..."),
      ],
    );
  }

  Column _buildList(
      double actualHeight,
      BuildContext context,
      String objectName,
      List<SongItem> songs,
      SongProvider provider,
      AudioPlayer player,
      bool isLandScape,
      MediaQueryData mediaQuery) {
    return Column(
      children: [
        Container(
          height: isLandScape ? actualHeight * 0.45 : actualHeight * 0.25,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: DefaultUtil.checkNotNull(songs[0].artPath)
                        ? FileImage(File(songs[0].artPath))
                        : AssetImage(DefaultUtil.defaultImage),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                left: 7,
                top: 15,
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    size: TextUtil.medium,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    provider.changeBottomBar(false);
                    provider.setQueueToNull();
                    provider.setKeysToNull();
                  },
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.black54,
                  child: Row(
                    children: [
                      Container(
                        width: mediaQuery.size.width * 3 / 4,
                        child: Text(
                          objectName.trim().capitalize(),
                          style: TextUtil.playlistCardTitle.copyWith(
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Spacer(),
                      IconButton(
                        icon: Icon(
                          Icons.play_circle_fill_outlined,
                          size: TextUtil.xlarge,
                        ),
                        onPressed: () {
                          player.setShuffle(false);
                          player.play(songs);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: BuildListView(
            songs: songs,
            songProvider: provider,
            player: player,
          ),
        ),
        Consumer<AudioPlayer>(
          builder: (context, value, child) => value.miniPlayerPresent
              ? SizedBox(
                  height: 73,
                )
              : Container(),
        ),
      ],
    );
  }
}

class BuildListView extends StatelessWidget {
  const BuildListView({Key key, this.songs, this.songProvider, this.player})
      : super(key: key);

  final List<SongItem> songs;
  final SongProvider songProvider;
  final AudioPlayer player;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return GestureDetector(
      onTap: () {
        songProvider.changeBottomBar(false);
        songProvider.setQueueToNull();
        songProvider.setKeysToNull();
      },
      child: ListView.separated(
        separatorBuilder: (context, index) => index != songs.length - 1
            ? Divider(
                indent: mediaQuery.size.width * (1 / 4),
              )
            : "",
        itemCount: songs.length,
        itemBuilder: (context, index) {
          return Material(
            color: ColorUtil.white,
            child: InkWell(
              onTap: () {
                player.setShuffle(false);
                player.play(songs, index);
              },
              onLongPress: () => songProvider.changeBottomBar(true),
              child: Consumer<SongProvider>(
                builder: (context, provider1, child) {
                  return GestureDetector(
                    onTap: provider1.showBottonBar
                        ? () {
                            songProvider.changeBottomBar(false);
                            songProvider.setQueueToNull();
                            songProvider.setKeysToNull();
                          }
                        : null,
                    child: ListTile(
                      leading: BoxImage(path: songs[index].artPath),
                      title: Text(
                        DefaultUtil.checkNotNull(songs[index].title)
                            ? songs[index].title
                            : DefaultUtil.unknown,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        DefaultUtil.checkNotNull(songs[index].title)
                            ? songs[index].artist
                            : DefaultUtil.unknown,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: provider1.showBottonBar
                          ? BuildCheckBox(
                              path: songs[index].path,
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
