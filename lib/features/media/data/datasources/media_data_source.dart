import 'dart:io';
import 'dart:developer';
import 'package:media_manager/features/media/data/datasources/media_scanner_data_source.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:media_manager/features/media/data/models/media.dart';

class MediaDataSource {
  final MediaScannerDataSource _scanner;

  MediaDataSource({required MediaScannerDataSource scanner})
    : _scanner = scanner;

  Future<bool> checkPermissions() async {
    if (await Permission.manageExternalStorage.isGranted) return true;
    final status = await Permission.manageExternalStorage.request();
    if (status.isGranted) return true;
    return (await Permission.storage.request()).isGranted;
  }

  Future<bool> deleteMedia(String path) async {
    try {
      final hasPermission = await checkPermissions();
      if (!hasPermission) return false;
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      log('Error deleting: $e');
      return false;
    }
  }

  Future<MediaModel?> renameMedia(MediaModel media, String newName) async {
    try {
      final hasPermission = await checkPermissions();
      if (!hasPermission) return null;
      final file = File(media.path);
      if (!await file.exists()) return null;
      final dir = file.parent.path;
      final ext = media.path.split('.').last;
      final newPath = '$dir/$newName.$ext';
      await file.rename(newPath);
      final stat = await File(newPath).stat();
      return MediaModel(
        path: newPath,
        duration: media.duration,
        size: stat.size,
        lastModified: stat.modified,
        type: media.type,
      );
    } catch (e) {
      log('Error rename: $e');
      return null;
    }
  }

  Future<bool> shareMedia(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) return false;
      final params = ShareParams(files: [XFile(file.path)]);
      await SharePlus.instance.share(params);
      return true;
    } catch (e) {
      log('Error sharing: $e');
      return false;
    }
  }

  Future<List<MediaModel>> scanDeviceDirectory() async {
    return await _scanner.scanDeviceDirectory();
  }
}
