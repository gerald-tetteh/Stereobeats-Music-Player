/*
  * Author: Gerald Addo-Tetteh
  * StereoBeats Music Player
  * Search View
*/

//imports

//package imports
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//local imports
import '../utils/text_util.dart';
import '../provider/songItem.dart';
import '../components/bottom_actions_bar.dart';

class SearchViewMore extends StatelessWidget {
  static const routeName = "/search-view-more";
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    final parameters =
        ModalRoute.of(context).settings.arguments as Map<String, Object>;
    final title = parameters["title"] as String;
    final listWidget = parameters["widget"] as Widget;
    return Scaffold(
      key: _scaffoldKey,
      bottomNavigationBar: Consumer<SongProvider>(
        builder: (context, songProvider, child) {
          return AnimatedContainer(
            child: BottomActionsBar(
              scaffoldKey: _scaffoldKey,
              deleteFunction: songProvider.deleteSongs,
            ),
            duration: Duration(milliseconds: 400),
            curve: Curves.easeIn,
            height: songProvider.showBottonBar ? 59 : 0,
          );
        },
      ),
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme,
        title: Text(
          title,
          style: TextUtil.artistAppBar,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
            child: Text(
              title,
              style: TextUtil.subHeading,
            ),
          ),
          Divider(),
          listWidget
        ],
      ),
    );
  }
}
