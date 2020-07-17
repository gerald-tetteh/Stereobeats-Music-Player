import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './pages/home.dart';
import './provider/songItem.dart';
import './provider/music_player.dart';

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
          primarySwatch: Colors.blue,
          accentColor: Color(0xff37474f),
          visualDensity: VisualDensity.adaptivePlatformDensity,
          fontFamily: "Montserrat",
          iconTheme: IconThemeData(
            color: Theme.of(context).accentColor,
          ),
        ),
        home: HomeScreen(),
      ),
    );
  }
}
