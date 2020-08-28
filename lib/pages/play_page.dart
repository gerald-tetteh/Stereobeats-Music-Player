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
import 'dart:ui';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:equalizer/equalizer.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

// lib file imports
import '../provider/music_player.dart';
import '../provider/songItem.dart';
import '../utils/default_util.dart';
import '../utils/text_util.dart';
import '../components/play_page_song_info.dart';
import '../components/slider_and_duration.dart';
import '../components/play_page_controls.dart';
import '../components/toast.dart';
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
    final slider = value.slider; // carousel slider
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  PlayPageSongInfo(),
                  SliderAndDuration(),
                  YoutubeView(
                    value: value,
                    scaffoldKey: widget._scaffoldKey,
                  ),
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
        key: widget._scaffoldKey,
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
          actions: [
            Consumer<AudioPlayer>(
              builder: (context, player, child) {
                var path = player.playing.path;
                return IconButton(
                  icon: Icon(Icons.notes),
                  onPressed: () => Navigator.of(context)
                      .pushNamed(SongDetailPage.routeName, arguments: path),
                  tooltip: "Song Details",
                );
              },
            ),
            Consumer<AudioPlayer>(
              builder: (context, player2, child) {
                return IconButton(
                  icon: Icon(Icons.equalizer_rounded),
                  onPressed: () async => await Equalizer.open(
                      player2.audioPlayer.audioSessionId.value),
                );
              },
            ),
            Consumer<AudioPlayer>(
              builder: (context, player3, child) {
                var path = player3.playing.path;
                songProvider.addToQueue(path);
                return IconButton(
                  icon: Icon(
                    Icons.share_outlined,
                    size: TextUtil.xsmall,
                  ),
                  onPressed: () async {
                    await songProvider.shareFile();
                    songProvider.setQueueToNull();
                  },
                );
              },
            ),
          ],
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

/* 
  This widget returns a button that can be used to view the music 
  video of the song playing on youtube if it exists.
  The video is ethier shown on th device browser or in th youtube app
  on the device (if it exists).
*/
class YoutubeView extends StatelessWidget {
  const YoutubeView({
    Key key,
    @required this.value,
    @required this.scaffoldKey,
  }) : super(key: key);

  final AudioPlayer value;
  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  Widget build(BuildContext context) {
    final fToast = FToast(scaffoldKey.currentContext);
    return PlayerBuilder.current(
      player: value.audioPlayer,
      builder: (context, current) {
        return IconButton(
          icon: FaIcon(
            FontAwesomeIcons.youtube,
            size: TextUtil.medium,
          ),
          onPressed: () async {
            var artist = value.playing.metas.artist.toLowerCase();
            var finalArtistName = artist.contains("unknown") ? "" : artist;
            var title = value.playing.metas.title;
            if (title != null) {
              _showSnackBar();
              var response = await ApiKeys.youtubeApiHandler
                  .search(title + " $finalArtistName");
              var url = response
                  .firstWhere(
                      (result) => result.url != null && result.url.length != 0,
                      orElse: () => null)
                  ?.url;
              await _launch(url, fToast);
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
  Future<void> _launch(String url, FToast fToast) async {
    if (await launcher.canLaunch(url)) {
      scaffoldKey.currentState.removeCurrentSnackBar();
      launcher.launch(
        url,
        forceWebView: false,
      );
    } else {
      scaffoldKey.currentState.removeCurrentSnackBar();
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
  void _showSnackBar() {
    scaffoldKey.currentState.showSnackBar(
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
