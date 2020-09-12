/*
 * Author: Gerald Addo-Tetteh
 * Stereo Beats Music Player for Android mobile devices.
 * Addo Develop
 * Email: addodevelop@gmail.com
 * Slider and Duration (Component)
*/

/*
  This widget renders a slider showing the current position on the 
  song playing and the duration below the slider.
*/

//imports

// package imports
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:assets_audio_player/assets_audio_player.dart';

// lib file imports
import '../provider/music_player.dart';
import '../provider/theme_mode.dart';
import '../utils/color_util.dart';

class SliderAndDuration extends StatelessWidget {
  const SliderAndDuration({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<AppThemeMode>(context, listen: false);
    return Consumer<AudioPlayer>(
      builder: (context, provider, child) {
        final songDuration = provider
            .songsQueue[provider.findCurrentIndex(provider.playing.path)]
            .duration;
        // the PlayBuilder updates every second in sync with the current song.
        return PlayerBuilder.currentPosition(
          player: provider.audioPlayer,
          builder: (context, position) {
            final songPosition = position.inMilliseconds ?? 0;
            // converts songPosition from milliseconds => minutes:seconds || hours:minutes:seconds
            final calculatedPosition = provider.calculateDuration(songPosition);
            return Container(
              child: Column(
                children: [
                  Slider(
                    inactiveColor: themeProvider.isDarkMode
                        ? ColorUtil.darkTeal.withOpacity(0.5)
                        : null,
                    activeColor:
                        themeProvider.isDarkMode ? ColorUtil.darkTeal : null,
                    value: songPosition.toDouble(),
                    min: 0,
                    max: double.parse(songDuration),
                    onChanged: (value) {
                      provider.seekTrack(value);
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(23, 0, 23, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          calculatedPosition ?? "0:00",
                          style: themeProvider.isDarkMode
                              ? TextStyle(color: ColorUtil.purple)
                              : TextStyle(color: Colors.blueAccent),
                        ),
                        Text(
                          provider
                              .calculateDuration(int.parse(songDuration))
                              .toString(),
                          style: themeProvider.isDarkMode
                              ? TextStyle(color: ColorUtil.purple)
                              : TextStyle(color: Colors.blueAccent),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
