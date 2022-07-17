/*
 * Author: Gerald Addo-Tetteh
 * Stereo Beats Music Player for Android mobile devices.
 * Addo Develop
 * Email: addodevelop@gmail.com
 * Audio Player
*/

import 'dart:io';

import 'package:flutter/material.dart';

/// Custom scroll behavior for android
class CustomScrollBehavior extends ScrollBehavior {
  final int sdkVersion;

  CustomScrollBehavior(this.sdkVersion);

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    if (Platform.isAndroid) {
      if (sdkVersion > 30) {
        return StretchingOverscrollIndicator(
          axisDirection: details.direction,
          child: child,
        );
      }
      return child;
    } else {
      return child;
    }
  }
}
