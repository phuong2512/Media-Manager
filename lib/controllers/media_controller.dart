import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:media_manager/models/media.dart';
import 'package:media_manager/interfaces/media_service_interface.dart';
import 'package:media_manager/widgets/bottom_sheets/media_options_bottom_sheet.dart';
import 'package:media_manager/widgets/dialogs/delete_media_dialog.dart';
import 'package:media_manager/widgets/dialogs/rename_media_dialog.dart';

enum SortOrder { none, newestFirst, oldestFirst }

class MediaController extends ChangeNotifier {
  final MediaServiceInterface _service;

  MediaController({required MediaServiceInterface service}) : _service = service {
    _libraryMediaList = [];
    _homeMediaList = [];
    _isLibraryScanned = false;
    _sortOrder = SortOrder.none;
  }

  SortOrder _sortOrder = SortOrder.none;
  SortOrder get sortOrder => _sortOrder;

  late List<Media> _libraryMediaList;
  List<Media> get libraryMediaList => _libraryMediaList;

  late List<Media> _homeMediaList;
  List<Media> get homeMediaList => _homeMediaList;

  bool _isLibraryScanned = false;
  bool get isLibraryScanned => _isLibraryScanned;

  bool _isScanning = false;
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

  Future<bool> deleteMedia(String path) async {
    final success = await _service.deleteMedia(path);
    if (success) {
      _libraryMediaList.removeWhere((m) => m.path == path);
      _homeMediaList.removeWhere((m) => m.path == path);
      notifyListeners();
    }
    return success;
  }

  Future<bool> renameMedia(Media media, String newName) async {
    final updatedMedia = await _service.renameMedia(media, newName);
    if (updatedMedia != null) {
      final index = _libraryMediaList.indexWhere((m) => m.path == media.path);
      if (index != -1) {
        _libraryMediaList[index] = updatedMedia;
      }
      final homeIndex = _homeMediaList.indexWhere((m) => m.path == media.path);
      if (homeIndex != -1) {
        _homeMediaList[homeIndex] = updatedMedia;
      }
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> shareMedia(String path) async {
    return await _service.shareMedia(path);
  }

  void sortToggleByLastModified(SortOrder order) {
    if (order == SortOrder.none) return;
    _sortOrder = order;
    _libraryMediaList.sort(
      (a, b) => order == SortOrder.newestFirst
          ? a.lastModified.compareTo(b.lastModified)
          : b.lastModified.compareTo(a.lastModified),
    );
    notifyListeners();
  }

  Future<void> scanDeviceDirectory() async {
    if (_isLibraryScanned || _isScanning) return;
    _isScanning = true;
    notifyListeners();

    try {
      final scanned = await _service.scanDeviceDirectory();
      _libraryMediaList = scanned;
      _isLibraryScanned = true;
      if (_sortOrder != SortOrder.none) {
        sortToggleByLastModified(_sortOrder);
      }
    } catch (e) {
      log('Error scanning library: $e');
    } finally {
      _isScanning = false;
      notifyListeners();
    }
  }

  Future<String?> handleMediaOptions(BuildContext context, Media media) async {
    String? message;

    final action = await showMediaOptionsBottomSheet(context: context);
    if (action == null) return null;

    if (action == 'delete') {
      if (!context.mounted) return null;
      final confirmed = await showDeleteMediaDialog(context, media);
      if (confirmed == true) {
        final success = await deleteMedia(media.path);
        message = success ? 'Xóa file thành công' : 'Xóa file thất bại';
      }
    } else if (action == 'rename') {
      if (!context.mounted) return null;
      final newName = await showRenameMediaDialog(context, media);
      if (newName != null && newName.isNotEmpty) {
        final success = await renameMedia(media, newName);
        message = success ? 'Đổi tên thành công' : 'Đổi tên thất bại';
      }
    } else if (action == 'share') {
      await shareMedia(media.path);
    }

    return message;
  }
}
