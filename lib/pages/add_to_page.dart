/*
 * Author: Gerald Addo-Tetteh
 * Stereo Beats Music Player for Android mobile devices.
 * Addo Develop
 * Email: addodevelop@gmail.com
 * Add to Page
*/

/*
  This screen shows which collections the user can add a
  SongItem to. By default favourites is available.
*/

// imports

// package imports
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

// lib file imports
import '../provider/songItem.dart';
import '../provider/music_player.dart';
import '../models/playlist.dart';
import '../extensions/string_extension.dart';
import '../utils/text_util.dart';

class AddToPage extends StatelessWidget {
  // Name of route
  static const routeName = "/add-page";
  @override
  Widget build(BuildContext context) {
    final songProvider = Provider.of<SongProvider>(context, listen: false);
    final player = Provider.of<AudioPlayer>(context, listen: false);
    final mediaQuery = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add To..",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        iconTheme: Theme.of(context).iconTheme,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            songProvider.changeBottomBar(false);
            songProvider.setQueueToNull();
            Navigator.of(context).pop(false);
          },
        ),
      ),
      // Available items a rendered in a column
      // favourites and queue are always present
      body: Column(
        children: [
          ListTile(
            leading: Icon(Icons.favorite_border_rounded),
            title: Text("Favourites"),
            onTap: () {
              songProvider.addToFavourites();
              songProvider.changeBottomBar(false);
              songProvider.setQueueToNull();
              Navigator.of(context).pop(true);
            },
          ),
          ListTile(
            leading: Icon(Icons.queue_music_outlined),
            title: Text("Queue"),
            onTap: () {
              player.addToQueue(songProvider.queue);
              songProvider.changeBottomBar(false);
              songProvider.setQueueToNull();
              Navigator.of(context).pop(true);
            },
          ),
          Text(
            "Playlists",
            style: TextUtil.addPageHeadings,
          ),
          /*
            All playlist are retrived from the db and
            rendered in a list view is there are any present 
            otherwise and empty container is shown.(invisible)
          */
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: Hive.box<PlayList>("playLists").listenable(),
              builder: (context, Box<PlayList> box, child) {
                var playLists = box.values.toList() ?? [];
                if (playLists == null || playLists.length < 1) {
                  return Container();
                }
                return ListView.separated(
                  separatorBuilder: (context, index) =>
                      index != playLists.length - 1
                          ? Divider(
                              indent: mediaQuery.size.width * (1 / 4),
                            )
                          : "",
                  itemCount: playLists.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Icon(Icons.my_library_music_outlined),
                      title: Text(
                        playLists[index].toString().trim().capitalize(),
                      ),
                      onTap: () {
                        songProvider.addToPlayList(playLists[index]);
                        songProvider.changeBottomBar(false);
                        songProvider.setQueueToNull();
                        Navigator.of(context).pop(true);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
