/*
 * Author: Gerald Addo-Tetteh
 * Stereo Beats Music Player for Android mobile devices.
 * Addo Develop
 * Email: addodevelop@gmail.com
 * Loading Screen
*/

/*
  This screen is shown when the app is opened.
  The app reads the external storage and retrieves all
  the songs on the device.
  All the album arts are also retrieved.
*/

// imports

// package imports
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// lib file imports
import '../provider/songItem.dart';
import 'home.dart';
// import 'new_feature_page.dart';
import '../utils/default_util.dart';
import '../utils/text_util.dart';

class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // var box = Hive.box<String>("settings");
    // var updateCode = box.get("updateCode");
    var songProvider = Provider.of<SongProvider>(context, listen: false);
    songProvider.initSongProvider().then((_) {
      // Include for feature updates
      // if (updateCode == DefaultUtil.versionCode) {
      //   Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
      // } else {
      //   Navigator.of(context).pushReplacementNamed(NewFeature.routeName);
      // }
      // Navigate to home screen
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
          Center(
            child: CircularProgressIndicator(),
          ),
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
