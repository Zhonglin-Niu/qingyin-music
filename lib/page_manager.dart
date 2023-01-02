import 'package:flutter/foundation.dart';
import 'package:qingyin_music/models/models.dart';
import 'package:qingyin_music/services/audio_handler.dart';
import 'api/api.dart';
import 'notifiers/play_button_notifier.dart';
import 'notifiers/progress_notifier.dart';
import 'notifiers/repeat_button_notifier.dart';
import 'package:audio_service/audio_service.dart';
import 'services/service_locator.dart';

class PageManager {
  final _audioHandler = getIt<MyAudioHandler>();
  // Listeners: Updates going to the UI
  final currentSongTitleNotifier = ValueNotifier<String>('');
  final currentSongSingerNotifier = ValueNotifier<String>("");
  final currentSongUrlNotifier = ValueNotifier<String>("");
  final currentSongCoverImgNotifier = ValueNotifier<String>("");
  final playlistNotifier = ValueNotifier<List<SongInfo>>([]);
  final progressNotifier = ProgressNotifier();
  final repeatButtonNotifier = RepeatButtonNotifier();
  final isFirstSongNotifier = ValueNotifier<bool>(true);
  final playButtonNotifier = PlayButtonNotifier();
  final isLastSongNotifier = ValueNotifier<bool>(true);
  final isShuffleModeEnabledNotifier = ValueNotifier<bool>(false);
  final showPlayBarNotifier = ValueNotifier<bool>(false);

  // Events: Calls coming from the UI
  void init() async {
    _listenToChangesInPlaylist();
    _listenToPlaybackState();
    _listenToCurrentPosition();
    _listenToBufferedPosition();
    _listenToTotalDuration();
    _listenToChangesInSong();
  }

  bool get playble => _audioHandler.playble;

  Future<void> loadPlaylist(url) async {
    _audioHandler.clearQueue();
    playlistNotifier.value = []; // 更新 UI
    var songs = await getSongs(url: url);
    final mediaItems = songs
        .map((song) => MediaItem(
              id: song.hashCode.toString(),
              artUri: Uri.parse(song.coverImg),
              title: song.title,
              extras: {'url': song.url},
              artist: song.singer,
            ))
        .toList();
    _audioHandler.addQueueItems(mediaItems);
  }

  void play() => _audioHandler.play();
  void pause() => _audioHandler.pause();
  void seek(Duration position) => _audioHandler.seek(position);
  void previous() => _audioHandler.skipToPrevious();
  void next() => _audioHandler.skipToNext();
  int shuffleIndex(int index) => _audioHandler.shuffleIndex(index);
  void skipToIndex(int index) => _audioHandler.skipToQueueItem(index);
  void repeat() {
    repeatButtonNotifier.nextState();
    final repeatMode = repeatButtonNotifier.value;
    switch (repeatMode) {
      case RepeatState.off:
        _audioHandler.setRepeatMode(AudioServiceRepeatMode.none);
        break;
      case RepeatState.repeatSong:
        _audioHandler.setRepeatMode(AudioServiceRepeatMode.one);
        break;
      case RepeatState.repeatPlaylist:
        _audioHandler.setRepeatMode(AudioServiceRepeatMode.all);
        break;
    }
  }

  void shuffle() {
    final enable = !isShuffleModeEnabledNotifier.value;
    isShuffleModeEnabledNotifier.value = enable;
    if (enable) {
      _audioHandler.setShuffleMode(AudioServiceShuffleMode.all);
    } else {
      _audioHandler.setShuffleMode(AudioServiceShuffleMode.none);
    }
  }

  void add() {}
  void remove() {}
  void dispose() {
    _audioHandler.customAction('dispose');
  }

  void stop() {
    _audioHandler.stop();
  }

  void _listenToChangesInPlaylist() {
    _audioHandler.queue.listen((playlist) {
      if (playlist.isEmpty) {
        playlistNotifier.value = [];
        currentSongTitleNotifier.value = '';
      } else {
        final newList = playlist
            .map((item) => SongInfo(
                coverImg: item.artUri.toString(),
                title: item.title,
                singer: item.artist!,
                url: item.extras?["url"]))
            .toList();
        playlistNotifier.value = newList;
      }
      _updateSkipButtons();
    });
  }

  void _listenToPlaybackState() {
    _audioHandler.playbackState.listen((playbackState) {
      final isPlaying = playbackState.playing;
      final processingState = playbackState.processingState;
      if (processingState == AudioProcessingState.loading ||
          processingState == AudioProcessingState.buffering) {
        playButtonNotifier.value = ButtonState.loading;
      } else if (!isPlaying) {
        playButtonNotifier.value = ButtonState.paused;
      } else if (processingState != AudioProcessingState.completed) {
        playButtonNotifier.value = ButtonState.playing;
      } else {
        _audioHandler.seek(Duration.zero);
        _audioHandler.pause();
      }
    });
  }

  void _listenToCurrentPosition() {
    AudioService.position.listen((position) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: position,
        buffered: oldState.buffered,
        total: oldState.total,
      );
    });
  }

  void _listenToBufferedPosition() {
    _audioHandler.playbackState.listen((playbackState) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: playbackState.bufferedPosition,
        total: oldState.total,
      );
    });
  }

  void _listenToTotalDuration() {
    _audioHandler.mediaItem.listen((mediaItem) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: oldState.buffered,
        total: mediaItem?.duration ?? Duration.zero,
      );
    });
  }

  void _listenToChangesInSong() {
    _audioHandler.mediaItem.listen((mediaItem) {
      // 减少 UI 刷新
      if (currentSongUrlNotifier.value == mediaItem?.extras?["url"]) return;
      pr("mediaitem $mediaItem");
      currentSongTitleNotifier.value = mediaItem?.title ?? '';
      currentSongSingerNotifier.value = mediaItem?.artist ?? '';
      currentSongCoverImgNotifier.value =
          mediaItem?.artUri.toString() ?? currentSongCoverImgNotifier.value;
      currentSongUrlNotifier.value = mediaItem?.extras?["url"] ?? "";
      _updateSkipButtons();
    });
  }

  void updateUI(title) {
    currentSongTitleNotifier.value = title;
  }

  void _updateSkipButtons() {
    final mediaItem = _audioHandler.mediaItem.value;
    final playlist = _audioHandler.queue.value;
    if (playlist.length < 2 || mediaItem == null) {
      isFirstSongNotifier.value = true;
      isLastSongNotifier.value = true;
    } else {
      isFirstSongNotifier.value = playlist.first == mediaItem;
      isLastSongNotifier.value = playlist.last == mediaItem;
    }
  }
}
