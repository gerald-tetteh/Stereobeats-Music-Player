import 'package:flutter/material.dart';

import '../components/image_builder.dart';

class BoxImage extends StatelessWidget {
  const BoxImage({
    Key key,
    @required this.path,
  }) : super(key: key);

  final String path;

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
          path: path,
        ),
      ),
    );
  }
}
