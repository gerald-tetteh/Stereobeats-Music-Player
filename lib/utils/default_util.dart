/*
 * Author: Gerald Addo-Tetteh
 * Stereo Beats Music Player for Android mobile devices.
 * Addo Develop
 * Email: addodevelop@gmail.com
 * DefaultUtil
*/

/*
  The DefaultUtil containes constants and some functions that 
  are used to check if a string is null or has a length of zero.
  Its also containes commonly used text and images.
*/

// imports

// package imports
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:empty_widget/empty_widget.dart';

// lib file imports
import 'text_util.dart';
import 'color_util.dart';

class DefaultUtil {
  // constant values for images ans null values
  static const defaultImage = "assets/images/default-image.png";
  static const unknown = "Unknown";
  static const emptyImage = "assets/images/empty_image.webp";
  static const versionCode = "1.3.1";

  /*
    This function returns true if the parameters entered is
    not null or has a length greater that zero.
    Returns false otherwise.
  */
  static bool checkNotNull(String? value) {
    if (value != null && value.length != 0) {
      return true;
    }
    return false;
  }

  /*
    This function returns true if the parameters entered is
    not null or has a length greater that zero.
    Returns false otherwise.
  */
  static bool checkListNotNull(Uint8List? value) {
    if (value != null && value.length != 0) {
      return true;
    }
    return false;
  }

  /*
    This function return true if the string provided contains
    "assets/images" indicating its is a local asset and false 
    otherwise.
  */
  static bool checkNotAsset(String? path) {
    if (path == null || path.contains("assets/images")) {
      return false;
    }
    return true;
  }

  /*
    This is the styled app name.
  */
  static final appName = RichText(
    text: TextSpan(
      text: "Stereo",
      style: TextStyle(
        fontFamily: "Grenze",
        fontSize: TextUtil.large,
        color: Colors.blue,
      ),
      children: [
        TextSpan(
          text: "beats",
          style: TextStyle(
            fontFamily: "Montserrat",
            fontSize: TextUtil.small,
            fontStyle: FontStyle.italic,
            color: Colors.red,
          ),
        ),
      ],
    ),
  );

  /*
    This is the widget that is retured if a widget is not provided with 
    the data it needs and can not be built without throwing a runtime error.
  */
  static Widget empty(String text, [String? subText]) {
    return EmptyWidget(
      image: DefaultUtil.emptyImage,
      title: text,
      titleTextStyle: TextUtil.emptyTitle,
      subTitle: subText,
      subtitleTextStyle: TextUtil.emptySubTitle,
    );
  }

  /*
    This is the widget that is retured if a widget is not provided with 
    the data it needs and can not be built without throwing a runtime error.
    (DarkMode)
  */
  static Widget emptyDarkMode(String text, [String? subText]) {
    return CircleAvatar(
      backgroundColor: ColorUtil.dark2,
      maxRadius: 160,
      minRadius: 50,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            constraints: BoxConstraints(
              maxHeight: 100,
              maxWidth: 90,
            ),
            child: Image.asset(DefaultUtil.emptyImage),
          ),
          Text(text),
          if (subText != null) Text(subText),
        ],
      ),
    );
  }
}
