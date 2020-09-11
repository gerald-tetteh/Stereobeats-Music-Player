/*
 * Author: Gerald Addo-Tetteh
 * Stereo Beats Music Player for Android mobile devices.
 * Addo Develop
 * Email: addodevelop@gmail.com
 * Theme Mode
*/

/*
  This class controls the theme of the 
  app. (Dark or light)
*/

// imports

// package imports
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

class AppThemeMode with ChangeNotifier {
  final _box = Hive.box<String>("settings");
  final _lightTheme = ThemeMode.light;
  final _darkTheme = ThemeMode.dark;
  final _systemTheme = ThemeMode.system;
  final themeDbKey = "theme_mode";
  static const lightDbKey = "light";
  static const darkDbkey = "dark";

  // This getter returs the theme
  ThemeMode get themeMode {
    var themeMode = _box.get(themeDbKey);
    if (themeMode == lightDbKey) {
      return _lightTheme;
    } else if (themeMode == darkDbkey) {
      return _darkTheme;
    }
    return _systemTheme;
  }

  // returns true is dark mode is active, false otherwise
  bool get isDarkMode => themeMode == _darkTheme;

  // sets the new theme mode and updates app
  Future<void> setThemeMode(String themeKey) async {
    await _box.put(themeDbKey, themeKey);
    notifyListeners();
  }
}
