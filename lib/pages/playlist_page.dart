import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qingyin_music/api/api.dart';
import 'package:qingyin_music/models/models.dart';
import 'package:qingyin_music/page_manager.dart';
import 'package:qingyin_music/services/audio_handler.dart';
import 'package:qingyin_music/services/service_locator.dart';

import '../widgets/widgets.dart';

class PlaylistPage extends StatefulWidget {
  const PlaylistPage({super.key});

  @override
  State<PlaylistPage> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  final PlaylistInfo playlist = Get.arguments;
  final pageManager = getIt<PageManager>();

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    var rsp = await getSongs(url: playlist.songsLink);
    pageManager.loadPlaylist(rsp);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.lightBlue.shade800,
            Colors.lightBlue.shade200,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: MyAppBar(
          title: playlist.title,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
          ),
        ),
        body: Flex(
          direction: Axis.vertical,
          children: [
            const AllSongs(),
            ValueListenableBuilder(
                valueListenable: pageManager.showPlayBarNotifier,
                builder: (_, show, __) {
                  return show
                      ? const PlayBar()
                      : const SizedBox(
                          height: 20,
                        );
                }),
          ],
        ),
      ),
    );
  }
}

class AllSongs extends StatefulWidget {
  const AllSongs({
    super.key,
  });

  @override
  State<AllSongs> createState() => _AllSongsState();
}

class _AllSongsState extends State<AllSongs> {
  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();
    return Expanded(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: ShadowContainer(
            width: MediaQuery.of(context).size.width * 0.9,
            height: double.infinity,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(15, 20, 15, 20),
              child: ValueListenableBuilder<List<SongInfo>>(
                valueListenable: pageManager.playlistNotifier,
                builder: (_, songs, __) {
                  return ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: songs.length,
                    itemBuilder: (context, index) {
                      return SingleSong(
                        song: songs[index],
                        index: index,
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SingleSong extends StatefulWidget {
  final SongInfo song;
  final int index;

  const SingleSong({
    super.key,
    required this.song,
    required this.index,
  });

  @override
  State<SingleSong> createState() => _SingleSongState();
}

class _SingleSongState extends State<SingleSong> {
  final double imageRadius = 15;

  final pageManager = getIt<PageManager>();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // if (pageManager.isShuffleModeEnabledNotifier.value) {
        //   int newIndex = pageManager.shuffleIndex(index);
        //   print("[TAG] $newIndex");
        //   Get.toNamed("/song");
        // } else {
        //   Get.toNamed("/song");
        // }
        pageManager.skipToIndex(widget.index);
        pageManager.play();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            SizedBox(
              width: 30,
              child: MyText(
                content: (widget.index + 1).toString().padLeft(3),
                color: Colors.white70,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(imageRadius),
                color: Colors.blue,
              ),
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(imageRadius),
                ),
                child: CachedNetworkImage(
                  placeholder: (context, url) => const CircleAvatar(
                    backgroundColor: Colors.blue,
                  ),
                  imageUrl: widget.song.coverImg,
                  width: MediaQuery.of(context).size.width * 0.12,
                  height: MediaQuery.of(context).size.width * 0.12,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText(content: widget.song.title),
                  MyText(
                    content: widget.song.singer,
                    fontSize: 12,
                    color: Colors.white60,
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                pageManager.skipToIndex(widget.index);
                pageManager.play();
              },
              icon: const Icon(Icons.play_arrow),
              color: Colors.white,
            )
          ],
        ),
      ),
    );
  }
}
