/*
 * Author: Gerald Addo-Tetteh
 * Stereo Beats Music Player for Android mobile devices.
 * Addo Develop
 * Email: addodevelop@gmail.com
 * Custom Drawer (Component)
*/

// imports

// package imports
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// lib file imports
import '../utils/default_util.dart';
import '../utils/text_util.dart';
import '../pages/home.dart';
import '../pages/all_songs_page.dart';
import '../pages/favourites_page.dart';
import '../pages/playlist_page.dart';
import '../pages/album_page.dart';
import '../pages/artist_page.dart';
import '../provider/theme_mode.dart';

class CustomDrawer extends StatefulWidget {
  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<AppThemeMode>(context, listen: false);
    var lightThemeGradient = [
      Colors.blue[300],
      Colors.blue[200],
      Colors.blue[100],
      Colors.blue[50],
      Colors.red[50],
      Colors.red[100],
      Colors.red[200],
      Colors.red[300],
    ];
    var darkThemeGradient = [
      Colors.teal[300],
      Colors.teal[200],
      Colors.teal[100],
      Colors.teal[50],
      Colors.purple[50],
      Colors.purple[100],
      Colors.purple[200],
      Colors.purple[300],
    ];
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: themeProvider.isDarkMode
                ? darkThemeGradient
                : lightThemeGradient,
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: ListView(
          children: [
            DrawerHeader(
              padding: EdgeInsets.zero,
              margin: EdgeInsets.zero,
              child: Container(
                alignment: Alignment.topCenter,
                decoration: BoxDecoration(
                  color: Colors.black,
                  image: DecorationImage(
                    alignment: Alignment.centerRight,
                    image: AssetImage("assets/images/app_icon.png"),
                  ),
                ),
                child: Container(
                  child: DefaultUtil.appName,
                  alignment: Alignment.bottomLeft,
                ),
              ),
            ),
            CustomListTile(
              text: "Home",
              iconData: Icons.home,
              // the page the drawer item opens
              function: () => Navigator.of(context)
                  .pushReplacementNamed(HomeScreen.routeName),
            ),
            CustomListTile(
              text: "All Songs",
              iconData: Icons.music_note,
              function: () => Navigator.of(context)
                  .pushReplacementNamed(AllSongsScreen.routeName),
            ),
            CustomListTile(
              text: "Favourites",
              iconData: Icons.favorite,
              function: () => Navigator.of(context)
                  .pushReplacementNamed(FavouritesPage.routeName),
            ),
            CustomListTile(
              text: "Playlists",
              iconData: Icons.library_music,
              function: () => Navigator.of(context)
                  .pushReplacementNamed(PlayListScreen.routeName),
            ),
            CustomListTile(
              text: "Albums",
              iconData: Icons.album,
              function: () => Navigator.of(context)
                  .pushReplacementNamed(AlbumListScreen.routeName),
            ),
            CustomListTile(
              text: "Artists",
              iconData: Icons.person_outline,
              function: () => Navigator.of(context)
                  .pushReplacementNamed(ArtistScreen.routeName),
            ),
            ListTile(
              leading: Icon(
                Icons.invert_colors,
                color: Theme.of(context).primaryColor,
                size: TextUtil.medium,
              ),
              title: Text("Dark Mode"),
              trailing: Switch.adaptive(
                value: themeProvider.isDarkMode,
                onChanged: (value) {
                  if (value) {
                    themeProvider.setThemeMode(AppThemeMode.darkDbkey);
                  } else {
                    themeProvider.setThemeMode(AppThemeMode.lightDbKey);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/*
  This widget returns a list tile showing the
  name of the page and an icon to identify it.
*/
class CustomListTile extends StatelessWidget {
  const CustomListTile({
    Key key,
    @required this.iconData,
    @required this.text,
    @required this.function,
  }) : super(key: key);

  final IconData iconData;
  final String text;
  final Function function;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        leading: Icon(
          iconData,
          color: Theme.of(context).primaryColor,
          size: TextUtil.medium,
        ),
        title: Text(
          text,
        ),
        onTap: () {
          Navigator.of(context).pop();
          function();
        },
      ),
    );
  }
}
