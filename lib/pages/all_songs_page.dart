import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../components/box_image.dart';
import '../provider/songItem.dart';
import '../utils/color_util.dart';
import '../utils/text_util.dart';
import '../utils/default_util.dart';
import '../components/customDrawer.dart';
import '../provider/music_player.dart';
import '../components/mini_player.dart';
import '../components/dropdown_menu.dart';

class AllSongsScreen extends StatelessWidget {
  static const routeName = "/all-songs";
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final provider = Provider.of<AudioPlayer>(context, listen: false);
    final songs = Provider.of<SongProvider>(context, listen: false).songs;
    GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
    final ItemScrollController itemScrollController = ItemScrollController();
    return Scaffold(
      backgroundColor: Color(0xffeeeeee),
      drawer: CustomDrawer(),
      key: _scaffoldKey,
      appBar: AppBar(
        title: DefaultUtil.appName,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.menu,
                          size: TextUtil.medium,
                        ),
                        onPressed: () => _scaffoldKey.currentState.openDrawer(),
                      ),
                      Text(
                        "All Tracks",
                        style: TextUtil.pageHeadingTop,
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.search,
                          size: TextUtil.medium,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: ColorUtil.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: const Radius.circular(30),
                      topRight: const Radius.circular(30),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: const Radius.circular(30),
                      topRight: const Radius.circular(30),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
                              child:
                                  CustomDropDown(songs, itemScrollController),
                            ),
                            Container(
                              width: mediaQuery.size.width * 0.3,
                              padding: const EdgeInsets.all(8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
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
                            ),
                          ],
                        ),
                        Expanded(
                          child: ScrollablePositionedList.separated(
                            itemCount: songs.length,
                            addAutomaticKeepAlives: true,
                            itemScrollController: itemScrollController,
                            separatorBuilder: (context, index) =>
                                index != songs.length - 1
                                    ? Divider(
                                        indent: mediaQuery.size.width * (1 / 4),
                                      )
                                    : "",
                            itemBuilder: (context, index) {
                              return ListTile(
                                leading: BoxImage(
                                  path: songs[index].artPath,
                                ),
                                title: Text(
                                  DefaultUtil.checkNotNull(songs[index].title)
                                      ? songs[index].title
                                      : DefaultUtil.unknown,
                                ),
                                subtitle: Text(
                                  DefaultUtil.checkNotNull(songs[index].artist)
                                      ? songs[index].artist
                                      : DefaultUtil.unknown,
                                ),
                                onTap: () => Provider.of<AudioPlayer>(context,
                                        listen: false)
                                    .play(songs, index),
                                trailing: IconButton(
                                  icon: Icon(Icons.more_vert),
                                  onPressed: () {},
                                ),
                              );
                            },
                          ),
                        ),
                        Consumer<AudioPlayer>(
                          builder: (context, value, child) =>
                              value.miniPlayerPresent
                                  ? SizedBox(
                                      height: 73,
                                    )
                                  : Container(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 10,
            left: 3,
            right: 3,
            child: Consumer<AudioPlayer>(
              builder: (context, value, child) => value.miniPlayerPresent
                  ? MiniPlayer(mediaQuery: mediaQuery)
                  : Container(),
            ),
          ),
        ],
      ),
    );
  }
}
