/*
 * Author: Gerald Addo-Tetteh
 * Stereo Beats Music Player for Android mobile devices.
 * Addo Develop
 * Email: addodevelop@gmail.com
 * Playlist & Album Detail Template (Component)
*/

/*
  This Widget build the playlist and album detail screen and
*/

// imports

// package imports
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

// lib file imports
import '../utils/text_util.dart';
import '../utils/default_util.dart';
import '../utils/color_util.dart';
import '../models/playlist.dart';
import '../provider/songItem.dart';
import '../provider/theme_mode.dart';
import '../extensions/string_extension.dart';
import '../provider/music_player.dart';

import 'box_image.dart';
import 'build_check_box.dart';
import 'image_builder.dart';

class PlaylistAndAlbumDetail extends StatelessWidget {
  final PlayList? playlist;
  final AlbumModel? album;
  PlaylistAndAlbumDetail({this.playlist, this.album});
  // either the album or playlist must be null
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
      // it the album songs are null or 0 the empty widget is returned
      return album!.numOfSongs > 0
          ? _buildList(
              actualHeight,
              context,
              album!.album,
              songProvider.getAlbumSongs(album!.album, album!.artist ?? ""),
              songProvider,
              audioProvider,
              isLandScape,
              mediaQuery,
            )
          : _noSongs(context);
    } else {
      final songProvider = Provider.of<SongProvider>(context, listen: false);
      return ValueListenableBuilder(
        valueListenable: Hive.box<PlayList>("playLists")
            .listenable(keys: [playlist.toString()]),
        builder: (context, Box<PlayList> box, child) {
          final currentPlayList = box.get(playlist.toString())!;
          final songs = songProvider
              .playListSongs(currentPlayList.paths ?? [])
              .reversed
              .toList();
          // if the playlist has 0 songs the empty widget is returned
          return songs.length != 0
              ? _buildList(
                  actualHeight,
                  context,
                  playlist.toString(),
                  songs.reversed.toList(),
                  songProvider,
                  audioProvider,
                  isLandScape,
                  mediaQuery,
                )
              : _noSongs(context);
        },
      );
    }
  }

  // returns the empty widget
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

  // this widget constructs the layout for the page
  Column _buildList(
    double actualHeight,
    BuildContext context,
    String objectName,
    List<SongItem> songs,
    SongProvider provider,
    AudioPlayer player,
    bool isLandScape,
    MediaQueryData mediaQuery,
  ) {
    return Column(
      children: [
        Container(
          height: isLandScape ? actualHeight * 0.45 : actualHeight * 0.35,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Hero(
                tag: objectName,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: ImageBuilder(
                    albumId: songs[0].albumId ?? -1,
                    songId: songs[0].songId ?? -1,
                    highQuality: true,
                  ),
                ),
              ),
              // items in positioned are stacked on the top most element (in code)
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
        // adds extra space when the mini player is present
        SizedBox(
          height: 73,
        ),
      ],
    );
  }
}

// builds list view to show songs in album or playlist.
class BuildListView extends StatelessWidget {
  const BuildListView({Key? key, this.songs, this.songProvider, this.player})
      : super(key: key);

  final List<SongItem>? songs;
  final SongProvider? songProvider;
  final AudioPlayer? player;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final themeProvider = Provider.of<AppThemeMode>(context, listen: false);
    return GestureDetector(
      onTap: () {
        songProvider!.changeBottomBar(false);
        songProvider!.setQueueToNull();
        songProvider!.setKeysToNull();
      },
      child: ListView.separated(
        separatorBuilder: (context, index) => index != songs!.length - 1
            ? Divider(
                indent: mediaQuery.size.width * (1 / 4),
              )
            : "" as Widget,
        itemCount: songs!.length,
        itemBuilder: (context, index) {
          return Material(
            color: themeProvider.isDarkMode ? ColorUtil.dark : ColorUtil.white,
            child: InkWell(
              onTap: () {
                player!.setShuffle(false);
                player!.play(songs!, index);
              },
              onLongPress: () => songProvider!.changeBottomBar(true),
              child: Consumer<SongProvider>(
                builder: (context, provider1, child) {
                  return GestureDetector(
                    onTap: provider1.showBottomBar
                        ? () {
                            songProvider!.changeBottomBar(false);
                            songProvider!.setQueueToNull();
                            songProvider!.setKeysToNull();
                          }
                        : null,
                    child: ListTile(
                      leading: BoxImage(
                        albumId: songs![index].albumId ?? -1,
                        songId: songs![index].songId ?? -1,
                      ),
                      title: Text(
                        DefaultUtil.checkNotNull(songs![index].title)
                            ? songs![index].title!
                            : DefaultUtil.unknown,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: themeProvider.isDarkMode
                            ? TextUtil.allSongsTitle
                            : null,
                      ),
                      subtitle: Text(
                        DefaultUtil.checkNotNull(songs![index].title)
                            ? songs![index].artist!
                            : DefaultUtil.unknown,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: themeProvider.isDarkMode
                            ? TextUtil.allSongsArtist
                            : null,
                      ),
                      trailing: provider1.showBottomBar
                          ? BuildCheckBox(
                              path: songs![index].path,
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
