/*
 * Author: Gerald Addo-Tetteh
 * Stereo Beats Music Player for Android mobile devices.
 * Addo Develop
 * Email: addodevelop@gmail.com
 * New Feature
*/

/*
  This widget shows the features in the new
  update.
*/

// imports
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:intro_slider/slide_object.dart';

import '../utils/color_util.dart';
import '../utils/text_util.dart';
import '../utils/default_util.dart';

import 'home.dart';

class NewFeature extends StatelessWidget {
  static const routeName = "/new-feature";
  final box = Hive.box<String>("settings");
  final _slides = <Slide>[
    // creats a slide object
    Slide(
      title: "DARK MODE IS HERE !",
      maxLineTitle: 2,
      styleTitle: TextStyle(
        color: ColorUtil.purple,
        fontSize: TextUtil.small,
        fontWeight: FontWeight.bold,
      ),
      description:
          "The new Stereobeats includes dark mode to enhance your listening experience.",
      pathImage: "assets/images/darkMode_1.png",
      backgroundColor: ColorUtil.dark,
      styleDescription: TextStyle(
        fontSize: TextUtil.xsmall,
        fontWeight: FontWeight.w300,
        color: ColorUtil.white,
      ),
      heightImage: 350,
      widthImage: 350,
    ),
    Slide(
      title: "DARK MODE IS HERE !",
      maxLineTitle: 2,
      styleTitle: TextStyle(
        color: ColorUtil.purple,
        fontSize: TextUtil.small,
        fontWeight: FontWeight.bold,
      ),
      description: "Just hit the switch",
      pathImage: "assets/images/darkMode_4.png",
      backgroundColor: ColorUtil.dark,
      styleDescription: TextStyle(
        fontSize: TextUtil.xsmall,
        fontWeight: FontWeight.w300,
        color: ColorUtil.white,
      ),
      heightImage: 350,
      widthImage: 350,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // after the user looks at the update
    // it is saved in the data base to prevent it from showing.
    void onDone() {
      box.put("updateCode", DefaultUtil.versionCode);
      Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
    }

    return IntroSlider(
      slides: _slides,
      onDonePress: onDone,
    );
  }
}
