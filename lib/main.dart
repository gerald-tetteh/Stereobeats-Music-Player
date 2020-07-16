import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './pages/home.dart';
import './provider/songItem.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SongProvider(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          accentColor: Color(0xff37474f),
          visualDensity: VisualDensity.adaptivePlatformDensity,
          fontFamily: "Montserrat",
        ),
        home: HomeScreen(),
      ),
    );
  }
}
