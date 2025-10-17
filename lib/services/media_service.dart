import 'dart:developer';
import 'dart:io';
import 'package:media_manager/interfaces/media_interface.dart';
import 'package:media_manager/interfaces/media_scanner_interface.dart';
import 'package:media_manager/models/media.dart';
  import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

class MediaService implements MediaInterface {
  final MediaScannerInterface _scanner;

  MediaService({required MediaScannerInterface scanner}) : _scanner = scanner;

  @override
  Future<bool> checkPermissions() async {
    if (await Permission.manageExternalStorage.isGranted) {
      return true;
    }
    final status = await Permission.manageExternalStorage.request();
    if (status.isGranted) return true;
    final storageStatus = await Permission.storage.request();
    return storageStatus.isGranted;
  }

  @override
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
      log('Error deleting media: $e');
      return false;
    }
  }

  @override
  Future<Media?> renameMedia(Media media, String newName) async {
    try {
      final hasPermission = await checkPermissions();
      if (!hasPermission) return null;
      final oldFile = File(media.path);
      final directoryPath = oldFile.parent.path;
      final extension = media.path.split('.').last;
      final newPath = '$directoryPath/$newName.$extension';
      if (await oldFile.exists()) {
        await oldFile.rename(newPath);
        FileStat? updatedStat;
        try {
          updatedStat = await File(newPath).stat();
        } catch (e) {
          updatedStat = await File(media.path).stat();
        }
        return Media(
          path: newPath,
          duration: media.duration,
          size: updatedStat.size,
          lastModified: updatedStat.modified,
          type: media.type,
        );
      }
      return null;
    } catch (e) {
      log('Error renaming media: $e');
      return null;
    }
  }

  @override
  Future<bool> shareMedia(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        final params = ShareParams(files: [XFile(file.path)]);
        await SharePlus.instance.share(params);
        return true;
      }
      return false;
    } catch (e) {
      log('Error sharing media: $e');
      return false;
    }
  }

  @override
  Future<List<Media>> scanDeviceDirectory() async {
    try {
      return await _scanner.scanDeviceDirectory();
    } catch (e) {
      log('Error scanning: $e');
      return [];
    }
  }
}
