import 'package:flutter/material.dart';

import '../utils/default_util.dart';
import '../utils/text_util.dart';
import '../components/customDrawer.dart';
import '../components/playlist_&_album_main.dart';
import '../helpers/db_helper.dart';

class PlayListScreen extends StatelessWidget {
  static const routeName = "/playlist-screen";
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme,
        leading: IconButton(
          icon: Icon(
            Icons.menu,
            size: TextUtil.medium,
          ),
          onPressed: () => _scaffoldKey.currentState.openDrawer(),
        ),
        title: DefaultUtil.appName,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      drawer: CustomDrawer(),
      body: PlayListAndAlbum(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => DBHelper.createItem("playLists", "hello"),
      ),
    );
  }
}
