import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';

import '../provider/songItem.dart';

class LoadingPage extends StatefulWidget {
  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  List<SongItem> songs;
  List<dynamic> albumPaths;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: Provider.of<SongProvider>(context, listen: false).getSongs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // Uri albumArtUri =
            //     Uri.parse(Provider.of<SongProvider>(context).song["albumArt"]);
            // return Image.file(
            //   File(Provider.of<SongProvider>(context).song["albumArt"]),
            //   // File(albumArtUri.),
            // );
            print(Provider.of<SongProvider>(context).song);
            String path = "";
            return FutureBuilder(
              future: Provider.of<SongProvider>(context, listen: false)
                  .getAlbumArt(Provider.of<SongProvider>(context, listen: false)
                      .song["albumId"])
                  .then((value) {
                path = value;
                print(value);
              }),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Image.file(File(path));
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            );
          } else {
            return Container(
              color: Color(0xff343d46),
              child: Center(
                child: Text("Getting Music, This May take a while"),
              ),
            );
          }
        },
      ),
    );
  }
}
