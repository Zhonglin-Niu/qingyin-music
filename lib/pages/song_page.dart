import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:qingyin_music/widgets/widgets.dart';
import '../notifiers/notifiers.dart';
import '../page_manager.dart';
import '../services/service_locator.dart';

class SongPage extends StatefulWidget {
  const SongPage({super.key});

  @override
  State<SongPage> createState() => _SongPageState();
}

class _SongPageState extends State<SongPage> {
  final pageManager = getIt<PageManager>();
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
        appBar: MyDynaMicAppBar(
          title: ValueListenableBuilder(
              valueListenable: pageManager.currentSongTitleNotifier,
              builder: (_, title, __) {
                return MyText(
                  content: title,
                  fontSize: 18,
                );
              }),
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
        body: Column(
          children: [
            Expanded(
              child: Center(
                child: ShadowContainer(
                  circularRadius: MediaQuery.of(context).size.width * 0.6,
                  padding:
                      EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
                  shadowBg: const Color.fromARGB(255, 42, 108, 128),
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                          MediaQuery.of(context).size.width * 0.6),
                    ),
                    child: ValueListenableBuilder(
                      valueListenable: pageManager.currentSongCoverImgNotifier,
                      builder: (_, coverImg, __) {
                        return coverImg == ""
                            ? Container(
                                width: MediaQuery.of(context).size.width * 0.6,
                                height: MediaQuery.of(context).size.width * 0.6,
                                color: Colors.black12,
                              )
                            : CachedNetworkImage(
                                placeholder: (context, url) => const MyText(
                                  content: "Loading...",
                                ),
                                imageUrl: coverImg,
                                width: MediaQuery.of(context).size.width * 0.6,
                                height: MediaQuery.of(context).size.width * 0.6,
                                fit: BoxFit.cover,
                              );
                      },
                    ),
                  ),
                ),
              ),
            ),
            const AudioProgressBar(),
            const SizedBox(height: 20),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ShadowContainer(child: const RepeatButton()),
                  ShadowContainer(child: const PreviousSongButton()),
                  ShadowContainer(child: const PlayButton()),
                  ShadowContainer(child: const NextSongButton()),
                  ShadowContainer(child: const ShuffleButton()),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class AudioProgressBar extends StatelessWidget {
  const AudioProgressBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();

    return ShadowContainer(
      width: MediaQuery.of(context).size.width * 0.9,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: ValueListenableBuilder<ProgressBarState>(
        valueListenable: pageManager.progressNotifier,
        builder: (_, value, __) {
          return ProgressBar(
            progress: value.current,
            buffered: value.buffered,
            total: value.total,
            onSeek: pageManager.seek,
          );
        },
      ),
    );
  }
}

class RepeatButton extends StatelessWidget {
  const RepeatButton({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();
    return ValueListenableBuilder<RepeatState>(
      valueListenable: pageManager.repeatButtonNotifier,
      builder: (context, value, child) {
        Icon icon;
        switch (value) {
          case RepeatState.off:
            icon = const Icon(Icons.repeat, color: Colors.grey);
            break;
          case RepeatState.repeatSong:
            icon = const Icon(
              Icons.repeat_one,
              color: Colors.white,
            );
            break;
          case RepeatState.repeatPlaylist:
            icon = const Icon(
              Icons.repeat,
              color: Colors.white,
            );
            break;
        }
        return IconButton(
          icon: icon,
          onPressed: pageManager.repeat,
        );
      },
    );
  }
}

class PreviousSongButton extends StatelessWidget {
  const PreviousSongButton({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();
    return ValueListenableBuilder<bool>(
      valueListenable: pageManager.isFirstSongNotifier,
      builder: (_, isFirst, __) {
        return IconButton(
          icon: const Icon(
            Icons.skip_previous,
            color: Colors.white,
          ),
          onPressed: (isFirst) ? null : pageManager.previous,
        );
      },
    );
  }
}

class PlayButton extends StatelessWidget {
  const PlayButton({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();
    return ValueListenableBuilder<ButtonState>(
      valueListenable: pageManager.playButtonNotifier,
      builder: (_, value, __) {
        switch (value) {
          case ButtonState.loading:
            return Container(
              margin: const EdgeInsets.all(8.0),
              width: 32.0,
              height: 32.0,
              child: const CircularProgressIndicator(
                color: Colors.white,
              ),
            );
          case ButtonState.paused:
            return IconButton(
              icon: const Icon(
                Icons.play_arrow,
                color: Colors.white,
              ),
              iconSize: 32.0,
              onPressed: pageManager.play,
            );
          case ButtonState.playing:
            return IconButton(
              icon: const Icon(
                Icons.pause,
                color: Colors.white,
              ),
              iconSize: 32.0,
              onPressed: pageManager.pause,
            );
        }
      },
    );
  }
}

class NextSongButton extends StatelessWidget {
  const NextSongButton({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();
    return ValueListenableBuilder<bool>(
      valueListenable: pageManager.isLastSongNotifier,
      builder: (_, isLast, __) {
        return IconButton(
          icon: const Icon(
            Icons.skip_next,
            color: Colors.white,
          ),
          onPressed: (isLast) ? null : pageManager.next,
        );
      },
    );
  }
}

class ShuffleButton extends StatelessWidget {
  const ShuffleButton({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();
    return ValueListenableBuilder<bool>(
      valueListenable: pageManager.isShuffleModeEnabledNotifier,
      builder: (context, isEnabled, child) {
        return IconButton(
          icon: (isEnabled)
              ? const Icon(
                  Icons.shuffle,
                  color: Colors.white,
                )
              : const Icon(
                  Icons.shuffle,
                  color: Colors.grey,
                ),
          onPressed: pageManager.shuffle,
        );
      },
    );
  }
}
