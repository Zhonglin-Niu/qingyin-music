import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qingyin_music/models/models.dart';

import 'widgets.dart';

class PlayBar extends StatelessWidget {
  final SongInfo songInfo;
  const PlayBar({
    super.key,
    required this.songInfo,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.toNamed('/song', arguments: songInfo);
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
                child: CachedNetworkImage(
                  imageUrl: songInfo.coverImg,
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
                  MyText(content: songInfo.title),
                  MyText(
                    content: songInfo.singer,
                    fontSize: 12,
                    color: Colors.white60,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.play_circle_fill,
              size: 30,
              color: Colors.white,
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
