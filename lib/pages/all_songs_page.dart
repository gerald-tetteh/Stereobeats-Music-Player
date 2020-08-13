import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../provider/songItem.dart';
import '../utils/color_util.dart';
import '../utils/text_util.dart';
import '../utils/default_util.dart';
import '../components/customDrawer.dart';
import '../provider/music_player.dart';
import '../components/mini_player.dart';
import '../components/dropdown_menu.dart';
import '../components/quick_play_options.dart';
import '../components/bottom_actions_bar.dart';
import '../components/separated_positioned_list.dart';

class AllSongsScreen extends StatelessWidget {
  static const routeName = "/all-songs";
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final provider = Provider.of<AudioPlayer>(context, listen: false);
    final songProvider3 = Provider.of<SongProvider>(context, listen: false);
    GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
    final ItemScrollController itemScrollController = ItemScrollController();
    return Scaffold(
      bottomNavigationBar: Consumer<SongProvider>(
        builder: (context, songProvider, child) {
          return AnimatedContainer(
            child: BottomActionsBar(
              deleteFunction: songProvider.deleteSongs,
              scaffoldKey: _scaffoldKey,
            ),
            duration: Duration(milliseconds: 300),
            curve: Curves.easeIn,
            height: songProvider.showBottonBar ? 59 : 0,
          );
        },
      ),
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
                        onPressed: () {
                          songProvider3.changeBottomBar(false);
                          songProvider3.setQueueToNull();
                          songProvider3.setKeysToNull();
                          _scaffoldKey.currentState.openDrawer();
                        },
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
                        Consumer<SongProvider>(
                          builder: (context, songProvider2, child) {
                            return songProvider2.songs != null &&
                                    songProvider2.songs.length != 0
                                ? _topActionsBar(songProvider2,
                                    itemScrollController, mediaQuery, provider)
                                : Container();
                          },
                        ),
                        Expanded(
                          child: SeparatedPositionedList(
                            itemScrollController: itemScrollController,
                            mediaQuery: mediaQuery,
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

  Row _topActionsBar(
      SongProvider songProvider2,
      ItemScrollController itemScrollController,
      MediaQueryData mediaQuery,
      AudioPlayer provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
          child: CustomDropDown(songProvider2.songs, itemScrollController),
        ),
        QuickPlayOptions(
          mediaQuery: mediaQuery,
          provider: provider,
          songs: songProvider2.songs,
        ),
      ],
    );
  }
}
