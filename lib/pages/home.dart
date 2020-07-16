import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/songItem.dart';
import '../utils/color_util.dart';
import '../utils/text_util.dart';
import '../utils/default_util.dart';
import '../components/image_builder.dart';
import '../components/box_image.dart';

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
    var songProvider = Provider.of<SongProvider>(context);
    return FutureBuilder(
      future: songProvider.getSongs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          songs = songProvider.songsFraction;
          return Scaffold(
            backgroundColor: Color(0xffeeeeee),
            body: Column(
              children: [
                Container(
                  height: actualHeight * 0.6,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ImageBuilder(
                        songProvider: songProvider,
                        song: songs[0],
                      ),
                      Positioned(
                        top: 15,
                        left: 10,
                        child: IconButton(
                          icon: Icon(
                            Icons.menu,
                            size: TextUtil.large,
                          ),
                          onPressed: () {},
                        ),
                      ),
                      Positioned(
                        top: 15,
                        right: 10,
                        child: IconButton(
                          icon: Icon(
                            Icons.search,
                            size: TextUtil.large,
                          ),
                          onPressed: () {},
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
                              ),
                              Text(
                                songs[0].artist,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 45,
                        right: (mediaQuery.size.width - TextUtil.large) * 0.2,
                        child: IconButton(
                          icon: Icon(
                            Icons.play_circle_filled,
                            size: 70,
                          ),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _BottomSheet(songs: songs, songProvider: songProvider),
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
            children: [
              Expanded(
                child: ListView.builder(
                  addAutomaticKeepAlives: true,
                  itemCount: songs.length - 1,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: BoxImage(
                        songProvider: songProvider,
                        song: songs[index + 1],
                      ),
                      title: Text(
                        DefaultUtil.checkNotNull(songs[index].title)
                            ? songs[index + 1].title
                            : DefaultUtil.unknown,
                      ),
                      subtitle: Text(
                          DefaultUtil.checkNotNull(songs[index].artist)
                              ? songs[index + 1].artist
                              : DefaultUtil.unknown),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
