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
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
        child: Container(
          padding: EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              StreamBuilder(
                stream: value.audioPlayer.isShuffling,
                initialData: value.prefs.getBool("shuffle"),
                builder: (context, snapshot) {
                  return IconButton(
                    icon: Icon(
                      Icons.shuffle,
                      color: snapshot.data ??
                              value.prefs.getBool("shuffle") ??
                              false
                          ? Colors.blue
                          : Colors.grey,
                    ),
                    onPressed: () async => await value.changeShuffle(),
                  );
                },
              ),
              IconButton(
                  icon: FaIcon(FontAwesomeIcons.stepBackward),
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
                icon: FaIcon(FontAwesomeIcons.stepForward),
                onPressed: () async => await value.nextTrack(),
              ),
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
                      color: Colors.blue,
                    );
                  } else {
                    icon = Icon(
                      Icons.repeat_one,
                      color: Colors.blue,
                    );
                  }
                  return IconButton(
                      icon: icon,
                      onPressed: () async => await value.toogleLoop());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
