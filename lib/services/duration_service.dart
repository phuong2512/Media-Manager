import 'dart:io';
import 'dart:developer';
import 'package:media_kit/media_kit.dart';

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

      final player = Player();
      await player.open(Media(filePath), play: false);
      final duration = await player.stream.duration.first;
      await player.dispose();

      final formattedDuration = _formatDuration(duration);
      _durationCache[filePath] = {
        'duration': formattedDuration,
        'lastModified': lastModified,
      };

      return formattedDuration;
    } catch (e) {
      log('Error getting media duration for $filePath: $e');
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
