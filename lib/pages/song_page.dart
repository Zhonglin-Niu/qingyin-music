import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qingyin_music/models/models.dart';
import 'package:qingyin_music/widgets/widgets.dart';
import '../notifiers/notifiers.dart';

class SongPage extends StatefulWidget {
  const SongPage({super.key});

  @override
  State<SongPage> createState() => _SongPageState();
}

class _SongPageState extends State<SongPage> {
  SongInfo song = Get.arguments;
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
          title: song.title,
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
                  padding: const EdgeInsets.all(7),
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                          MediaQuery.of(context).size.width * 0.6),
                    ),
                    child: CachedNetworkImage(
                      placeholder: (context, url) => const MyText(
                        content: "Loading...",
                      ),
                      imageUrl: song.coverImg,
                      width: MediaQuery.of(context).size.width * 0.6,
                      height: MediaQuery.of(context).size.width * 0.6,
                      fit: BoxFit.cover,
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
    final progressNotifier = ProgressNotifier();
    return ValueListenableBuilder<ProgressBarState>(
      valueListenable: progressNotifier,
      builder: (_, value, __) {
        return ShadowContainer(
          width: MediaQuery.of(context).size.width * 0.9,
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          child: ProgressBar(
            progress: value.current,
            buffered: value.buffered,
            total: value.total,
            onSeek: (Duration position) {
              print(position);
            },
          ),
        );
      },
    );
  }
}

class RepeatButton extends StatelessWidget {
  const RepeatButton({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final repeatButtonNotifier = RepeatButtonNotifier();
    return ValueListenableBuilder<RepeatState>(
      valueListenable: repeatButtonNotifier,
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
          onPressed: () {},
        );
      },
    );
  }
}

class PreviousSongButton extends StatelessWidget {
  const PreviousSongButton({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final isFirstSongNotifier = ValueNotifier<bool>(true);
    return ValueListenableBuilder<bool>(
      valueListenable: isFirstSongNotifier,
      builder: (_, isFirst, __) {
        return IconButton(
          icon: const Icon(
            Icons.skip_previous,
            color: Colors.white,
          ),
          onPressed: (isFirst) ? null : () {},
        );
      },
    );
  }
}

class PlayButton extends StatelessWidget {
  const PlayButton({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final playButtonNotifier = PlayButtonNotifier();
    return ValueListenableBuilder<ButtonState>(
      valueListenable: playButtonNotifier,
      builder: (_, value, __) {
        switch (value) {
          case ButtonState.loading:
            return Container(
              margin: const EdgeInsets.all(8.0),
              width: 32.0,
              height: 32.0,
              child: const CircularProgressIndicator(),
            );
          case ButtonState.paused:
            return IconButton(
              icon: const Icon(
                Icons.play_arrow,
                color: Colors.white,
              ),
              iconSize: 32.0,
              onPressed: () {},
            );
          case ButtonState.playing:
            return IconButton(
              icon: const Icon(
                Icons.pause,
                color: Colors.white,
              ),
              iconSize: 32.0,
              onPressed: () {},
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
    final isLastSongNotifier = ValueNotifier<bool>(true);
    return ValueListenableBuilder<bool>(
      valueListenable: isLastSongNotifier,
      builder: (_, isLast, __) {
        return IconButton(
          icon: const Icon(
            Icons.skip_next,
            color: Colors.white,
          ),
          onPressed: (isLast) ? null : () {},
        );
      },
    );
  }
}

class ShuffleButton extends StatelessWidget {
  const ShuffleButton({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final isShuffleModeEnabledNotifier = ValueNotifier<bool>(false);
    return ValueListenableBuilder<bool>(
      valueListenable: isShuffleModeEnabledNotifier,
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
          onPressed: () {},
        );
      },
    );
  }
}
