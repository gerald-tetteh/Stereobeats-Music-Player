import 'package:flutter/material.dart';
import 'package:empty_widget/empty_widget.dart';

import 'text_util.dart';

class DefaultUtil {
  static const defaultImage = "assets/images/default-image.png";
  static const unknown = "Unknown";
  static const emptyImage = "assets/images/empty_image.webp";

  static bool checkNotNull(String value) {
    if (value != null && value.length != 0) {
      return true;
    }
    return false;
  }

  static bool checkNotAsset(String path) {
    if (path == null || path.contains("assets/images")) {
      return false;
    }
    return true;
  }

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

  static Widget empty(String text, [String subText]) {
    return EmptyListWidget(
      image: DefaultUtil.emptyImage,
      title: text,
      titleTextStyle: TextUtil.emptyTitle,
      subTitle: subText,
      subtitleTextStyle: TextUtil.emptySubTitle,
    );
  }
}
