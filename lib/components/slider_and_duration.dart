import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:assets_audio_player/assets_audio_player.dart';

import '../provider/music_player.dart';
import '../utils/color_util.dart';

class SliderAndDuration extends StatelessWidget {
  const SliderAndDuration({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioPlayer>(
      builder: (context, provider, child) {
        final songDuration = provider
            .songsQueue[provider.findCurrentIndex(provider.playing.path)]
            .duration;
        return PlayerBuilder.currentPosition(
          player: provider.audioPlayer,
          builder: (context, position) {
            final songPosition = position.inMilliseconds ?? 0;
            final calculatedPosition = provider.calculateDuration(songPosition);
            return Container(
              child: Column(
                children: [
                  Slider(
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
                          style: TextStyle(color: ColorUtil.white),
                        ),
                        Text(
                          provider
                              .calculateDuration(int.parse(songDuration))
                              .toString(),
                          style: TextStyle(color: ColorUtil.white),
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
