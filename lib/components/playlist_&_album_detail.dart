import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/text_util.dart';
import '../utils/default_util.dart';
import '../utils/color_util.dart';
import '../models/playlist.dart';
import '../provider/songItem.dart';
import '../extensions/string_extension.dart';
import '../provider/music_player.dart';

import 'box_image.dart';
import 'build_check_box.dart';

class PlaylistAndAlbumDetail extends StatelessWidget {
  final PlayList playlist;
  PlaylistAndAlbumDetail(this.playlist);
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final songProvider = Provider.of<SongProvider>(context, listen: false);
    final audioProvider = Provider.of<AudioPlayer>(context, listen: false);
    final songs = songProvider.playListSongs(playlist.paths ?? []);
    var viewHeight = mediaQuery.size.height;
    var extraPadding = mediaQuery.padding.top;
    var actualHeight = viewHeight - extraPadding;
    return songs != null && songs.length != 0
        ? _buildList(actualHeight, context, playlist.toString(), songs,
            songProvider, audioProvider)
        : _noSongs(context);
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
      String playlistName,
      List<SongItem> songs,
      SongProvider provider,
      AudioPlayer player) {
    return Column(
      children: [
        Container(
          height: actualHeight * 0.25,
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
                      Text(
                        playlistName.trim().capitalize(),
                        style: TextUtil.playlistCardTitle.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      Spacer(),
                      IconButton(
                        icon: Icon(
                          Icons.play_circle_fill_outlined,
                          size: TextUtil.xlarge,
                        ),
                        onPressed: () => print("hello"),
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
