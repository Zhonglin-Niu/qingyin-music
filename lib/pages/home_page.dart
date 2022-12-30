import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qingyin_music/api/api.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final playlistNames = ["__Songs.json", "__Masterpiece.json"];
  final List<PlaylistInfo> playlists = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    for (var name in playlistNames) {
      var rsp = await getPlayList(path: name);
      setState(() {
        playlists.add(rsp);
      });
    }
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
        backgroundColor: const Color.fromRGBO(0, 0, 0, 0),
        appBar: const MyAppBar(
          leading: OpenDrawerIcon(),
        ),
        drawer: const MyDrawer(),
        body: Flex(
          direction: Axis.vertical,
          children: [
            AllPlaylists(playlists: playlists),
            const PlayBar(),
          ],
        ),
      ),
    );
  }
}

class OpenDrawerIcon extends StatelessWidget {
  const OpenDrawerIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(
        Icons.menu,
        color: Colors.white,
      ),
      onPressed: Scaffold.of(context).openDrawer,
    );
  }
}

class AllPlaylists extends StatelessWidget {
  const AllPlaylists({
    super.key,
    required this.playlists,
  });

  final List<PlaylistInfo> playlists;

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
                itemCount: playlists.length,
                itemBuilder: (context, index) {
                  return SinglePlaylist(
                    playlist: playlists[index],
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

class SinglePlaylist extends StatelessWidget {
  final PlaylistInfo playlist;
  const SinglePlaylist({
    super.key,
    required this.playlist,
  });

  final double imageRadius = 15;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.toNamed("/playlist", arguments: playlist);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
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
                  imageUrl: playlist.coverImg,
                  width: MediaQuery.of(context).size.width * 0.15,
                  height: MediaQuery.of(context).size.width * 0.15,
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
                  MyText(content: playlist.title),
                  MyText(
                    content: "${playlist.songs} 首",
                    fontSize: 12,
                    color: Colors.white60,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.menu,
              color: Colors.white,
            )
          ],
        ),
      ),
    );
  }
}

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 1,
      backgroundColor: Colors.lightBlue.shade800,
      child: ListView(
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey,
                  width: 1,
                ),
              ),
            ),
            child: SizedBox(
              height: 72,
              child: DrawerHeader(
                child: MyText(content: "设置", fontSize: 24),
              ),
            ),
          ),
          ListTile(
            title: const MyText(content: "定时关闭"),
            onTap: () {
              // Handle the tap event for item 1
            },
          ),
        ],
      ),
    );
  }
}
