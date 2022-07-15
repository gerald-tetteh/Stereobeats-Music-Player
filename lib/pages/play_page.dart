/*
 * Author: Gerald Addo-Tetteh
 * Stereo Beats Music Player for Android mobile devices.
 * Addo Develop
 * Email: addodevelop@gmail.com
 * Play Page
*/

/*
  The play page shows the song that is playing, the duration
  and the play controls. The user can switch between songs here 
  and the user can also seek the track. The page also has a button
  th allows the user to view the music video of the song that is currently
  playing if it exists.
*/

// imports

// package imports
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;
import 'package:youtube_api/youtube_api.dart';

// lib file imports
import '../provider/music_player.dart';
import '../provider/songItem.dart';
import '../utils/default_util.dart';
import '../utils/text_util.dart';
import '../components/play_page_song_info.dart';
import '../components/slider_and_duration.dart';
import '../components/play_page_controls.dart';
import '../components/play_page_pop_up.dart';
import '../components/toast.dart';
import '../components/circular_image.dart';
import '../helpers/api_keys.dart';

import 'song_detail_page.dart';

class PlayMusicScreen extends StatefulWidget {
  // name of route
  static const routeName = "/play-page";
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  _PlayMusicScreenState createState() => _PlayMusicScreenState();
}

class _PlayMusicScreenState extends State<PlayMusicScreen> {
  @override
  Widget build(BuildContext context) {
    final value =
        Provider.of<AudioPlayer>(context, listen: false); // audio player
    final songProvider = Provider.of<SongProvider>(context, listen: false);
    final slider = value.slider;
    final mediaQuery = MediaQuery.of(context);
    var viewlHeight = mediaQuery.size.height;
    var viewWidth = mediaQuery.size.width;
    // the boolean variables ae used to ensure different
    // layouts on different screen sizes
    final _smallSize = viewlHeight < 600;
    final _smallWidth = viewWidth < 600;
    var appBar = AppBar(
      iconTheme: Theme.of(context).iconTheme,
      backgroundColor: Colors.transparent,
      title: FittedBox(child: DefaultUtil.appName),
      centerTitle: true,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_drop_down,
          size: TextUtil.large,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        if (_smallSize)
          YoutubeView(
            value: value,
            scaffoldKey: widget._scaffoldKey,
          ),
        Consumer<AudioPlayer>(
          builder: (context, player, child) {
            return PlayPagePopUp(
              audioProvider: player,
              songProvider: songProvider,
            );
          },
        ),
      ],
    ); // carousel slider
    var appBarHeight = appBar.preferredSize.height;
    var extraPadding = mediaQuery.padding.top;
    var actualHeight = viewlHeight - (extraPadding + appBarHeight);
    final _isLandScape = mediaQuery.orientation == Orientation.landscape;

    var songDataAndDuration = Container(
      constraints: _smallSize && !_isLandScape
          ? BoxConstraints(
              maxHeight: actualHeight * 0.71,
              maxWidth: mediaQuery.size.width,
            )
          : null,
      margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            children: [
              PlayPageSongInfo(),
              SliderAndDuration(),
              if (!_smallSize)
                YoutubeView(
                  value: value,
                  scaffoldKey: widget._scaffoldKey,
                ),
            ],
          ),
          PlayPageControls(value: value),
        ],
      ),
    );
    List<Widget> contents = [
      Expanded(
        child: slider,
      ),
      _smallSize && !_isLandScape
          ? FittedBox(
              child: songDataAndDuration,
            )
          : Expanded(
              child: songDataAndDuration,
              flex: _isLandScape && _smallSize && _smallWidth ? 2 : 1,
            ),
    ];
    // Color(0xffeceff1)
    return Consumer<AudioPlayer>(
      child: Scaffold(
        key: widget._scaffoldKey,
        backgroundColor: Colors.transparent,
        appBar: appBar,
        /*
          The items on this page are arranged differently 
          when the device orientation changes to prevent 
          layout errors.
        */
        body:
            _isLandScape ? Row(children: contents) : Column(children: contents),
      ),
      builder: (context, provider, child) {
        final song = provider.playing;
        return Stack(
          fit: StackFit.expand,
          children: [
            AlbumArtBuilder(
              albumId: song.metas.extra!["albumId"] ?? -1,
              songId: song.metas.extra!["songId"] ?? -1,
              artistId: -1,
              circular: false,
            ),
            Container(
              width: double.infinity,
              height: double.infinity,
              child: ClipRRect(
                // creates a background blur effect
                // the songs album art is used as the background
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    alignment: Alignment.center,
                    color: Colors.grey.withOpacity(0.1),
                    child: child,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/* 
  This widget returns a button that can be used to view the music 
  video of the song playing on youtube if it exists.
  The video is ethier shown on th device browser or in th youtube app
  on the device (if it exists).
*/
class YoutubeView extends StatelessWidget {
  const YoutubeView({
    Key? key,
    required this.value,
    required this.scaffoldKey,
  }) : super(key: key);

  final AudioPlayer value;
  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  Widget build(BuildContext context) {
    final fToast = FToast();
    return PlayerBuilder.current(
      player: value.audioPlayer,
      builder: (context, current) {
        return IconButton(
          icon: FaIcon(
            FontAwesomeIcons.youtube,
            size: TextUtil.medium,
          ),
          onPressed: () async {
            var artist = value.playing.metas.artist!.toLowerCase();
            var finalArtistName = artist.contains("unknown") ? "" : artist;
            var title = value.playing.metas.title;
            if (title != null) {
              _showSnackBar(context);
              try {
                var response = await ApiKeys.youtubeApiHandler
                    .search(title + " $finalArtistName");
                String? url = response
                    .firstWhereOrNull(
                      (result) => result.url.length != 0,
                    )
                    ?.url;
                await _launch(url ?? "", fToast, context);
              } catch (e) {
                ScaffoldMessenger.of(context).removeCurrentSnackBar();
                fToast.showToast(
                  child: ToastComponent(
                    color: Colors.orangeAccent,
                    icon: Icons.error_outline,
                    message: "Could not load video...",
                    iconColor: Colors.orangeAccent[100],
                  ),
                  gravity: ToastGravity.BOTTOM,
                  toastDuration: Duration(seconds: 3),
                );
              }
            }
          },
          tooltip: "Watch Youtube Video",
        );
      },
    );
  }

  /*
    This method is used to launch the music video.
    If the URL is valid the browser of youtube app is launched.
  */
  Future<void> _launch(String url, FToast fToast, BuildContext context) async {
    if (await launcher.canLaunchUrl(Uri.parse(url))) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      launcher.launchUrl(
        Uri.parse(url),
      );
    } else {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      fToast.showToast(
        child: ToastComponent(
          color: Colors.orangeAccent,
          icon: Icons.error_outline,
          message: "Could not find video...",
          iconColor: Colors.orangeAccent[100],
        ),
        gravity: ToastGravity.BOTTOM,
        toastDuration: Duration(seconds: 3),
      );
    }
  }

  /*
    This method returns a snackbar while the video is loading. 
  */
  void _showSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(
              width: 10,
            ),
            Text(
              "Loading Video",
            ),
          ],
        ),
        duration: Duration(minutes: 2),
      ),
    );
  }
}
