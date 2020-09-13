/*
 * Author: Gerald Addo-Tetteh
 * Stereo Beats Music Player for Android mobile devices.
 * Addo Develop
 * Email: addodevelop@gmail.com
*/

/*
  This is the main file which controlls the application.
  It containes all the routes, primary and secondary themes
  and where app wide providers are created.
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
import './pages/search_view.dart';
import './pages/song_detail_page.dart';
import './pages/search_view_more.dart';
import './pages/edit_song_page.dart';
import './pages/new_feature_page.dart';
import './provider/songItem.dart';
import './provider/music_player.dart';
import './provider/theme_mode.dart';
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
  await Hive.openBox<String>("settings");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // * initializing providers.
    // the SongProvider controls all function relating to a song items,playlists and song infomation.
    // the AudioPlayer handels playing audio, shuffle, loop and songs in queue.
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SongProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => AudioPlayer(),
        ),
        ChangeNotifierProvider(
          create: (_) => AppThemeMode(),
        ),
      ],
      child: Consumer<AppThemeMode>(
        builder: (context, themeProvider, child) => MaterialApp(
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
          darkTheme: ThemeData(
            visualDensity: VisualDensity.adaptivePlatformDensity,
            primaryColor: ColorUtil.purple,
            accentColor: ColorUtil.dark2,
            fontFamily: "Montserrat",
            iconTheme: IconThemeData(
              size: TextUtil.large,
              color: ColorUtil.purple,
            ),
            appBarTheme: AppBarTheme(
              elevation: 0,
              iconTheme: Theme.of(context).iconTheme,
              color: ColorUtil.purple,
            ),
          ),
          themeMode: themeProvider.themeMode,
          home: LoadingScreen(),
          // below are all the predefined routes
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
            SearchView.routeName: (ctx) => SearchView(),
            SearchViewMore.routeName: (ctx) => SearchViewMore(),
            SongDetailPage.routeName: (ctx) => SongDetailPage(),
            EditSongPage.routeName: (ctx) => EditSongPage(),
            NewFeature.routeName: (ctx) => NewFeature(),
          },
        ),
      ),
    );
  }
}
