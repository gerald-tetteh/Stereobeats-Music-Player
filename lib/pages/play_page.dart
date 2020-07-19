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
    final value = Provider.of<AudioPlayer>(context, listen: false);
    final songs = value.audioPlayer.playlist.audios;
    final songItems = value.songsQueue;
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
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              itemCount: songs.length,
              controller: value.pageController,
              itemBuilder: (context, index) {
                return Hero(
                  tag: songItems[index].path,
                  transitionOnUserGestures: true,
                  child: PageViewCard(songItems[index]),
                );
              },
              onPageChanged: (value1) async {
                await value.audioPlayer.playlistPlayAtIndex(value1);
                value.pageController = PageController(
                  initialPage: value.findCurrentIndex(
                      value.audioPlayer.current.value.audio.audio.path),
                  keepPage: false,
                  viewportFraction: 0.8,
                );
              },
            ),
          ),
          Expanded(
            child: Container(
              child: Column(
                children: [],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
