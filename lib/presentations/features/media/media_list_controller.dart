import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:media_manager/core/models/media.dart';
import 'package:media_manager/core/repositories/media_repository.dart';
import 'package:media_manager/core/widgets/bottom_sheet/media_options_bottom_sheet.dart';
import 'package:media_manager/core/widgets/dialogs/delete_media_dialog.dart';
import 'package:media_manager/core/widgets/dialogs/rename_media_dialog.dart';

enum SortOrder { none, newestFirst, oldestFirst }

class MediaListController {
  final MediaRepository _repository;

  final StreamController<List<Media>> _mediaListController =
      StreamController<List<Media>>.broadcast();
  final StreamController<bool> _isScanningController =
      StreamController<bool>.broadcast();
  final StreamController<bool> _isLibraryScannedController =
      StreamController<bool>.broadcast();
  final StreamController<SortOrder> _sortOrderController =
      StreamController<SortOrder>.broadcast();

  List<Media> _mediaList = [];
  SortOrder _sortOrder = SortOrder.none;
  bool _isLibraryScanned = false;
  bool _isScanning = false;

  late final StreamSubscription _deleteSubscription;
  late final StreamSubscription _renameSubscription;

  MediaListController({required MediaRepository repository})
    : _repository = repository {
    log('✅ MediaListController INIT');
    _emitMediaList([]);
    _emitIsScanning(false);
    _emitIsLibraryScanned(false);
    _emitSortOrder(SortOrder.none);

    _deleteSubscription = _repository.onMediaDeleted.listen(
      (path) => _handleMediaDeleted(path),
    );

    _renameSubscription = _repository.onMediaRenamed.listen(
      (event) => _handleMediaRenamed(event),
    );
  }

  Stream<List<Media>> get mediaListStream => _mediaListController.stream;

  Stream<bool> get isScanningStream => _isScanningController.stream;

  Stream<bool> get isLibraryScannedStream => _isLibraryScannedController.stream;

  Stream<SortOrder> get sortOrderStream => _sortOrderController.stream;

  bool get isScanning => _isScanning;

  bool get isLibraryScanned => _isLibraryScanned;

  SortOrder get sortOrder => _sortOrder;

  // Helper methods
  void _emitMediaList(List<Media> list) {
    _mediaList = list;
    if (!_mediaListController.isClosed) {
      _mediaListController.add(list);
    }
  }

  void _emitIsScanning(bool scanning) {
    _isScanning = scanning;
    if (!_isScanningController.isClosed) {
      _isScanningController.add(scanning);
    }
  }

  void _emitIsLibraryScanned(bool scanned) {
    _isLibraryScanned = scanned;
    if (!_isLibraryScannedController.isClosed) {
      _isLibraryScannedController.add(scanned);
    }
  }

  void _emitSortOrder(SortOrder order) {
    _sortOrder = order;
    if (!_sortOrderController.isClosed) {
      _sortOrderController.add(order);
    }
  }

  void _handleMediaDeleted(String path) {
    final int oldLength = _mediaList.length;
    final updatedList = _mediaList.where((m) => m.path != path).toList();
    final bool didRemove = updatedList.length < oldLength;
    if (didRemove) {
      _emitMediaList(updatedList);
    }
  }

  void _handleMediaRenamed(Map<String, Media> eventMap) {
    final oldMedia = eventMap['old'];
    final newMedia = eventMap['new'];

    if (oldMedia == null || newMedia == null) return;

    final updatedList = List<Media>.from(_mediaList);
    final index = updatedList.indexWhere((m) => m.path == oldMedia.path);
    if (index != -1) {
      updatedList[index] = newMedia;
      _emitMediaList(updatedList);
    }
  }

  List<Media> filteredLibrary({required String type, required String query}) {
    final lowered = query.toLowerCase();
    return _mediaList.where((media) {
      final isType = media.type == type;
      final name = media.path.split('/').last.split('.').first.toLowerCase();
      return isType && name.contains(lowered);
    }).toList();
  }

  Future<bool> deleteMedia(String path) async {
    return await _repository.deleteMedia(path);
  }

  Future<Media?> renameMedia(Media media, String newName) async {
    return await _repository.renameMedia(media, newName);
  }

  Future<bool> shareMedia(String path) async {
    return await _repository.shareMedia(path);
  }

  void sortToggleByLastModified(SortOrder order) {
    if (order == SortOrder.none) return;

    final sortedList = List<Media>.from(_mediaList);
    sortedList.sort(
      (a, b) => order == SortOrder.newestFirst
          ? b.lastModified.compareTo(a.lastModified)
          : a.lastModified.compareTo(b.lastModified),
    );

    _emitSortOrder(order);
    _emitMediaList(sortedList);
  }

  Future<void> scanDeviceDirectory() async {
    if (_isLibraryScanned || _isScanning) return;

    _emitIsScanning(true);

    try {
      final scanned = await _repository.scanDeviceDirectory();
      _emitMediaList(scanned);
      _emitIsLibraryScanned(true);

      if (_sortOrder != SortOrder.none) {
        sortToggleByLastModified(_sortOrder);
      }
    } catch (e) {
      log('Error scanning library: $e');
    } finally {
      _emitIsScanning(false);
    }
  }

  Future<void> rescanDeviceDirectory() async {
    if (_isScanning) return;

    _emitIsScanning(true);

    try {
      final scanned = await _repository.scanDeviceDirectory();
      _emitMediaList(scanned);
      _emitIsLibraryScanned(true);

      if (_sortOrder != SortOrder.none) {
        sortToggleByLastModified(_sortOrder);
      }
    } catch (e) {
      log('Error re-scanning library: $e');
    } finally {
      _emitIsScanning(false);
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
        if (!context.mounted) return null;
        final success = await deleteMedia(media.path);
        message = success ? 'Xóa file thành công' : 'Xóa file thất bại';
      }
    } else if (action == 'rename') {
      if (!context.mounted) return null;
      final newName = await showRenameMediaDialog(context, media);
      if (newName != null && newName.isNotEmpty) {
        if (!context.mounted) return null;
        final updatedMedia = await renameMedia(media, newName);
        message = updatedMedia != null
            ? 'Đổi tên thành công'
            : 'Đổi tên thất bại';
      }
    } else if (action == 'share') {
      await shareMedia(media.path);
    }

    return message;
  }

  void dispose() {
    log('❌ MediaListController DISPOSE');
    _deleteSubscription.cancel();
    _renameSubscription.cancel();
    _mediaListController.close();
    _isScanningController.close();
    _isLibraryScannedController.close();
    _sortOrderController.close();
  }
}
