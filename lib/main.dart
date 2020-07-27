import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:carousel_slider/carousel_controller.dart';

import './pages/home.dart';
import './pages/loading_screen.dart';
import './pages/all_songs_page.dart';
import './provider/songItem.dart';
import './provider/music_player.dart';
import './pages/play_page.dart';
import './utils/text_util.dart';
import './utils/color_util.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SongProvider(),
        ),
        ChangeNotifierProxyProvider<SongProvider, AudioPlayer>(
            update: (ctx, songProvider, oldProvider) {
          return AudioPlayer(
            prefs: oldProvider != null ? oldProvider.prefs : songProvider.prefs,
            audioPlayer: AssetsAudioPlayer.withId("current_player"),
            miniPlayerPresent:
                oldProvider != null ? oldProvider.miniPlayerPresent : false,
            pageController: oldProvider != null
                ? oldProvider.pageController
                : CarouselController(),
            slider: oldProvider != null ? oldProvider.slider : null,
            songsQueue: oldProvider != null ? oldProvider.songsQueue : null,
          );
        }),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primaryColor: Color(0xff1565c0),
          accentColor: Colors.black,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          fontFamily: "Montserrat",
          iconTheme: IconThemeData(
            color: Color(0xff1565c0),
            size: TextUtil.large,
          ),
          appBarTheme: AppBarTheme(
            elevation: 0,
            iconTheme: Theme.of(context).iconTheme,
            color: ColorUtil.white,
          ),
        ),
        home: LoadingScreen(),
        routes: {
          PlayMusicScreen.routeName: (ctx) => PlayMusicScreen(),
          HomeScreen.routeName: (ctx) => HomeScreen(),
          AllSongsScreen.routeName: (ctx) => AllSongsScreen(),
        },
      ),
    );
  }
}
