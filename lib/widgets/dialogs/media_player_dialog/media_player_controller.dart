import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:media_manager/models/media.dart' as app_media;

class MediaPlayerController extends ChangeNotifier {
  Player? _player;
  VideoController? _videoController;
  app_media.Media? _currentMedia;
  bool _isPlaying = false;
  bool _isInitialized = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  Player? get player => _player;
  VideoController? get videoController => _videoController;
  app_media.Media? get currentMedia => _currentMedia;
  bool get isPlaying => _isPlaying;
  bool get isInitialized => _isInitialized;
  Duration get position => _position;
  Duration get duration => _duration;
  bool get hasMedia => _currentMedia != null;
  bool get isVideo => _currentMedia?.type == "Video";

  Future<void> playMedia(app_media.Media media) async {
    try {
      await disposePlayer();

      _currentMedia = media;
      _player = Player();

      if (media.type == "Video") {
        _videoController = VideoController(_player!);
      }

      _player!.stream.playing.listen((playing) {
        _isPlaying = playing;
        notifyListeners();
      });

      _player!.stream.position.listen((position) {
        _position = position;
        notifyListeners();
      });

      _player!.stream.duration.listen((duration) {
        _duration = duration;
        notifyListeners();
      });

      await _player!.open(Media(media.path));
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      log('Error playing media: $e');
      _isInitialized = false;
      notifyListeners();
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
    _isPlaying = false;
    notifyListeners();
  }

  Future<void> disposePlayer() async {
    await _player?.dispose();
    _player = null;
    _videoController = null;
    _currentMedia = null;
    _isPlaying = false;
    _isInitialized = false;
    _position = Duration.zero;
    _duration = Duration.zero;
    notifyListeners();
  }


  @override
  Future<void> dispose() async {
    log('MediaPlayerController DISPOSE');
    await disposePlayer();
    super.dispose();
  }
}