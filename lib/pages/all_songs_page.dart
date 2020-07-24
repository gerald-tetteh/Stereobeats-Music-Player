import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/songItem.dart';
import '../utils/color_util.dart';
import '../utils/text_util.dart';
import '../components/custum_list_view.dart';

class AllSongsScreen extends StatelessWidget {
  static const routeName = "/all-songs";
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final songs = Provider.of<SongProvider>(context).songs;
    return Scaffold(
      backgroundColor: Color(0xffeeeeee),
      body: Column(
        children: [
          Container(
            color: Color(0xffeeeeee),
            height: mediaQuery.size.height * 0.2,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(),
                Positioned(
                  top: 19,
                  left: 10,
                  child: Icon(
                    Icons.menu,
                    size: TextUtil.large,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(15, 10, 10, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "All Songs",
                          style: TextUtil.pageHeadingTop,
                        ),
                        Text(
                          "for you",
                          style: TextUtil.pageHeadingBottom,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(70),
                  topRight: Radius.circular(70),
                ),
                color: ColorUtil.white,
              ),
              child: ListView.builder(
                addAutomaticKeepAlives: true,
                itemCount: songs.length,
                itemBuilder: (context, index) {
                  return CustumListView(
                    index: index,
                    song: songs[index],
                    songs: songs,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
