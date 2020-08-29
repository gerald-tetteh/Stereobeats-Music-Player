/*
 * Author: Gerald Addo-Tetteh
 * Stereo Beats Music Player for Android mobile devices.
 * Addo Develop
 * Email: addodevelop@gmail.com
 * Image Builder (Component)
*/

/*
  This widget returns the approprite image based
  on the path to the album art provided.
*/

// imports

// package imports
import 'dart:io';

import 'package:flutter/material.dart';

// lib file imports
import '../utils/default_util.dart';

class ImageBuilder extends StatelessWidget {
  ImageBuilder({
    Key key,
    @required this.path,
  }) : super(key: key);

  final String path;

  @override
  Widget build(BuildContext context) {
    return DefaultUtil.checkNotNull(path)
        ? Image.file(
            File(path),
            fit: BoxFit.cover,
          )
        : Image.asset(
            DefaultUtil.defaultImage,
            fit: BoxFit.cover,
          );
  }
}
