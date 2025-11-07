import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:media_manager/data/models/media.dart';
import 'package:media_manager/data/repositories/media_repository.dart';
import 'package:media_manager/presentation/widgets/bottom_sheet/media_options_bottom_sheet.dart';
import 'package:media_manager/presentation/widgets/dialogs/delete_media_dialog.dart';
import 'package:media_manager/presentation/widgets/dialogs/rename_media_dialog.dart';

enum SortOrder { none, newestFirst, oldestFirst }

class MediaListController extends ChangeNotifier {
  final MediaRepository _repository;

  late final StreamSubscription _deleteSubscription;
  late final StreamSubscription _renameSubscription;

  MediaListController({required MediaRepository repository})
    : _repository = repository {
    _mediaList = [];
    _isLibraryScanned = false;
    _sortOrder = SortOrder.none;

    _deleteSubscription = _repository.onMediaDeleted.listen(
      _handleMediaDeleted,
    );
    _renameSubscription = _repository.onMediaRenamed.listen(
      _handleMediaRenamed,
    );
  }

  void _handleMediaDeleted(String path) {
    final int oldLength = _mediaList.length;
    _mediaList.removeWhere((m) => m.path == path);
    final bool didRemove = _mediaList.length < oldLength;
    if (didRemove) {
      notifyListeners();
    }
  }

  void _handleMediaRenamed(Map<String, Media> eventMap) {
    final oldMedia = eventMap['old'];
    final newMedia = eventMap['new'];

    if (oldMedia == null || newMedia == null) return;

    final index = _mediaList.indexWhere((m) => m.path == oldMedia.path);
    if (index != -1) {
      _mediaList[index] = newMedia;
      notifyListeners();
    }
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
    _sortOrder = order;
    _mediaList.sort(
      (a, b) => order == SortOrder.newestFirst
          ? b.lastModified.compareTo(a.lastModified)
          : a.lastModified.compareTo(b.lastModified),
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

  @override
  void dispose() {
    log('MediaListController DISPOSE');
    _deleteSubscription.cancel();
    _renameSubscription.cancel();
    super.dispose();
  }
}
