import 'package:flutter/material.dart';

import 'color_util.dart';

class TextUtil {
  static const double xsmall = 19;
  static const double small = 24;
  static const double medium = 30;
  static const double large = 35;
  static const double xlarge = 45;

  static const TextStyle homeSongTitle = TextStyle(
    fontFamily: "Grenze",
    fontSize: TextUtil.xsmall,
  );
  static const TextStyle quickPick = TextStyle(
    fontFamily: "Grenze",
    fontSize: TextUtil.medium,
  );
  static const TextStyle mutedText = TextStyle(
    fontSize: 15,
    color: Color(0xff9e9e9e),
  );
  static const TextStyle playPageTitle = TextStyle(
    fontSize: TextUtil.small,
    fontFamily: "Grenze",
    color: ColorUtil.white,
  );
  static const TextStyle pageHeadingTop = TextStyle(
    fontSize: TextUtil.small,
    color: Color(0xff212121),
    fontFamily: "Grenze",
  );
  static const TextStyle playlistCardTitle = TextStyle(
    fontFamily: "Grenze",
    fontSize: TextUtil.small,
  );
  static const TextStyle addPageHeadings = TextStyle(
    fontFamily: "Grenze",
    fontSize: TextUtil.xsmall,
  );
  static const TextStyle emptyTitle = TextStyle(
    fontSize: TextUtil.small,
    fontWeight: FontWeight.w300,
  );
  static const TextStyle emptySubTitle = TextStyle(
    fontSize: TextUtil.xsmall,
    fontWeight: FontWeight.w300,
  );
  static const TextStyle albumTitle = TextStyle(
    fontSize: TextUtil.xsmall,
  );
  static const TextStyle subHeading = TextStyle(
    fontSize: TextUtil.small,
    color: ColorUtil.dark,
    fontWeight: FontWeight.w300,
    letterSpacing: 2,
  );
  static const TextStyle artistAppBar = TextStyle(
    color: ColorUtil.dark,
  );
  static const TextStyle loadingScreenCredit1 = TextStyle(
    color: Colors.red,
  );
  static const TextStyle loadingScreenCredit2 = TextStyle(
    color: Colors.blue,
  );
  static const TextStyle search = TextStyle(
    color: Colors.white,
  );
}
