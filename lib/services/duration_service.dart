import 'dart:io';
import 'dart:developer';
import 'package:just_audio/just_audio.dart';
import 'package:video_player/video_player.dart';

class DurationService {
  final Map<String, Map<String, dynamic>> _durationCache = {};

  Future<String> getMediaDuration(String filePath, String type) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return '00:00';
      }

      final stat = await file.stat();
      final lastModified = stat.modified;

      if (_durationCache.containsKey(filePath)) {
        final cached = _durationCache[filePath]!;
        if (cached['lastModified'] == lastModified) {
          return cached['duration'] as String;
        }
      }

      String duration = '00:00';
      if (type == 'Audio') {
        duration = await _getAudioDuration(filePath);
      } else if (type == 'Video') {
        duration = await _getVideoDuration(filePath);
      }

      _durationCache[filePath] = {
        'duration': duration,
        'lastModified': lastModified,
      };

      return duration;
    } catch (e) {
      log('Error getting media duration for $filePath: $e');
      return '00:00';
    }
  }

  // audio
  Future<String> _getAudioDuration(String filePath) async {
    try {
      final player = AudioPlayer();
      await player.setFilePath(filePath);
      final duration = player.duration ?? Duration.zero;
      await player.dispose();
      return _formatDuration(duration);
    } catch (e) {
      log('Error getting audio duration: $e');
      return '00:00';
    }
  }

  // video
  Future<String> _getVideoDuration(String filePath) async {
    try {
      final controller = VideoPlayerController.file(File(filePath));
      await controller.initialize();
      final duration = controller.value.duration;
      await controller.dispose();
      return _formatDuration(duration);
    } catch (e) {
      log('Error getting video duration: $e');
      return '00:00';
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
