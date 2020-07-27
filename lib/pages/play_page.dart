import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/music_player.dart';
import '../utils/default_util.dart';
import '../utils/text_util.dart';
import '../components/play_page_song_info.dart';
import '../components/slider_and_duration.dart';
import '../components/play_page_controls.dart';

class PlayMusicScreen extends StatefulWidget {
  static const routeName = "/play-page";

  @override
  _PlayMusicScreenState createState() => _PlayMusicScreenState();
}

class _PlayMusicScreenState extends State<PlayMusicScreen> {
  @override
  Widget build(BuildContext context) {
    final value = Provider.of<AudioPlayer>(context, listen: false);
    final slider = value.slider;
    final mediaQuery = MediaQuery.of(context);
    final _isLandScape = mediaQuery.orientation == Orientation.landscape;
    List<Widget> contents = [
      Expanded(
        child: slider,
      ),
      Expanded(
        child: Container(
          margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  PlayPageSongInfo(),
                  SliderAndDuration(),
                ],
              ),
              PlayPageControls(value: value),
            ],
          ),
        ),
      ),
    ];
    // Color(0xffeceff1)
    return Consumer<AudioPlayer>(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          iconTheme: Theme.of(context).iconTheme,
          backgroundColor: Colors.transparent,
          title: DefaultUtil.appName,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_drop_down,
              size: TextUtil.large,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body:
            _isLandScape ? Row(children: contents) : Column(children: contents),
      ),
      builder: (context, provider, child) {
        String path = provider.playing.metas.image.path;
        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: DefaultUtil.checkNotNull(path) &&
                      DefaultUtil.checkNotAsset(path)
                  ? FileImage(File(path))
                  : AssetImage(DefaultUtil.defaultImage),
              fit: BoxFit.cover,
            ),
          ),
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                alignment: Alignment.center,
                color: Colors.grey.withOpacity(0.1),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}
