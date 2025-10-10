import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:media_manager/controllers/home_controller.dart';
import 'package:media_manager/models/media.dart';
import 'package:media_manager/repositories/media_repository.dart';
import 'package:media_manager/widgets/bottom_sheets/media_options_bottom_sheet.dart';
import 'package:media_manager/widgets/dialogs/delete_media_dialog.dart';
import 'package:media_manager/widgets/dialogs/rename_media_dialog.dart';

enum SortOrder { none, newestFirst, oldestFirst }

class MediaListController extends ChangeNotifier {
  final MediaRepository _repository;
  final HomeController _homeController;

  MediaListController({
    required MediaRepository repository,
    required HomeController homeController,
  }) : _repository = repository,
       _homeController = homeController {
    _mediaList = [];
    _isLibraryScanned = false;
    _sortOrder = SortOrder.none;
  }

  SortOrder _sortOrder = SortOrder.none;
  SortOrder get sortOrder => _sortOrder;

  late List<Media> _mediaList;
  List<Media> get libraryMediaList => _mediaList;

  bool _isLibraryScanned = false;
  bool get isLibraryScanned => _isLibraryScanned;

  bool _isScanning = false;
  bool get isScanning => _isScanning;

  List<Media> filteredLibrary({required String type, required String query}) {
    final lowered = query.toLowerCase();
    return _mediaList.where((media) {
      final isType = media.type == type;
      final name = media.path.split('/').last.split('.').first.toLowerCase();
      return isType && name.contains(lowered);
    }).toList();
  }

  Future<bool> deleteMedia(String path) async {
    final success = await _repository.deleteMedia(path);
    if (success) {
      _mediaList.removeWhere((m) => m.path == path);
      await _homeController.syncDeleteMedia(path);
      notifyListeners();
    }
    return success;
  }

  Future<bool> renameMedia(Media media, String newName) async {
    final updatedMedia = await _repository.renameMedia(media, newName);
    if (updatedMedia != null) {
      final index = _mediaList.indexWhere((m) => m.path == media.path);
      if (index != -1) {
        _mediaList[index] = updatedMedia;
      }
      await _homeController.syncRenameMedia(media, updatedMedia);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> shareMedia(String path) async {
    return await _repository.shareMedia(path);
  }

  void sortToggleByLastModified(SortOrder order) {
    if (order == SortOrder.none) return;
    _sortOrder = order;
    _mediaList.sort(
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
      final scanned = await _repository.scanDeviceDirectory();
      _mediaList = scanned;
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
