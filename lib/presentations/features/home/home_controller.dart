import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:media_manager/core/models/media.dart';
import 'package:media_manager/core/repositories/media_repository.dart';
import 'package:media_manager/core/use_cases/clear_home_media.dart';
import 'package:media_manager/core/use_cases/delete_media.dart';
import 'package:media_manager/core/use_cases/load_home_media.dart';
import 'package:media_manager/core/use_cases/observe_media_deleted.dart';
import 'package:media_manager/core/use_cases/observe_media_renamed.dart';
import 'package:media_manager/core/use_cases/rename_media.dart';
import 'package:media_manager/core/use_cases/save_home_media.dart';
import 'package:media_manager/core/use_cases/share_media.dart';
import 'package:media_manager/core/widgets/bottom_sheet/media_options_bottom_sheet.dart';
import 'package:media_manager/core/widgets/dialogs/delete_media_dialog.dart';
import 'package:media_manager/core/widgets/dialogs/rename_media_dialog.dart';

class HomeController extends ChangeNotifier {
  final LoadHomeMedia _loadHomeMedia;
  final ClearHomeMedia _clearHomeMedia;
  final SaveHomeMedia _saveHomeMedia;
  final DeleteMedia _deleteMedia;
  final RenameMedia _renameMedia;
  final ShareMedia _shareMedia;
  final ObserveMediaDeleted _observeMediaDeleted;
  final ObserveMediaRenamed _observeMediaRenamed;

  final StreamController<List<Media>> _homeMediaListController =
      StreamController<List<Media>>.broadcast();
  final StreamController<bool> _isLoadingController =
      StreamController<bool>.broadcast();

  List<Media> _homeMediaList = [];

  late final StreamSubscription _deleteSubscription;
  late final StreamSubscription _renameSubscription;

  HomeController({
    required MediaRepository mediaRepository,
    required ClearHomeMedia clearHomeMedia,
    required LoadHomeMedia loadHomeMedia,
    required SaveHomeMedia saveHomeMedia,
    required DeleteMedia deleteMedia,
    required RenameMedia renameMedia,
    required ShareMedia shareMedia,
    required ObserveMediaDeleted observeMediaDeleted,
    required ObserveMediaRenamed observeMediaRenamed,
  }) : _clearHomeMedia = clearHomeMedia,
       _saveHomeMedia = saveHomeMedia,
       _loadHomeMedia = loadHomeMedia,
       _deleteMedia = deleteMedia,
       _renameMedia = renameMedia,
       _shareMedia = shareMedia,
       _observeMediaDeleted = observeMediaDeleted,
       _observeMediaRenamed = observeMediaRenamed {
    log('✅ HomeController INIT');
    _emitHomeMediaList([]);
    _emitIsLoading(true);
    loadHomeMediaFromStorage();

    _deleteSubscription = _observeMediaDeleted.execute().listen(
      (path) => syncDeleteMedia(path),
    );

    _renameSubscription = _observeMediaRenamed.execute().listen(
      (eventMap) => syncRenameMedia(eventMap),
    );
  }

  Stream<List<Media>> get homeMediaListStream =>
      _homeMediaListController.stream;

  Stream<bool> get isLoadingStream => _isLoadingController.stream;

  List<Media> get audioList =>
      _homeMediaList.where((media) => media.type == "Audio").toList();

  List<Media> get videoList =>
      _homeMediaList.where((media) => media.type == "Video").toList();

  // Helper methods
  void _emitHomeMediaList(List<Media> list) {
    _homeMediaList = list;
    if (!_homeMediaListController.isClosed) {
      _homeMediaListController.add(list);
    }
  }

  void _emitIsLoading(bool loading) {
    if (!_isLoadingController.isClosed) {
      _isLoadingController.add(loading);
    }
  }

  Future<void> loadHomeMediaFromStorage() async {
    try {
      _emitIsLoading(true);
      final savedMedia = await _loadHomeMedia.execute();
      _emitHomeMediaList(savedMedia);
      _emitIsLoading(false);
    } catch (e) {
      log('Error loading home media from storage: $e');
      _emitIsLoading(false);
    }
  }

  Future<void> _saveHomeMediaToStorage() async {
    try {
      await _saveHomeMedia.execute(_homeMediaList);
    } catch (e) {
      log('Error saving home media to storage: $e');
    }
  }

  void addToHome(Media media) {
    final isExists = _homeMediaList.any((m) => m.path == media.path);
    if (!isExists) {
      final updatedList = [..._homeMediaList, media];
      _emitHomeMediaList(updatedList);
      _saveHomeMediaToStorage();
    }
  }

  Future<void> clearHomeMediaList() async {
    if (_homeMediaList.isEmpty) return;

    if (await _clearHomeMedia.execute()) {
      _emitHomeMediaList([]);
    }
  }

  Future<bool> deleteMedia(String path) async {
    final success = await _deleteMedia.execute(path);
    if (success) {
      final updatedList = _homeMediaList.where((m) => m.path != path).toList();
      _emitHomeMediaList(updatedList);
      _saveHomeMediaToStorage();
    }
    return success;
  }

  Future<bool> renameMedia(Media media, String newName) async {
    final updatedMedia = await _renameMedia.execute(media, newName);
    if (updatedMedia != null) {
      final updatedList = List<Media>.from(_homeMediaList);
      final homeIndex = updatedList.indexWhere((m) => m.path == media.path);
      if (homeIndex != -1) {
        updatedList[homeIndex] = updatedMedia;
        _emitHomeMediaList(updatedList);
        _saveHomeMediaToStorage();
      }
      return true;
    }
    return false;
  }

  Future<bool> shareMedia(String path) async {
    return await _shareMedia.execute(path);
  }

  Future<void> syncDeleteMedia(String path) async {
    final updatedList = _homeMediaList.where((m) => m.path != path).toList();
    _emitHomeMediaList(updatedList);
    await _saveHomeMediaToStorage();
  }

  Future<void> syncRenameMedia(Map<String, dynamic> eventMap) async {
    final oldMedia = eventMap['old'];
    final newMedia = eventMap['new'];
    if (oldMedia != null && newMedia != null) {
      final updatedList = List<Media>.from(_homeMediaList);
      final index = updatedList.indexWhere((m) => m.path == oldMedia.path);
      if (index != -1) {
        updatedList[index] = newMedia;
        _emitHomeMediaList(updatedList);
        await _saveHomeMediaToStorage();
      }
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

  @override
  void dispose() {
    log('❌ HomeController DISPOSE');
    _deleteSubscription.cancel();
    _renameSubscription.cancel();
    _homeMediaListController.close();
    _isLoadingController.close();
    super.dispose();
  }
}
