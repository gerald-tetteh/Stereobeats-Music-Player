import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../provider/songItem.dart';
import '../utils/text_util.dart';
import '../provider/music_player.dart';

class QuickPlayOptions extends StatelessWidget {
  const QuickPlayOptions({
    Key key,
    @required this.mediaQuery,
    @required this.provider,
    @required this.songs,
  }) : super(key: key);

  final MediaQueryData mediaQuery;
  final AudioPlayer provider;
  final List<SongItem> songs;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: mediaQuery.size.width * 0.3,
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: FaIcon(
              FontAwesomeIcons.random,
              size: TextUtil.xsmall,
            ),
            onPressed: () async {
              await provider.setShuffle(true);
              await provider.play(songs, 0, true);
            },
          ),
          IconButton(
            icon: FaIcon(
              FontAwesomeIcons.playCircle,
              size: TextUtil.xsmall,
            ),
            onPressed: () async {
              await provider.setShuffle(false);
              await provider.play(songs, 0, false);
            },
          ),
        ],
      ),
    );
  }
}
