import 'package:flutter/material.dart';

class TextUtil {
  static const double xsmall = 19;
  static const double small = 24;
  static const double medium = 30;
  static const double large = 35;

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
  );
}
