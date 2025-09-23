import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:media_manager/models/media.dart';
import 'package:media_manager/services/duration_service.dart';

class MediaScannerService {
  static const _audioExtension = [
    '.mp3',
    '.m4a',
    '.wav',
    '.aac',
    '.flac',
    '.ogg',
  ];
  static const _videoExtension = [
    '.mp4',
    '.mkv',
    '.mov',
    '.avi',
    '.webm',
    '.3gp',
  ];

  final DurationService _durationService;

  MediaScannerService(this._durationService);

  Future<List<Media>> scanAll() async {
    final hasPermission = await _requestStoragePermissions();
    if (!hasPermission) return [];

    final roots = await _getCandidateRoots();
    final items = <Media>[];

    for (final dir in roots) {
      if (await dir.exists()) {
        final paths = await _listMediaFilesRecursiveAsync(dir.path);

        for (final path in paths) {
          final f = File(path);
          if (!await f.exists()) continue;

          final stat = await f.stat();
          final ext = p.extension(f.path).toLowerCase();
          final isAudio = _audioExtension.contains(ext);
          final isVideo = _videoExtension.contains(ext);
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

  Future<bool> _requestStoragePermissions() async {
    if (await Permission.manageExternalStorage.isGranted) return true;
    final status = await Permission.manageExternalStorage.request();
    if (status.isGranted) return true;

    final storageStatus = await Permission.storage.request();
    return storageStatus.isGranted;
  }

  Future<List<Directory>> _getCandidateRoots() async {
    final result = <Directory>[];
    result.addAll([
      Directory('/storage/emulated/0/Download'),
      Directory('/storage/emulated/0/Music'),
      Directory('/storage/emulated/0/Movies'),
    ]);
    final extDirs = await getExternalStorageDirectories();
    if (extDirs != null) {
      result.addAll(extDirs);
    }
    return result;
  }

  static Future<List<String>> _listMediaFilesRecursiveAsync(
    String dirPath,
  ) async {
    final collected = <String>[];
    final dir = Directory(dirPath);

    try {
      await for (final entity in dir.list(
        recursive: true,
        followLinks: false,
      )) {
        if (entity is File) {
          final ext = p.extension(entity.path).toLowerCase();
          if (_audioExtension.contains(ext) || _videoExtension.contains(ext)) {
            collected.add(entity.path);
          }
        }
      }
    } catch (e) {
      debugPrint('Error: $e');
    }

    return collected;
  }
}
