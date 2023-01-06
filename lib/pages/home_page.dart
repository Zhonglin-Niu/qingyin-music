import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qingyin_music/api/api.dart';
import 'package:qingyin_music/page_manager.dart';
import 'package:qingyin_music/services/audio_handler.dart';
import 'package:qingyin_music/services/service_locator.dart';
import 'package:qingyin_music/storages/storages.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';

// 全局歌单列表
final List<PlaylistInfo> playlists = [];

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    // 初始化 本地简单数据存储器
    await Storage.init();
    final playlistNames = Storage.getList("playlists");
    if (playlistNames != null) {
      for (var name in playlistNames) {
        try {
          var rsp = await getPlayList(path: name);
          // setState 更新数据并更新使用此数据的 UI
          setState(() {
            playlists.add(rsp);
          });
        } catch (e) {
          failInfo(msg: e.toString());
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();
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
            // 不加 const，因为这里面用了全局变量 playlists
            // 加上的话 当 playlists 改变时，UI 不会刷新
            AllPlaylists(),
            ValueListenableBuilder(
              valueListenable: pageManager.showPlayBarNotifier,
              builder: (_, show, __) {
                return show ? const PlayBar() : const SizedBox(height: 20);
              },
            )
          ],
        ),
      ),
    );
  }
}

/// 左上角 Icon
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

class AllPlaylists extends StatefulWidget {
  const AllPlaylists({super.key});

  @override
  State<AllPlaylists> createState() => _AllPlaylistsState();
}

class _AllPlaylistsState extends State<AllPlaylists> {
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
              child: RefreshIndicator(
                /// 下拉刷新事件
                onRefresh: () async {
                  final playlistNames = Storage.getList("playlists");
                  pr(playlistNames);
                  setState(() {
                    playlists.clear();
                  });
                  if (playlistNames == null) return;

                  for (var name in playlistNames) {
                    try {
                      var rsp = await getPlayList(path: name);
                      setState(() {
                        playlists.add(rsp);
                      });
                    } catch (e) {
                      failInfo(msg: e.toString());
                    }
                  }
                },
                // 如果无歌单，就展示text
                child: playlists.isNotEmpty
                    ? ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: playlists.length,
                        itemBuilder: (context, index) {
                          return SinglePlaylist(
                            playlist: playlists[index],
                          );
                        })
                    : ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: 1,
                        itemBuilder: (context, index) {
                          var hasPlaylistNames = Storage.getList("playlists");
                          var text = (hasPlaylistNames == null)
                              ? "当前无歌单\n请在设置里先添加歌单\n然后下拉刷新"
                              : "加载中……";
                          return Center(
                            child: Text(
                              text,
                              style: const TextStyle(
                                fontSize: 30,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        },
                      ),
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
        // 页面跳转
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

/// 应用左滑菜单
class MyDrawer extends StatefulWidget {
  const MyDrawer({super.key});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  void openSetBaseUrlDialog() {
    final controller = TextEditingController();
    Get.defaultDialog(
      title: "设置 BASE_URL",
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("当前 BASE_URL: ${Storage.get("BASE_URL") ?? "无"}"),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: "请输入 BASE_URL，记得在最后加斜杠",
            ),
          ),
        ],
      ),
      buttonColor: Colors.lightGreen,
      textConfirm: "确认",
      confirmTextColor: Colors.white,
      onConfirm: () async {
        /// 先关闭对话框
        Get.back();
        Storage.set("BASE_URL", controller.text.trim());
        successInfo(msg: "当前 BASE_URL 为 ${controller.text}");
      },

      textCancel: "取消",
      cancelTextColor: Colors.blueGrey,

      /// 点击空白区域是否关闭对话框
      barrierDismissible: false,
    );
  }

  void openAddPlaylistDialog() {
    final controller = TextEditingController();
    Get.defaultDialog(
      title: "添加歌单",
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
        ),
      ),
      buttonColor: Colors.lightGreen,
      textConfirm: "确认添加",
      confirmTextColor: Colors.white,
      onConfirm: () async {
        /// 先关闭对话框
        Get.back();

        if (Storage.get("BASE_URL") == null) {
          failInfo(msg: "请先设置 BASE_URL");
          return;
        }

        List<String> playlists_ = Storage.getList("playlists") ?? [];

        if (playlists_.contains(controller.text)) {
          failInfo(msg: "不能添加重复的歌单！");
          return;
        }

        var rst = await PlaylistInfo.validName(controller.text);
        bool valid = rst[0] as bool;
        String title = rst[1] as String;

        if (valid) {
          Storage.set("playlists", playlists_..add(controller.text));
          successInfo(msg: "歌单 $title 添加成功 下拉刷新");
        } else {
          failInfo(msg: "输入信息为 ${controller.text} 请检查您是否输错了");
        }
      },

      textCancel: "取消",
      cancelTextColor: Colors.blueGrey,

      /// 点击空白区域是否关闭对话框
      barrierDismissible: false,
    );
  }

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
            title: const MyText(content: "设置 BASE_URL"),
            onTap: openSetBaseUrlDialog,
          ),
          ListTile(
            title: const MyText(content: "添加歌单"),
            onTap: openAddPlaylistDialog,
          ),
          ListTile(
            title: const MyText(content: "定时关闭"),
            onTap: () {},
          ),
          ListTile(
            title: const MyText(content: "删除所有歌单"),
            onTap: () => Storage.prefs?.clear(),
          ),
        ],
      ),
    );
  }
}
