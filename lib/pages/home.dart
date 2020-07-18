import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stereo_beats_main/provider/music_player.dart';
import 'package:stereo_beats_main/utils/default_util.dart';

import '../provider/songItem.dart';
import '../utils/color_util.dart';
import '../utils/text_util.dart';
import '../components/image_builder.dart';
import '../components/mini_player.dart';
import '../components/custum_list_view.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    List<SongItem> songs;
    final mediaQuery = MediaQuery.of(context);
    var viewHeight = mediaQuery.size.height;
    var extraPadding = mediaQuery.padding.top;
    var actualHeight = viewHeight - extraPadding;
    var songProvider = Provider.of<SongProvider>(context, listen: false);
    var _isLandScape = mediaQuery.orientation == Orientation.landscape;
    return FutureBuilder(
      future: songProvider.getSongs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          songs = songProvider.songsFraction;
          return Scaffold(
            backgroundColor: Color(0xffeeeeee),
            body: Stack(
              fit: StackFit.expand,
              children: [
                Column(
                  children: [
                    Container(
                      height: _isLandScape
                          ? actualHeight * 0.4
                          : actualHeight * 0.6,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ImageBuilder(
                            songProvider: songProvider,
                            song: songs[0],
                          ),
                          Positioned(
                            right: 10,
                            top: 15,
                            left: 10,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.menu,
                                    size: TextUtil.large,
                                  ),
                                  onPressed: () {},
                                ),
                                DefaultUtil.appName,
                                IconButton(
                                  icon: Icon(
                                    Icons.search,
                                    size: TextUtil.large,
                                  ),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            left: 0,
                            bottom: 0,
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth: mediaQuery.size.width * 0.6,
                              ),
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(40),
                                ),
                                color: Color(0xffeeeeee),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    songs[0].title,
                                    style: TextUtil.homeSongTitle,
                                    maxLines: 2,
                                    overflow: TextOverflow.fade,
                                  ),
                                  Text(
                                    songs[0].artist,
                                    maxLines: 1,
                                    overflow: TextOverflow.fade,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _BottomSheet(
                          songs: songs, songProvider: songProvider),
                    ),
                  ],
                ),
                Positioned(
                  bottom: 10,
                  left: 10,
                  right: 10,
                  child: Consumer<AudioPlayer>(
                    builder: (context, value, child) => value.miniPlayerPresent
                        ? MiniPlayer(mediaQuery: mediaQuery)
                        : Container(),
                  ),
                ),
              ],
            ),
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _BottomSheet extends StatelessWidget {
  const _BottomSheet({
    Key key,
    @required this.songs,
    @required this.songProvider,
  }) : super(key: key);

  final List<SongItem> songs;
  final SongProvider songProvider;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      maxChildSize: 1,
      initialChildSize: 1,
      expand: false,
      builder: (context, scrollController) => Container(
        padding: EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(100),
          ),
          color: ColorUtil.white,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(100),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 40,
                      top: 10,
                    ),
                    child: Text(
                      "Quick Pick",
                      style: TextUtil.quickPick,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.play_circle_outline,
                      size: TextUtil.large,
                    ),
                    onPressed: () =>
                        Provider.of<AudioPlayer>(context, listen: false)
                            .play(songs),
                  ),
                ],
              ),
              Expanded(
                child: ListView.builder(
                  addAutomaticKeepAlives: true,
                  itemCount: songs.length - 1,
                  itemBuilder: (context, index) {
                    return CustumListView(
                      songProvider: songProvider,
                      song: songs[index + 1],
                      songs: songs,
                      index: index + 1,
                    );
                  },
                ),
              ),
              Consumer<AudioPlayer>(
                builder: (context, value, child) => value.miniPlayerPresent
                    ? SizedBox(
                        height: 73,
                      )
                    : Container(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
