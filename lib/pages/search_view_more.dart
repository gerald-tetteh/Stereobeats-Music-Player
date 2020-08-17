/*
  * Author: Gerald Addo-Tetteh
  * StereoBeats Music Player
  * Search View
*/

//imports

//package imports
import 'package:flutter/material.dart';

//local imports
import '../utils/text_util.dart';

class SearchViewMore extends StatelessWidget {
  static const routeName = "/search-view-more";
  @override
  Widget build(BuildContext context) {
    final parameters =
        ModalRoute.of(context).settings.arguments as Map<String, Object>;
    final title = parameters["title"] as String;
    final listWidget = parameters["widget"] as Widget;
    return Scaffold(
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
