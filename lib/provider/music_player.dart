import 'package:flutter/foundation.dart';
import 'package:assets_audio_player/assets_audio_player.dart';

import 'songItem.dart';
import '../utils/default_util.dart';

class AudioPlayer with ChangeNotifier {
  final audioPlayer = AssetsAudioPlayer.withId("Current_Player");

  List<Audio> audioSongs(List<SongItem> songs) {
    return songs
        .map((song) => Audio.file(
              song.path,
              metas: Metas(
                album: DefaultUtil.checkNotNull(song.album)
                    ? song.album
                    : DefaultUtil.unknown,
                artist: DefaultUtil.checkNotNull(song.artist)
                    ? song.artist
                    : DefaultUtil.unknown,
                title: DefaultUtil.checkNotNull(song.title)
                    ? song.title
                    : DefaultUtil.unknown,
                image: DefaultUtil.checkNotNull(song.artPath)
                    ? MetasImage.file(song.artPath)
                    : MetasImage.asset(DefaultUtil.defaultImage),
              ),
            ))
        .toList();
  }

  Future<void> play(List<SongItem> songs, [int startIndex = 0]) async {
    await audioPlayer.open(
      Playlist(audios: audioSongs(songs), startIndex: startIndex),
      showNotification: true,
      headPhoneStrategy: HeadPhoneStrategy.pauseOnUnplug,
      notificationSettings: NotificationSettings(
        playPauseEnabled: true,
        nextEnabled: true,
        prevEnabled: true,
        stopEnabled: true,
      ),
    );
    await audioPlayer.play();
  }

  Future<void> playOrPause() async {
    await audioPlayer.playOrPause();
  }

  Future<void> nextTrack() async {
    await audioPlayer.next();
  }

  Future<void> previousTrack() async {
    await audioPlayer.previous();
  }
}
