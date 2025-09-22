import 'dart:io';
import 'package:media_manager/models/media.dart';
import 'package:media_manager/repositories/media_repository_interface.dart';
import 'package:media_manager/services/media_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

class MediaRepository implements MediaRepositoryInterface {
  final MediaScannerService _scanner;

  MediaRepository(this._scanner);

  @override
  Future<List<Media>> scanAllMedia() async {
    return await _scanner.scanAll();
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
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> renameMedia(Media media, String newName) async {
    try {
      final hasPermission = await checkPermissions();
      if (!hasPermission) return false;

      final oldFile = File(media.path);
      final directoryPath = oldFile.parent.path;
      final extension = media.path.split('.').last;
      final newPath = '$directoryPath/$newName.$extension';

      if (await oldFile.exists()) {
        await oldFile.rename(newPath);
        return true;
      }
      return false;
    } catch (_) {
      return false;
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
    } catch (_) {
      return false;
    }
  }

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
}
