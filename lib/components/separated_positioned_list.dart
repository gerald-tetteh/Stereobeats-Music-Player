import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:provider/provider.dart';

import '../provider/songItem.dart';
import '../provider/music_player.dart';
import '../utils/default_util.dart';
import '../utils/color_util.dart';
import 'build_check_box.dart';

import 'box_image.dart';

class SeparatedPositionedList extends StatelessWidget {
  const SeparatedPositionedList({
    Key key,
    @required this.itemScrollController,
    @required this.mediaQuery,
  }) : super(key: key);

  final ItemScrollController itemScrollController;
  final MediaQueryData mediaQuery;
  @override
  Widget build(BuildContext context) {
    final songProvider = Provider.of<SongProvider>(context);
    final audioProvider = Provider.of<AudioPlayer>(context, listen: false);
    final songs = songProvider.songs;
    return GestureDetector(
      onTap: () {
        songProvider.changeBottomBar(false);
        songProvider.setQueueToNull();
      },
      child: ScrollablePositionedList.separated(
        itemCount: songs.length,
        addAutomaticKeepAlives: true,
        itemScrollController: itemScrollController,
        separatorBuilder: (context, index) => index != songs.length - 1
            ? Divider(
                indent: mediaQuery.size.width * (1 / 4),
              )
            : "",
        itemBuilder: (context, index) {
          return Material(
            color: ColorUtil.white,
            child: InkWell(
              onTap: () {
                audioProvider.setShuffle(false);
                audioProvider.play(songs, index);
              },
              onLongPress: () => songProvider.changeBottomBar(true),
              child: GestureDetector(
                onTap: songProvider.showBottonBar
                    ? () {
                        songProvider.changeBottomBar(false);
                        songProvider.setQueueToNull();
                      }
                    : null,
                child: ListTile(
                  leading: BoxImage(
                    path: songs[index].artPath,
                  ),
                  title: Text(
                    DefaultUtil.checkNotNull(songs[index].title)
                        ? songs[index].title
                        : DefaultUtil.unknown,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    DefaultUtil.checkNotNull(songs[index].artist)
                        ? songs[index].artist
                        : DefaultUtil.unknown,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: songProvider.showBottonBar
                      ? BuildCheckBox(path: songs[index].path)
                      : IconButton(
                          icon: Icon(Icons.more_vert),
                          onPressed: () {},
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
