import 'package:flutter/material.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../provider/music_player.dart';

class PlayPageControls extends StatelessWidget {
  const PlayPageControls({
    Key key,
    @required this.value,
  }) : super(key: key);

  final AudioPlayer value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 7, 15, 15),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
        child: Container(
          padding: EdgeInsets.all(15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(Icons.shuffle),
                onPressed: () {},
              ),
              IconButton(
                  icon: FaIcon(FontAwesomeIcons.stepBackward),
                  onPressed: () async => await value.previousTrack()),
              PlayerBuilder.playerState(
                player: value.audioPlayer,
                builder: (context, playerState) => IconButton(
                  icon: (playerState == PlayerState.pause)
                      ? FaIcon(FontAwesomeIcons.play)
                      : FaIcon(FontAwesomeIcons.pause),
                  onPressed: () async => await value.playOrPause(),
                ),
              ),
              IconButton(
                icon: FaIcon(FontAwesomeIcons.stepForward),
                onPressed: () async => await value.nextTrack(),
              ),
              IconButton(
                icon: Icon(Icons.repeat),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
