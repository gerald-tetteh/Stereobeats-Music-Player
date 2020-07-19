import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/songItem.dart';
import 'home.dart';

class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var songProvider = Provider.of<SongProvider>(context, listen: false);
    return FutureBuilder(
      future: songProvider.getSongs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return FutureBuilder(
            future: songProvider.getAllAlbumArt(),
            builder: (context, snapshot2) {
              if (snapshot2.connectionState == ConnectionState.done) {
                return HomeScreen();
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
