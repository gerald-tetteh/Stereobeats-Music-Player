/*
 * Author: Gerald Addo-Tetteh
 * Stereo Beats Music Player for Android mobile devices.
 *  AddoDevelop
 * Email: addodevelop@gmail.com
*/

// imports

// package imports
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

// lib file imports
import './pages/home.dart';
import './pages/loading_screen.dart';
import './pages/all_songs_page.dart';
import './pages/favourites_page.dart';
import './pages/playlist_page.dart';
import './pages/add_to_page.dart';
import './pages/add_to_playlist.dart';
import './pages/playlist_detail_screen.dart';
import './pages/album_page.dart';
import './pages/artist_page.dart';
import './pages/artist_view_page.dart';
import './pages/album_detail_screen.dart';
import './provider/songItem.dart';
import './provider/music_player.dart';
import './pages/play_page.dart';
import './utils/text_util.dart';
import './utils/color_util.dart';
import './models/playlist.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // * initialize hive db and open db's.
  await Hive.initFlutter("steroBeatsData");
  Hive.registerAdapter(PlayListAdapter());
  await Hive.openBox<PlayList>("playLists");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // * initializing providers.
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
        debugShowCheckedModeBanner: false,
        title: 'Stereobeats',
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
          FavouritesPage.routeName: (ctx) => FavouritesPage(),
          PlayListScreen.routeName: (ctx) => PlayListScreen(),
          PlaylistDetailScreen.routeName: (ctx) => PlaylistDetailScreen(),
          AddToPage.routeName: (ctx) => AddToPage(),
          AddToPlayListPage.routeName: (ctx) => AddToPlayListPage(),
          AlbumListScreen.routeName: (ctx) => AlbumListScreen(),
          AlbumDetailScreen.routeName: (ctx) => AlbumDetailScreen(),
          ArtistScreen.routeName: (ctx) => ArtistScreen(),
          ArtistViewScreen.routeName: (ctx) => ArtistViewScreen(),
        },
      ),
    );
  }
}
