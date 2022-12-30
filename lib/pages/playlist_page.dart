import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qingyin_music/api/api.dart';
import 'package:qingyin_music/models/models.dart';

import '../widgets/widgets.dart';

class PlaylistPage extends StatefulWidget {
  const PlaylistPage({super.key});

  @override
  State<PlaylistPage> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  final PlaylistInfo playlist = Get.arguments;

  late List<SongInfo> songs = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    var rsp = await getSongs(url: playlist.songsLink);
    setState(() {
      songs = rsp;
    });
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
            AllSongs(songs: songs),
            const PlayBar(),
          ],
        ),
      ),
    );
  }
}

class AllSongs extends StatelessWidget {
  const AllSongs({
    super.key,
    required this.songs,
  });

  final List<SongInfo> songs;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: ShadowContainer(
            width: MediaQuery.of(context).size.width * 0.9,
            height: double.infinity,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(15, 20, 15, 20),
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: songs.length,
                itemBuilder: (context, index) {
                  return SingleSong(
                    song: songs[index],
                    index: index + 1,
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

class SingleSong extends StatelessWidget {
  final SongInfo song;
  final int index;

  const SingleSong({
    super.key,
    required this.song,
    required this.index,
  });

  final double imageRadius = 15;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.toNamed("/song", arguments: song);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            SizedBox(
              width: 30,
              child: MyText(
                content: index.toString().padLeft(3),
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
                  imageUrl: song.coverImg,
                  width: MediaQuery.of(context).size.width * 0.12,
                  height: MediaQuery.of(context).size.width * 0.12,
                  fit: BoxFit.cover,
                ),
                // child: Image.network(
                //   song.coverImg,
                //   width: MediaQuery.of(context).size.width * 0.12,
                //   height: MediaQuery.of(context).size.width * 0.12,
                //   fit: BoxFit.cover,
                // ),
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
                  MyText(content: song.title),
                  MyText(
                    content: song.singer,
                    fontSize: 12,
                    color: Colors.white60,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.play_arrow,
              color: Colors.white,
            )
          ],
        ),
      ),
    );
  }
}
