/*
 * Author: Gerald Addo-Tetteh
 * Stereo Beats Music Player for Android mobile devices.
 * Addo Develop
 * Email: addodevelop@gmail.com
 * Play Page Controls (Component)
*/

/*
  This widget returns a row of widgets
  which can be used to play, pause and skip to the next track or return
  to the previous track.
  It also allows the user to set the loop and shuffle mode
  Stream Builders are used to rebuild the widget when the loop or 
  shuffle state changes.
*/

// imports

// package imports
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// lib file imports
import '../provider/music_player.dart';
import '../provider/theme_mode.dart';
import '../utils/color_util.dart';

class PlayPageControls extends StatelessWidget {
  const PlayPageControls({
    Key? key,
    required this.value,
  }) : super(key: key);

  final AudioPlayer value;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<AppThemeMode>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
      child: Card(
        color: themeProvider.isDarkMode ? ColorUtil.dark2 : null,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
        child: Container(
          padding: EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              /*
                The color and shape of the loop icon is changed to visually
                inform the user of the current shuffle moode.
                The PlayBuider rebuilds every time the shuffle button is clicked.
              */
              StreamBuilder<bool>(
                stream: value.audioPlayer.isShuffling,
                initialData: value.prefs!.getBool("shuffle") ?? false,
                builder: (context, snapshot) {
                  return IconButton(
                    icon: Icon(
                      Icons.shuffle,
                      color: (snapshot.hasData ? snapshot.data! : false)
                          ? themeProvider.isDarkMode
                              ? ColorUtil.darkTeal
                              : Colors.blue
                          : Colors.grey,
                    ),
                    onPressed: () async => await value.changeShuffle(),
                  );
                },
              ),
              IconButton(
                  icon: FaIcon(FontAwesomeIcons.backwardStep),
                  onPressed: () async => await value.previousTrack()),
              PlayerBuilder.playerState(
                player: value.audioPlayer,
                builder: (context, playerState) => IconButton(
                  icon: (playerState == PlayerState.pause ||
                          playerState == PlayerState.stop)
                      ? FaIcon(FontAwesomeIcons.play)
                      : FaIcon(FontAwesomeIcons.pause),
                  onPressed: () async => await value.playOrPause(),
                ),
              ),
              IconButton(
                icon: FaIcon(FontAwesomeIcons.forwardStep),
                onPressed: () async => await value.nextTrack(),
              ),
              /*
                The color and shape of the loop icon is changed to visually
                inform the user of the current loop mode.
                The PlayBuider rebuilds every time the loop button is clicked.
              */
              PlayerBuilder.loopMode(
                player: value.audioPlayer,
                builder: (context, loopMode) {
                  Icon icon;
                  if (loopMode == LoopMode.none) {
                    icon = Icon(
                      Icons.repeat,
                      color: Colors.grey,
                    );
                  } else if (loopMode == LoopMode.playlist) {
                    icon = Icon(
                      Icons.repeat,
                      color: themeProvider.isDarkMode
                          ? ColorUtil.darkTeal
                          : Colors.blue,
                    );
                  } else {
                    icon = Icon(
                      Icons.repeat_one,
                      color: themeProvider.isDarkMode
                          ? ColorUtil.darkTeal
                          : Colors.blue,
                    );
                  }
                  return IconButton(
                    icon: icon,
                    onPressed: () async => await value.toogleLoop(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
