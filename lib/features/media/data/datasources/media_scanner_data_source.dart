import 'dart:io';
import 'package:flutter/material.dart';
import 'package:media_manager/features/media/data/datasources/duration_data_source.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';
import 'package:media_manager/features/media/data/models/media.dart';

class MediaScannerDataSource {
  static const _audioExtensions = [
    '.mp3',
    '.m4a',
    '.wav',
    '.aac',
    '.flac',
    '.ogg',
  ];
  static const _videoExtensions = [
    '.mp4',
    '.mkv',
    '.mov',
    '.avi',
    '.webm',
    '.3gp',
  ];

  final DurationDataSource _durationDataSource;

  MediaScannerDataSource(this._durationDataSource);

  Future<List<MediaModel>> scanDeviceDirectory() async {
    final hasPermission = await requestStoragePermissions();
    if (!hasPermission) return [];

    final roots = await getCandidateRoots();
    final items = <MediaModel>[];

    for (final dir in roots) {
      if (await dir.exists()) {
        final paths = await _getMediaFilePaths(dir.path);

        for (final path in paths) {
          final f = File(path);
          if (!await f.exists()) continue;

          final stat = await f.stat();
          final ext = p.extension(f.path).toLowerCase();
          final isAudio = _audioExtensions.contains(ext);
          final isVideo = _videoExtensions.contains(ext);
          if (!isAudio && !isVideo) continue;

          final duration = await _durationDataSource.getMediaDuration(
            f.path,
            isAudio ? 'Audio' : 'Video',
          );

          items.add(
            MediaModel(
              path: f.path,
              duration: duration,
              size: stat.size,
              lastModified: stat.modified,
              type: isAudio ? 'Audio' : 'Video',
            ),
          );
        }
      }
    }

    return items;
  }

  Future<bool> requestStoragePermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
      Permission.audio,
      Permission.videos,
    ].request();
    if (statuses[Permission.storage] == PermissionStatus.granted) {
      return true;
    }if (statuses[Permission.audio] == PermissionStatus.granted &&
        statuses[Permission.videos] == PermissionStatus.granted) {
      return true;
    }
    return false;
  }

  Future<List<Directory>> getCandidateRoots() async {
    final result = <Directory>[];
    result.addAll([
      Directory('/storage/emulated/0/Download'),
      Directory('/storage/emulated/0/Music'),
      Directory('/storage/emulated/0/Movies'),
    ]);
    return result;
  }

  static Future<List<String>> _getMediaFilePaths(String dirPath) async {
    final dir = Directory(dirPath);
    final extensions = {..._audioExtensions, ..._videoExtensions};
    try {
      return await dir
          .list(recursive: true, followLinks: false)
          .where(
            (e) =>
                e is File &&
                extensions.contains(p.extension(e.path).toLowerCase()),
          )
          .map((e) => e.path)
          .toList();
    } catch (e) {
      debugPrint('Error scanning $dirPath: $e');
      return [];
    }
  }
}
