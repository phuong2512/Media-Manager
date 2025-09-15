import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:media_manager/widgets/bottom_sheets/media_options_bottom_sheet.dart';
import 'package:media_manager/widgets/dialogs/delete_media_dialog.dart';
import 'package:media_manager/widgets/dialogs/rename_media_dialog.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:media_manager/models/media.dart';
import 'package:media_manager/services/media_scanner.dart';
import 'package:share_plus/share_plus.dart';

class MediaController extends ChangeNotifier {
  MediaController() {
    _libraryMediaList = [];
    _homeMediaList = [];
    _isLibraryScanned = false;
  }

  late List<Media> _libraryMediaList;
  late List<Media> _homeMediaList;
  bool _isSortNewestFirst = true;
  bool _isLibraryScanned = false;
  bool _isScanning = false;
  final MediaScannerService _scanner = MediaScannerService();

  List<Media> get libraryMediaList => _libraryMediaList;

  List<Media> get homeMediaList => _homeMediaList;

  bool get isSortNewestFirst => _isSortNewestFirst;

  bool get isLibraryScanned => _isLibraryScanned;

  bool get isScanning => _isScanning;

  List<Media> get audioList =>
      _homeMediaList.where((media) => media.type == "Audio").toList();

  List<Media> get videoList =>
      _homeMediaList.where((media) => media.type == "Video").toList();

  List<Media> filteredLibrary({required String type, required String query}) {
    final lowered = query.toLowerCase();
    return _libraryMediaList.where((media) {
      final isType = media.type == type;
      final name = media.path.split('/').last.split('.').first.toLowerCase();
      return isType && name.contains(lowered);
    }).toList();
  }

  void addToHome(Media media) {
    final isExists = _homeMediaList.any((m) => m.path == media.path);
    if (!isExists) {
      _homeMediaList.add(media);
      notifyListeners();
    }
  }

  Future<bool> deleteByPath(String path) async {
    try {
      final hasPermission = await _checkStoragePermission();
      if (!hasPermission) {
        return false;
      }

      final file = File(path);
      final exists = await file.exists();

      if (exists) {
        await file.delete();
      } else {
        return false;
      }
      _libraryMediaList.removeWhere((m) => m.path == path);
      _homeMediaList.removeWhere((m) => m.path == path);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> rename(Media target, String newName) async {
    final index = _libraryMediaList.indexWhere((m) => m.path == target.path);
    if (index == -1) {
      return false;
    }
    final oldMedia = _libraryMediaList[index];
    try {
      final hasPermission = await _checkStoragePermission();
      if (!hasPermission) {
        return false;
      }

      final oldFile = File(oldMedia.path);
      final directoryPath = oldFile.parent.path;
      final extension = oldMedia.path.split('.').last;
      final newPath = '$directoryPath/$newName.$extension';

      final exists = await oldFile.exists();
      if (exists) {
        await oldFile.rename(newPath);
      } else {
        return false;
      }

      FileStat? updatedStat;
      try {
        updatedStat = await File(newPath).stat();
      } catch (e) {
        updatedStat = await oldFile.stat();
      }

      final updated = Media(
        path: newPath,
        duration: oldMedia.duration,
        size: updatedStat.size,
        lastModified: updatedStat.modified,
        type: oldMedia.type,
      );

      _libraryMediaList[index] = updated;
      final homeIndex = _homeMediaList.indexWhere((m) => m.path == target.path);
      if (homeIndex != -1) {
        _homeMediaList[homeIndex] = updated;
      }
      notifyListeners();

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> share(String path) async {
    try {
      final file = File(path);
      final exists = await file.exists();

      if (exists) {
        final params = ShareParams(files: [XFile(file.path)]);
        await SharePlus.instance.share(params);
      } else {
        return false;
      }
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  void sortToggleByLastModified() {
    _libraryMediaList.sort(
      (a, b) => _isSortNewestFirst
          ? a.lastModified.compareTo(b.lastModified)
          : b.lastModified.compareTo(a.lastModified),
    );
    _isSortNewestFirst = !_isSortNewestFirst;
    notifyListeners();
  }

  Future<void> scanLibrary() async {
    if (_isLibraryScanned || _isScanning) {
      return;
    }
    _isScanning = true;
    notifyListeners();
    try {
      final scanned = await _scanner.scanAll();
      _libraryMediaList = scanned;
      _isLibraryScanned = true;
    } catch (e) {
      log('Error scanning library: $e');
    } finally {
      _isScanning = false;
      notifyListeners();
    }
  }

  Future<bool> _checkStoragePermission() async {
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

  Future<String?> handleMediaOptions(BuildContext context, Media media) async {
    final action = await showMediaOptionsBottomSheet(context: context);
    if (action == null) return null;

    String? message;

    if (action == 'delete') {
      if (!context.mounted) return null;
      final confirmed = await showDeleteMediaDialog(context, media);
      if (confirmed == true) {
        final success = await deleteByPath(media.path);
        message = success ? 'Xóa file thành công' : 'Xóa file thất bại';
      }
    } else if (action == 'rename') {
      if (!context.mounted) return null;
      final newName = await showRenameMediaDialog(context, media);
      if (newName != null && newName.isNotEmpty) {
        final success = await rename(media, newName);
        message = success ? 'Đổi tên thành công' : 'Đổi tên thất bại';
      }
    } else if (action == 'share') {
      final success = await share(media.path);
      if (!success) {
        message = 'Chia sẻ file thất bại';
      }
    }

    return message;
  }
}
