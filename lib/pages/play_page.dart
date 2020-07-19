import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/music_player.dart';
import '../utils/default_util.dart';
import '../utils/text_util.dart';
import '../components/page_view_card.dart';

class PlayMusicScreen extends StatefulWidget {
  static const routeName = "/play-page";

  @override
  _PlayMusicScreenState createState() => _PlayMusicScreenState();
}

class _PlayMusicScreenState extends State<PlayMusicScreen> {
  @override
  Widget build(BuildContext context) {
    // final mediaQuery = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(
              Icons.search,
              size: TextUtil.large,
            ),
            onPressed: () {},
          ),
        ],
        title: DefaultUtil.appName,
        centerTitle: true,
      ),
      body: Consumer<AudioPlayer>(
        builder: (context, value, child) {
          final songs = value.audioPlayer.playlist.audios;
          var pageController = value.pageController;
          final songItems = value.songsQueue;
          return Column(
            children: [
              Expanded(
                child: Center(
                  child: PageView.builder(
                    itemCount: songs.length,
                    controller: pageController,
                    itemBuilder: (context, index) {
                      return PageViewCard(songItems[index]);
                    },
                    onPageChanged: (value1) {
                      setState(() async {
                        await value.audioPlayer.playlistPlayAtIndex(value1);
                        value.pageController = PageController(
                          initialPage: value1,
                          keepPage: false,
                          viewportFraction: 0.8,
                        );
                      });
                    },
                  ),
                ),
              ),
              Expanded(child: Container()),
            ],
          );
        },
      ),
    );
  }
}
