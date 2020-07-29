import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
        ChangeNotifierProvider(
          create: (_) => AudioPlayer(),
        ),
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
