/*
 * Author: Gerald Addo-Tetteh
 * Stereo Beats Music Player for Android mobile devices.
 * Addo Develop
 * Email: addodevelop@gmail.com
 * Box Image (Component)
*/

/*
  This widget returns a square with rounded edges 
  with a n image in the background.
  The path to the image is needed for the widget to build.
  The image path is also passsed to the image builder.
*/

// imports

// package imports
import 'dart:typed_data';

import 'package:flutter/material.dart';

// lib file imports
import '../components/image_builder.dart';

class BoxImage extends StatelessWidget {
  const BoxImage({
    Key? key,
    required this.albumId,
    required this.songId,
  }) : super(key: key);

  final int albumId;
  final int songId;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Color(0xff212121),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: ImageBuilder(
          albumId: albumId,
          songId: songId,
        ),
      ),
    );
  }
}
