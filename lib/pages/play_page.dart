import 'dart:io';
import 'dart:ui';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

import '../provider/music_player.dart';
import '../utils/default_util.dart';
import '../utils/text_util.dart';
import '../components/play_page_song_info.dart';
import '../components/slider_and_duration.dart';
import '../components/play_page_controls.dart';
import '../components/toast.dart';
import '../helpers/api_keys.dart';

class PlayMusicScreen extends StatefulWidget {
  static const routeName = "/play-page";
  final _scaffoldKey = GlobalKey<ScaffoldState>();

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
