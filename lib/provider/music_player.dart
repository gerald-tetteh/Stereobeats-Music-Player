import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'songItem.dart';
import '../utils/default_util.dart';
import '../components/page_view_card.dart';

class AudioPlayer with ChangeNotifier {
  SharedPreferences prefs;
  AssetsAudioPlayer audioPlayer = AssetsAudioPlayer.withId("current_player");
  bool miniPlayerPresent = false;
  CarouselController pageController = CarouselController();
  CarouselSlider slider;
  List<SongItem> songsQueue;

  Audio get playing {
    return audioPlayer.current.value.audio.audio;
  }

  void changePageController() {
    slider = CarouselSlider.builder(
      carouselController: pageController,
      itemCount: songsQueue.length,
      itemBuilder: (context, index) {
        return PageViewCard(songsQueue[index]);
      },
      options: CarouselOptions(
        autoPlay: false,
        height: double.infinity,
        viewportFraction: 1,
        enlargeCenterPage: true,
        initialPage:
            findCurrentIndex(audioPlayer.current.value.audio.audio.path),
        onPageChanged: (index, reason) async {
          if (CarouselPageChangedReason.manual == reason) {
            await audioPlayer.playlistPlayAtIndex(index);
            notifyListeners();
          }
        },
      ),
    );
  }

  void changeNotify() {
    changePageController();
    notifyListeners();
  }

  void animateCarousel() {
    pageController.jumpToPage(
        findCurrentIndex(audioPlayer.current.value.audio.audio.path));
  }

  String calculateDuration(int time) {
    final doubleTime = time.toDouble() / 1000;
    final double oneHour = 3.6 * pow(10, 6);
    if (doubleTime < oneHour) {
      final minutes = (doubleTime / 60).floor();
      final seconds = doubleTime - (minutes * 60);
      return "$minutes:${seconds.floor().toString().padLeft(2, '0')}";
    }
    final hours = (doubleTime / (3600)).floor();
    final minutes = ((doubleTime - (hours * 3600)) / 60).floor();
    final seconds = doubleTime - (minutes * 60);
    return "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.floor().toString().padLeft(2, '0')}";
  }

  List<Audio> audioSongs(List<SongItem> songs) {
    return songs
        .map(
          (song) => Audio.file(
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
              image: MetasImage.file(song.artPath),
            ),
          ),
        )
        .toList();
  }

  Future<void> play(List<SongItem> songs,
      [int startIndex = 0, bool shuffle, Duration seekValue]) async {
    audioPlayer.shuffle = shuffle ?? prefs.getBool("shuffle") ?? false;
    songsQueue = songs;
    await audioPlayer.open(
      Playlist(audios: audioSongs(songs)),
      autoStart: false,
      audioFocusStrategy: AudioFocusStrategy.request(
        resumeAfterInterruption: true,
      ),
      loopMode:
          checkLoopMode(prefs.getString("loopMode") ?? "") ?? LoopMode.none,
      showNotification: true,
      headPhoneStrategy: HeadPhoneStrategy.pauseOnUnplug,
      playInBackground: PlayInBackground.enabled,
      notificationSettings: NotificationSettings(
        playPauseEnabled: true,
        nextEnabled: true,
        prevEnabled: true,
        stopEnabled: false,
        customNextAction: (player) => nextTrack(),
        customPrevAction: (player) => previousTrack(),
      ),
    );
    if (startIndex == 0 && shuffle == true) {
      Random rand = Random();
      int randomIndex = rand.nextInt(songs.length);
      audioPlayer.playlistPlayAtIndex(randomIndex);
    } else {
      await audioPlayer.playlistPlayAtIndex(startIndex);
      if (seekValue != null) {
        audioPlayer.seek(seekValue);
      }
    }
    changePageController();
    miniPlayerPresent = true;
    notifyListeners();
    audioPlayer.onReadyToPlay.listen((event) {
      changePageController();
      notifyListeners();
      animateCarousel();
    });
    audioPlayer.onErrorDo = (handler) async {
      Fluttertoast.showToast(
        msg: "File is not supported",
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_SHORT,
      );
      await nextTrack();
    };
  }

  Future<void> playOrPause() async {
    await audioPlayer.playOrPause();
    notifyListeners();
  }

  Future<void> nextTrack() async {
    await audioPlayer.next();
    changePageController();
    notifyListeners();
    animateCarousel();
  }

  Future<void> previousTrack() async {
    await audioPlayer.previous();
    changePageController();
    notifyListeners();
    animateCarousel();
  }

  void seekTrack(double value) {
    audioPlayer.seek(Duration(milliseconds: value.floor()));
  }

  LoopMode checkLoopMode(String mode) {
    if (mode == "single") {
      return LoopMode.single;
    } else if (mode == "all") {
      return LoopMode.playlist;
    } else if (mode == "none") {
      return LoopMode.none;
    }
    return null;
  }

  String saveLoopMode(LoopMode mode) {
    if (mode == LoopMode.none) {
      return "none";
    } else if (mode == LoopMode.playlist) {
      return "all";
    } else if (mode == LoopMode.single) {
      return "single";
    }
    return null;
  }

  Future<void> toogleLopp() async {
    await audioPlayer.toggleLoop();
    await prefs.setString("loopMode", saveLoopMode(audioPlayer.loopMode.value));
  }

  int findCurrentIndex(String path) {
    return audioPlayer.playlist.audios.indexOf(
        audioPlayer.playlist.audios.firstWhere((song) => song.path == path));
  }

  Future<void> changeShuffle() async {
    audioPlayer.toggleShuffle();
    await prefs.setBool("shuffle", audioPlayer.shuffle);
  }

  Future<void> setShuffle(bool value) async {
    audioPlayer.shuffle = value;
    await prefs.setBool("shuffle", audioPlayer.shuffle);
  }

  void setMiniPlayer(bool value) {
    miniPlayerPresent = value;
    notifyListeners();
  }

  void addToQueue(List<SongItem> songs) async {
    songsQueue.addAll(songs);
    var playlist = audioPlayer.playlist.audios;
    playlist.addAll(audioSongs(songs));
    var currentIndex = findCurrentIndex(playing.path);
    var currentPosition = audioPlayer.currentPosition.value;
    await play(songsQueue, currentIndex, null, currentPosition);
  }
}
