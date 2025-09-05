import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:media_manager/models/media.dart';

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

  Future<List<Media>> scanAll() async {
    final hasPermission = await _requestStoragePermissions();
    if (!hasPermission) {
      return [];
    }

    final roots = await _getCandidateRoots();
    final files = <File>[];
    for (final dir in roots) {
      if (await dir.exists()) {
        files.addAll(_listMediaFilesRecursive(dir));
      }
    }

    final items = <Media>[];
    for (final f in files) {
      final stat = await f.stat();
      final ext = p.extension(f.path).toLowerCase();
      final isAudio = _audioExtension.contains(ext);
      final isVideo = _videoExtension.contains(ext);
      if (!isAudio && !isVideo) continue;
      items.add(
        Media(
          path: f.path,
          duration: '00:00',
          size: stat.size,
          lastModified: stat.modified,
          type: isAudio ? 'Audio' : 'Video',
        ),
      );
    }
    return items;
  }

  Future<bool> _requestStoragePermissions() async {
    if (await Permission.manageExternalStorage.isGranted) {
      return true;
    }
    final status = await Permission.manageExternalStorage.request();
    if (status.isGranted) {
      return true;
    }
    final storageStatus = await Permission.storage.request();
    return storageStatus.isGranted;
  }

  Future<List<Directory>> _getCandidateRoots() async {
    final result = <Directory>[];
    final downloads = Directory('/storage/emulated/0/Download');
    final music = Directory('/storage/emulated/0/Music');
    final movies = Directory('/storage/emulated/0/Movies');
    final dcim = Directory('/storage/emulated/0/DCIM');
    result.addAll([downloads, music, movies, dcim]);
    final extDirs = await getExternalStorageDirectories();
    if (extDirs != null) {
      result.addAll(extDirs);
    }
    return result;
  }

  List<File> _listMediaFilesRecursive(Directory dir) {
    final collected = <File>[];
    for (final entity in dir.listSync(recursive: true, followLinks: false)) {
      //Liệt kê tất cả các tệp và thư mục con trong thư mục
      if (entity is File) {
        final ext = p.extension(entity.path).toLowerCase();
        if (_audioExtension.contains(ext) || _videoExtension.contains(ext)) {
          collected.add(entity);
        }
      }
    }
    return collected;
  }
}
