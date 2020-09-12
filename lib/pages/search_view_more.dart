/*
 * Author: Gerald Addo-Tetteh
 * Stereo Beats Music Player for Android mobile devices.
 * Addo Develop
 * Email: addodevelop@gmail.com
 * Search View More
*/

/*
  This widget shows the full list of 
  results from the users search.
*/

//imports

// package imports
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// lib file imports
import '../utils/text_util.dart';
import '../utils/color_util.dart';
import '../provider/songItem.dart';
import '../provider/theme_mode.dart';
import '../components/bottom_actions_bar.dart';

class SearchViewMore extends StatelessWidget {
  // name of route
  static const routeName = "/search-view-more";
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  /*
    This widget requires data from the previous widget to build.
    This widget recieves the title =>> "Songs", "Artists", "Albums" and
    a widget would be shown.
    The widget recieved is a list of the results for a particular section
    with some options enabled.
  */
  @override
  Widget build(BuildContext context) {
    final parameters =
        ModalRoute.of(context).settings.arguments as Map<String, Object>;
    final title = parameters["title"] as String;
    final listWidget = parameters["widget"] as Widget;
    final themeProvider = Provider.of<AppThemeMode>(context, listen: false);
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: themeProvider.isDarkMode ? ColorUtil.dark2 : null,
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
        backgroundColor: themeProvider.isDarkMode ? ColorUtil.dark : null,
        iconTheme: Theme.of(context).iconTheme,
        title: Text(
          title,
          style: TextUtil.artistAppBar.copyWith(
            color: themeProvider.isDarkMode ? ColorUtil.white : null,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
            child: Text(
              title,
              style: TextUtil.subHeading.copyWith(
                color: themeProvider.isDarkMode ? ColorUtil.darkTeal : null,
              ),
            ),
          ),
          Divider(
            color: themeProvider.isDarkMode ? ColorUtil.darkTeal : null,
          ),
          listWidget // results list
        ],
      ),
    );
  }
}
