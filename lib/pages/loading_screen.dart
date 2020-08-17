import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/music_player.dart';
import '../provider/songItem.dart';
import 'home.dart';
import '../utils/default_util.dart';
import '../utils/text_util.dart';

class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var songProvider = Provider.of<SongProvider>(context, listen: false);
    songProvider
        .getSongs()
        .then((value) => songProvider.getAllAlbumArt())
        .then((value) {
      Provider.of<AudioPlayer>(context, listen: false).prefs =
          songProvider.prefs;
      Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
    });
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Spacer(),
          Center(child: DefaultUtil.appName),
          Spacer(),
          Text(
            "created by".toLowerCase(),
            style: TextUtil.loadingScreenCredit1,
          ),
          Text(
            "addo develop".toUpperCase(),
            style: TextUtil.loadingScreenCredit2,
          ),
        ],
      ),
    );
  }
}
