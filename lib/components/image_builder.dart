import 'dart:io';

import 'package:flutter/material.dart';

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
