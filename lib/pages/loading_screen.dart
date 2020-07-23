import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/songItem.dart';
import 'home.dart';

class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var songProvider = Provider.of<SongProvider>(context, listen: false);
    songProvider.getSongs().then((value) => songProvider.getAllAlbumArt()).then(
        (value) =>
            Navigator.of(context).pushReplacementNamed(HomeScreen.routeName));
    return Center(
      child: CircularProgressIndicator(),
    );
  }
}
