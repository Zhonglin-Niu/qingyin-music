import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../notifiers/play_button_notifier.dart';
import '../page_manager.dart';
import '../services/service_locator.dart';
import 'widgets.dart';

class PlayBar extends StatefulWidget {
  const PlayBar({
    super.key,
  });

  @override
  State<PlayBar> createState() => _PlayBarState();
}

class _PlayBarState extends State<PlayBar> {
  final pageManager = getIt<PageManager>();
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.toNamed('/song');
      },
      child: ShadowContainer(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.blue,
              ),
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                // child: CachedNetworkImage(
                //   imageUrl: widget.songInfo.coverImg,
                //   width: MediaQuery.of(context).size.width * 0.15,
                //   height: MediaQuery.of(context).size.width * 0.15,
                //   fit: BoxFit.cover,
                // ),
                child: ValueListenableBuilder(
                  valueListenable: pageManager.currentSongCoverImgNotifier,
                  builder: (_, coverImg, __) {
                    return CachedNetworkImage(
                      imageUrl: coverImg,
                      width: MediaQuery.of(context).size.width * 0.15,
                      height: MediaQuery.of(context).size.width * 0.15,
                      fit: BoxFit.cover,
                    );
                  },
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
                  // MyText(content: widget.songInfo.title),
                  ValueListenableBuilder<String>(
                    valueListenable: pageManager.currentSongTitleNotifier,
                    builder: (_, title, __) {
                      return MyText(content: title);
                    },
                  ),
                  ValueListenableBuilder<String>(
                    valueListenable: pageManager.currentSongSingerNotifier,
                    builder: (_, singer, __) {
                      return MyText(
                        content: singer,
                        fontSize: 12,
                        color: Colors.white60,
                      );
                    },
                  ),
                  // MyText(
                  //   content: widget.songInfo.singer,
                  //   fontSize: 12,
                  //   color: Colors.white60,
                  // ),
                ],
              ),
            ),
            // IconButton(
            //   icon: const Icon(
            //     Icons.play_circle_fill,
            //     size: 30,
            //     color: Colors.white,
            //   ),
            //   onPressed: () {},
            // ),
            ValueListenableBuilder<ButtonState>(
              valueListenable: pageManager.playButtonNotifier,
              builder: (_, value, __) {
                switch (value) {
                  case ButtonState.loading:
                    return Container(
                      margin: const EdgeInsets.all(8.0),
                      width: 30.0,
                      height: 30.0,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    );
                  case ButtonState.paused:
                    return IconButton(
                      icon: const Icon(Icons.play_arrow),
                      color: Colors.white,
                      iconSize: 30.0,
                      onPressed: pageManager.play,
                    );
                  case ButtonState.playing:
                    return IconButton(
                      icon: const Icon(Icons.pause),
                      color: Colors.white,
                      iconSize: 30.0,
                      onPressed: pageManager.pause,
                    );
                }
              },
            ),
            const SizedBox(
              width: 10,
            ),
            const Icon(
              Icons.menu,
              size: 30,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
