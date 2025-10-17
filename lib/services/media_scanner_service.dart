import 'dart:io';
import 'package:flutter/material.dart';
import 'package:media_manager/interfaces/media_scanner_interface.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';
import 'package:media_manager/models/media.dart';
import 'package:media_manager/services/duration_service.dart';

class MediaScannerService implements MediaScannerInterface {
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

  final DurationService _durationService;

  MediaScannerService(this._durationService);

  @override
  Future<List<Media>> scanDeviceDirectory() async {
    final hasPermission = await requestStoragePermissions();
    if (!hasPermission) return [];

    final roots = await getCandidateRoots();
    final items = <Media>[];

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

          final duration = await _durationService.getMediaDuration(
            f.path,
            isAudio ? 'Audio' : 'Video',
          );

          items.add(
            Media(
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

  @override
  Future<bool> requestStoragePermissions() async {
    if (await Permission.manageExternalStorage.isGranted) return true;
    final status = await Permission.manageExternalStorage.request();
    if (status.isGranted) return true;

    final storageStatus = await Permission.storage.request();
    return storageStatus.isGranted;
  }

  @override
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
