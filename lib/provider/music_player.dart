import 'package:flutter/foundation.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';

import 'songItem.dart';
import '../utils/default_util.dart';

class AudioPlayer with ChangeNotifier {
  final audioPlayer = AssetsAudioPlayer.withId("Current_Player");
  bool miniPlayerPresent = false;
  PageController pageController;
  List<SongItem> songsQueue;

  Audio get playing {
    return audioPlayer.current.value.audio.audio;
  }

  List<Audio> audioSongs(List<SongItem> songs) {
    songsQueue = songs;
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
        stopEnabled: false,
        customNextAction: (player) => nextTrack(),
        customPrevAction: (player) => previousTrack(),
      ),
    );
    await audioPlayer.play();
    audioPlayer.playlistAudioFinished.listen((event) {
      pageController = PageController(
        initialPage:
            findCurrentIndex(audioPlayer.current.value.audio.audio.path),
        keepPage: false,
        viewportFraction: 0.8,
      );
    });
    miniPlayerPresent = true;
    pageController = PageController(
      initialPage: findCurrentIndex(audioPlayer.current.value.audio.audio.path),
      keepPage: false,
      viewportFraction: 0.8,
    );
    notifyListeners();
  }

  Future<void> playOrPause() async {
    await audioPlayer.playOrPause();
    notifyListeners();
  }

  Future<void> nextTrack() async {
    await audioPlayer.next();
    pageController = PageController(
      initialPage: findCurrentIndex(audioPlayer.current.value.audio.audio.path),
      keepPage: false,
      viewportFraction: 0.8,
    );
    notifyListeners();
  }

  Future<void> previousTrack() async {
    await audioPlayer.previous();
    pageController = PageController(
      initialPage: findCurrentIndex(audioPlayer.current.value.audio.audio.path),
      keepPage: false,
      viewportFraction: 0.8,
    );
    notifyListeners();
  }

  int findCurrentIndex(String path) {
    return audioPlayer.playlist.audios.indexOf(
        audioPlayer.playlist.audios.firstWhere((song) => song.path == path));
  }
}
