import 'dart:async';
import 'dart:developer';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:media_manager/features/media/domain/entities/media.dart'
    as app_media;

class MediaPlayerController {

  final StreamController<bool> _isPlayingController = StreamController<bool>.broadcast();
  final StreamController<bool> _isInitializedController = StreamController<bool>.broadcast();
  final StreamController<Duration> _positionController = StreamController<Duration>.broadcast();
  final StreamController<Duration> _durationController = StreamController<Duration>.broadcast() ;


  Player? _player;
  VideoController? _videoController;
  app_media.Media? _currentMedia;
  bool _isPlaying = false;
  bool _isInitialized = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  MediaPlayerController() {
    log('✅ MediaPlayerController INIT');
    _emitIsPlaying(false);
    _emitIsInitialized(false);
    _emitPosition(Duration.zero);
    _emitDuration(Duration.zero);
  }


  Stream<bool> get isPlayingStream => _isPlayingController.stream;

  Stream<bool> get isInitializedStream => _isInitializedController.stream;

  Stream<Duration> get positionStream => _positionController.stream;

  Stream<Duration> get durationStream => _durationController.stream;

  VideoController? get videoController => _videoController;

  app_media.Media? get currentMedia => _currentMedia;

  bool get isPlaying => _isPlaying;

  bool get isInitialized => _isInitialized;

  Duration get position => _position;

  Duration get duration => _duration;

  bool get isVideo => _currentMedia?.type == "Video";

  void _emitIsPlaying(bool playing) {
    _isPlaying = playing;
    if (!_isPlayingController.isClosed) {
      _isPlayingController.add(playing);
    }
  }

  void _emitIsInitialized(bool initialized) {
    _isInitialized = initialized;
    if (!_isInitializedController.isClosed) {
      _isInitializedController.add(initialized);
    }
  }

  void _emitPosition(Duration pos) {
    _position = pos;
    if (!_positionController.isClosed) {
      _positionController.add(pos);
    }
  }

  void _emitDuration(Duration dur) {
    _duration = dur;
    if (!_durationController.isClosed) {
      _durationController.add(dur);
    }
  }

  Future<void> playMedia(app_media.Media media) async {
    try {
      await disposePlayer();

      _currentMedia = media;
      _player = Player();

      if (media.type == "Video") {
        _videoController = VideoController(_player!);
      }

      _player!.stream.playing.listen((playing) {
        _emitIsPlaying(playing);
      });

      _player!.stream.position.listen((position) {
        _emitPosition(position);
      });

      _player!.stream.duration.listen((duration) {
        _emitDuration(duration);
      });

      await _player!.open(Media(media.path));
      _emitIsInitialized(true);
    } catch (e) {
      log('Error playing media: $e');
      _emitIsInitialized(false);
    }
  }

  Future<void> togglePlayPause() async {
    if (_player == null) return;
    await _player!.playOrPause();
  }

  Future<void> seek(Duration position) async {
    if (_player == null) return;
    await _player!.seek(position);
  }

  Future<void> stop() async {
    if (_player == null) return;
    await _player!.stop();
    _emitIsPlaying(false);
  }

  Future<void> disposePlayer() async {
    await _player?.dispose();
    _player = null;
    _videoController = null;
    _currentMedia = null;

    _emitIsPlaying(false);
    _emitIsInitialized(false);
    _emitPosition(Duration.zero);
    _emitDuration(Duration.zero);
  }

  Future<void> dispose() async {
    log('❌ MediaPlayerController DISPOSE');
    await disposePlayer();
    _isPlayingController.close();
    _isInitializedController.close();
    _positionController.close();
    _durationController.close();
  }
}
