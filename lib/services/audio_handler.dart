import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

void pr(c) {
  print("[TAG] $c");
}

/// 初始化音频服务
Future<MyAudioHandler> initAudioService() async {
  return await AudioService.init(
    builder: () => MyAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.qingyin.music',
      androidNotificationChannelName: '倾音悦',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );
}

class MyAudioHandler extends BaseAudioHandler {
  final _player = AudioPlayer();
  final _playlist = ConcatenatingAudioSource(children: []);

  bool get playble {
    if (queue.value.isEmpty) {
      return false;
    }
    return true;
  }

  int shuffleIndex(int index) => _player.shuffleIndices![index];

  MyAudioHandler() {
    _loadEmptyPlaylist();
    _notifyAudioHandlerAboutPlaybackEvents();
    _listenForDurationChanges();
    // _listenForCurrentSongIndexChanges();
    _listenForSequenceStateChanges();
  }

  Future<void> _loadEmptyPlaylist() async {
    await _player.setAudioSource(_playlist);
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() => _player.seekToNext();

  @override
  Future<void> skipToPrevious() => _player.seekToPrevious();

  @override
  Future<void> stop() async {
    await _player.stop();
    return super.stop();
  }

  @override
  Future customAction(
    String name, [
    Map<String, dynamic>? extras,
  ]) async {
    if (name == 'dispose') {
      await _player.dispose();
      super.stop();
    }
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    switch (repeatMode) {
      case AudioServiceRepeatMode.none:
        _player.setLoopMode(LoopMode.off);
        break;
      case AudioServiceRepeatMode.one:
        _player.setLoopMode(LoopMode.one);
        break;
      case AudioServiceRepeatMode.group:
      case AudioServiceRepeatMode.all:
        _player.setLoopMode(LoopMode.all);
        break;
    }
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    if (shuffleMode == AudioServiceShuffleMode.none) {
      _player.setShuffleModeEnabled(false);
    } else {
      await _player.shuffle();
      _player.setShuffleModeEnabled(true);
    }
  }

  UriAudioSource _createAudioSource(MediaItem mediaItem) {
    return AudioSource.uri(
      Uri.parse(mediaItem.extras!['url']),
      tag: mediaItem,
    );
  }

  @override
  Future<void> addQueueItems(List<MediaItem> mediaItems) async {
    // manage Just Audio
    final audioSource = mediaItems.map(_createAudioSource);
    _playlist.addAll(audioSource.toList());
    // notify system
    final newQueue = queue.value..addAll(mediaItems); // 双点表示返回这个对象 -> q.value
    queue.add(newQueue);
  }

  void clearQueue() {
    _playlist.clear();
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index < 0 || index >= queue.value.length) return;
    if (_player.shuffleModeEnabled) {
      index = _player.shuffleIndices![index];
    }
    _player.seek(Duration.zero, index: index);
  }

  /// 控制中心 消息中心音乐播放bar
  void _notifyAudioHandlerAboutPlaybackEvents() {
    _player.playbackEventStream.listen((PlaybackEvent event) {
      final playing = _player.playing;
      playbackState.add(playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.stop,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
        },
        androidCompactActionIndices: const [0, 1, 3],
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_player.processingState]!,
        repeatMode: const {
          LoopMode.off: AudioServiceRepeatMode.none,
          LoopMode.one: AudioServiceRepeatMode.one,
          LoopMode.all: AudioServiceRepeatMode.all,
        }[_player.loopMode]!,
        shuffleMode: (_player.shuffleModeEnabled)
            ? AudioServiceShuffleMode.all
            : AudioServiceShuffleMode.none,
        playing: playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: event.currentIndex,
      ));
    });
  }

  void _listenForDurationChanges() {
    // The duration of the current audio.
    _player.durationStream.listen((duration) {
      // 虽然duration有时候会调用两次，但是有时会duration是空值
      // 所以不能限制这个函数的执行次数

      // 如果直接判断 duration 是否为空再 return 的话，会导致已经换歌，但是
      // 歌曲还没加载出来，所以 UI 不刷新的情况
      var index = _player.currentIndex;
      final newQueue = queue.value;
      if (index == null || newQueue.isEmpty) return;

      // shuffleMode player: 花了我十个小时才de出来的bug 绝！
      // 一个个函数打断点，debug，终于发现问题出在这儿，上面的 currentIndex
      // 获取到之后，不需要再获取新的 index 了，因为在 sequence 里面就已经有了
      // 直接更新就好了，currentIndex 默认就是现在在播放的 index
      var newMediaItem = ((_player.sequence?[index].tag) as MediaItem)
          .copyWith(duration: duration);
      newQueue[index] = newMediaItem;
      queue.add(newQueue);
      mediaItem.add(newMediaItem);
      pr("duration change $newMediaItem");
    });
  }

  // duration change 监听函数已经可以满足 UI 刷新的需求了，所以就不需要这个
  // 监听事件了
  // void _listenForCurrentSongIndexChanges() {
  //   _player.currentIndexStream.listen((index) {
  //     if (index == null || queue.value.isEmpty) return;
  //     if (_player.shuffleModeEnabled) {
  //       index = _player.shuffleIndices![index];
  //     }
  //     MediaItem item = _player.sequence?[index].tag;
  //     mediaItem.add(item);
  //     pr("index change $item");
  //   });
  // }

  void _listenForSequenceStateChanges() {
    // 歌单状态改变
    _player.sequenceStateStream.listen((SequenceState? sequenceState) {
      final sequence = sequenceState?.effectiveSequence;
      if (sequence == null || sequence.isEmpty) return;
      final items = sequence.map((source) {
        return (source.tag) as MediaItem;
      });
      queue.add(items.toList());
    });
  }
}
