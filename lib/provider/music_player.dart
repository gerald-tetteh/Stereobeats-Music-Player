import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'songItem.dart';
import '../utils/default_util.dart';
import '../components/page_view_card.dart';

class AudioPlayer with ChangeNotifier {
  final audioPlayer = AssetsAudioPlayer.withId("Current_Player");
  bool miniPlayerPresent = false;
  CarouselController pageController = CarouselController();
  CarouselSlider slider;
  List<SongItem> songsQueue;
  final songProvider = SongProvider();

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
        onPageChanged: (index, reason) async =>
            CarouselPageChangedReason.manual == reason
                ? await audioPlayer.playlistPlayAtIndex(index)
                : null,
      ),
    );
  }

  void animateCarousel() {
    pageController.animateToPage(
      findCurrentIndex(audioPlayer.current.value.audio.audio.path),
      curve: Curves.easeInOut,
      duration: Duration(milliseconds: 300),
    );
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
    songsQueue = songs;
    return songsQueue
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

  Future<void> play(List<SongItem> songs, [int startIndex = 0]) async {
    await audioPlayer.open(
      Playlist(audios: audioSongs(songs), startIndex: startIndex),
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
    await audioPlayer.play();
    miniPlayerPresent = true;
    changePageController();
    audioPlayer.onReadyToPlay.listen((event) {
      changePageController();
      notifyListeners();
      animateCarousel();
    });
    notifyListeners();
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

  void seekTrack(double value) async {
    audioPlayer.seek(Duration(milliseconds: value.floor()));
  }

  int findCurrentIndex(String path) {
    return audioPlayer.playlist.audios.indexOf(
        audioPlayer.playlist.audios.firstWhere((song) => song.path == path));
  }
}
