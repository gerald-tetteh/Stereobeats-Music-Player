/*
 * Author: Gerald Addo-Tetteh
 * Stereo Beats Music Player for Android mobile devices.
 * Addo Develop
 * Email: addodevelop@gmail.com
 * Audio Player
*/

/*
  The AudioPlayer plays the audio file found on the device.
  It also controls the notification, visibility of the mini player,
  the page controller for the play page and also calculates the duration
  of a song.
*/

// TODO(CrossFade): Add cross fade for audio player.

// imports

// package imports
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

// lib file imports
import 'songItem.dart';
import '../utils/default_util.dart';
import '../components/page_view_card.dart';

class AudioPlayer with ChangeNotifier {
  // initialized class variables (global)
  SharedPreferences
      prefs; // shared preferences; this is initialized in the loading page
  AssetsAudioPlayer audioPlayer = AssetsAudioPlayer.withId("current_player");
  bool miniPlayerPresent = false;
  CarouselController pageController = CarouselController();
  CarouselSlider slider;
  List<SongItem> songsQueue;

  // returns the current Audio playing.
  Audio get playing {
    return audioPlayer.current.value.audio.audio;
  }

  /*
    This function changes the page controller when
    the song playing is chagened to keep the carousel
    up to date.
  */
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

  // notifies listeners of changes to the carousel
  void changeNotify() {
    changePageController();
    notifyListeners();
  }

  // change the current index of the carousel when it is mouted
  void animateCarousel() {
    try {
      pageController.jumpToPage(
          findCurrentIndex(audioPlayer.current.value.audio.audio.path));
    } catch (e) {
      return;
    }
  }

  /*
    This function changes the duration of a song from 
    milliseconds to => minutes:seconds or hours:minutes:seconds
    depending on the length of the audio file.
  */
  String calculateDuration(int time) {
    /*
      padLeft addes extra zeros to the  value if it
      has length less than 2.
    */
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

  // converts SongItems to Audio.
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

  /*
    This function is used to play an audio file.
    The SongItems provided are converted to Audio and
    passed to the open() function as a playlist.
    The open() function also creats the notification
    to show music is playing. The Audio is passed as a playlist
    in order to create a queue. The index of the song that was clicked 
    is also passed to start playing at the index.

    The equalizer is also initialized here.
    A call back function is also created in case and audio file 
    is incompatible with the device.
  */
  Future<void> play(List<SongItem> songs,
      [int startIndex = 0, bool shuffle = false, Duration seekValue]) async {
    audioPlayer.shuffle = shuffle ?? prefs.getBool("shuffle") ?? false;
    songsQueue = songs;
    Random rand = Random();
    int randomIndex = rand.nextInt(songs.length);
    await audioPlayer.open(
      Playlist(
          audios: audioSongs(songs),
          startIndex: shuffle ? randomIndex : startIndex),
      audioFocusStrategy: AudioFocusStrategy.request(
        resumeAfterInterruption: true,
      ), // the song continues after the interuption.
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
    if (seekValue != null) {
      audioPlayer.seek(seekValue);
    }
    changePageController();
    miniPlayerPresent = true;
    notifyListeners();
    audioPlayer.onReadyToPlay.listen((event) async {
      changePageController();
      notifyListeners();
      animateCarousel();
    });
    // audioPlayer.playlistFinished.listen((event) async {
    //   if (event && audioPlayer.loopMode.value == LoopMode.none) {
    //     await audioPlayer.playlistPlayAtIndex(startIndex);
    //     await audioPlayer.pause();
    //   }
    // });
    audioPlayer.onErrorDo = (handler) async {
      // shows a toast if song can not be played and
      // moves to the next song.
      Fluttertoast.showToast(
        msg: "File is not supported",
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_SHORT,
      );
      await nextTrack();
    };
    // setup eqaulizer
  }

  // plays or pauses a song based on the current state
  // of the player.
  Future<void> playOrPause() async {
    await audioPlayer.playOrPause();
    notifyListeners();
  }

  // moves to the next track and changes the
  // carousel for the play page.
  Future<void> nextTrack() async {
    await audioPlayer.next();
    changePageController();
    notifyListeners();
    animateCarousel();
  }

  // moves to the previous track and changes the
  // carousel for the play page.
  Future<void> previousTrack() async {
    await audioPlayer.previous();
    changePageController();
    notifyListeners();
    animateCarousel();
  }

  // seeks the current song to the position provided
  void seekTrack(double value) {
    audioPlayer.seek(Duration(milliseconds: value.floor()));
  }

  // returns the appropriate LoopMode based on the
  // string provided. Defaults to null.
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

  // returns a string used to identify the LoopMode
  // when it is saved. Defaults to null
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

  // changes to LoopMode based on the current LoopMode.
  Future<void> toogleLoop() async {
    await audioPlayer.toggleLoop();
    await prefs.setString("loopMode", saveLoopMode(audioPlayer.loopMode.value));
  }

  // returns the current index of the song whose path is provided.
  int findCurrentIndex(String path) {
    return audioPlayer.playlist.audios.indexOf(
        audioPlayer.playlist.audios.firstWhere((song) => song.path == path));
  }

  // changes the suffle mode based on the current shuffle state.
  Future<void> changeShuffle() async {
    audioPlayer.toggleShuffle();
    await prefs.setBool("shuffle", audioPlayer.shuffle);
  }

  // changes the shuffle state based on the value provided.
  Future<void> setShuffle(bool value) async {
    audioPlayer.shuffle = value;
    await prefs.setBool("shuffle", audioPlayer.shuffle);
  }

  // changes the visiblility of the miniplayer
  // based on the value provided.
  void setMiniPlayer(bool value) {
    miniPlayerPresent = value;
    notifyListeners();
  }

  // adds the songs provided to the playing queue
  void addToQueue(List<SongItem> songs) async {
    songsQueue.addAll(songs);
    var playlist = audioPlayer.playlist.audios;
    playlist.addAll(audioSongs(songs));
    var currentIndex = findCurrentIndex(playing.path);
    var currentPosition = audioPlayer.currentPosition.value;
    await play(songsQueue, currentIndex, null, currentPosition);
  }
}
