import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/text_util.dart';
import '../utils/default_util.dart';
import '../utils/color_util.dart';
import '../components/customDrawer.dart';
import '../components/quick_play_options.dart';
import '../provider/songItem.dart';
import '../provider/music_player.dart';
import '../components/mini_player.dart';

class FavouritesPage extends StatelessWidget {
  static const routeName = "/favourites-page";
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    final favouriteSongs = Provider.of<SongProvider>(context).favourites;
    final audioProvider = Provider.of<AudioPlayer>(context);
    final mediaQuery = MediaQuery.of(context);
    return Scaffold(
      backgroundColor: Color(0xffeeeeee),
      drawer: CustomDrawer(),
      key: _scaffoldKey,
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme,
        leading: IconButton(
          icon: Icon(
            Icons.menu,
            size: TextUtil.medium,
          ),
          onPressed: () => _scaffoldKey.currentState.openDrawer(),
        ),
        title: DefaultUtil.appName,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Column(
            children: [
              ListTile(
                title: Text(
                  "Favourites",
                  style: TextUtil.pageHeadingTop,
                ),
                subtitle: Text("by you"),
                trailing: Icon(Icons.favorite),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: ColorUtil.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      QuickPlayOptions(
                          mediaQuery: mediaQuery,
                          provider: audioProvider,
                          songs: favouriteSongs),
                      Expanded(
                        child: ListView.builder(
                          itemCount: favouriteSongs.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(
                                DefaultUtil.checkNotNull(
                                        favouriteSongs[index].title)
                                    ? favouriteSongs[index].title
                                    : DefaultUtil.unknown,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                DefaultUtil.checkNotNull(
                                        favouriteSongs[index].artist)
                                    ? favouriteSongs[index].artist
                                    : DefaultUtil.unknown,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: CircleAvatar(
                                backgroundColor: Colors.black,
                                backgroundImage: DefaultUtil.checkNotNull(
                                        favouriteSongs[index].artPath)
                                    ? FileImage(
                                        File(favouriteSongs[index].artPath))
                                    : AssetImage(DefaultUtil.defaultImage),
                              ),
                              onTap: () =>
                                  audioProvider.play(favouriteSongs, index),
                            );
                          },
                        ),
                      ),
                      Consumer<AudioPlayer>(
                        builder: (context, value, child) =>
                            value.miniPlayerPresent
                                ? SizedBox(
                                    height: 73,
                                  )
                                : Container(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 10,
            left: 3,
            right: 3,
            child: Consumer<AudioPlayer>(
              builder: (context, value, child) => value.miniPlayerPresent
                  ? MiniPlayer(mediaQuery: mediaQuery)
                  : Container(),
            ),
          ),
        ],
      ),
    );
  }
}
