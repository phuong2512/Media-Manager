import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:media_manager/features/media/domain/entities/media.dart';
import 'package:media_manager/features/media/domain/repositories/media_repository.dart';
import 'package:media_manager/features/home/domain/usecases/clear_home_media.dart';
import 'package:media_manager/features/home/domain/usecases/load_home_media.dart';
import 'package:media_manager/features/home/domain/usecases/save_home_media.dart';
import 'package:media_manager/features/media/domain/usecases/delete_media.dart';
import 'package:media_manager/features/media/domain/usecases/rename_media.dart';
import 'package:media_manager/features/media/domain/usecases/share_media.dart';
import 'package:media_manager/presentation/shared_widgets/bottom_sheet/media_options_bottom_sheet.dart';
import 'package:media_manager/presentation/shared_widgets/dialogs/delete_media_dialog.dart';
import 'package:media_manager/presentation/shared_widgets/dialogs/rename_media_dialog.dart';

class HomeController {
  final LoadHomeMedia _loadHomeMedia;
  final SaveHomeMedia _saveHomeMedia;
  final ClearHomeMedia _clearHomeMedia;
  final DeleteMedia _deleteMedia;
  final RenameMedia _renameMedia;
  final ShareMedia _shareMedia;
  final MediaRepository _mediaRepository;

  // Streams riêng biệt
  final StreamController<List<Media>> _homeMediaListController;
  final StreamController<bool> _isLoadingController;

  // Cache giá trị hiện tại
  List<Media> _homeMediaList = [];
  bool _isLoadingHomeMedia = true;

  late final StreamSubscription _deleteSubscription;
  late final StreamSubscription _renameSubscription;

  HomeController({
    required LoadHomeMedia loadHomeMedia,
    required SaveHomeMedia saveHomeMedia,
    required ClearHomeMedia clearHomeMedia,
    required DeleteMedia deleteMedia,
    required RenameMedia renameMedia,
    required ShareMedia shareMedia,
    required MediaRepository mediaRepository,
  }) : _loadHomeMedia = loadHomeMedia,
       _saveHomeMedia = saveHomeMedia,
       _clearHomeMedia = clearHomeMedia,
       _deleteMedia = deleteMedia,
       _renameMedia = renameMedia,
       _shareMedia = shareMedia,
       _mediaRepository = mediaRepository,
       _homeMediaListController = StreamController<List<Media>>.broadcast(),
       _isLoadingController = StreamController<bool>.broadcast() {
    log('✅ HomeController INIT');
    _emitHomeMediaList([]);
    _emitIsLoading(true);

    _loadHomeMediaFromStorage();

    _deleteSubscription = _mediaRepository.onMediaDeleted.listen((path) {
      syncDeleteMedia(path);
    });

    _renameSubscription = _mediaRepository.onMediaRenamed.listen((eventMap) {
      final oldMedia = eventMap['old'];
      final newMedia = eventMap['new'];
      if (oldMedia != null && newMedia != null) {
        syncRenameMedia(oldMedia, newMedia);
      }
    });
  }

  // Public streams
  Stream<List<Media>> get homeMediaListStream =>
      _homeMediaListController.stream;

  Stream<bool> get isLoadingStream => _isLoadingController.stream;

  // Getters đồng bộ
  List<Media> get homeMediaList => _homeMediaList;

  bool get isLoadingHomeMedia => _isLoadingHomeMedia;

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
    _isLoadingHomeMedia = loading;
    if (!_isLoadingController.isClosed) {
      _isLoadingController.add(loading);
    }
  }

  Future<void> _loadHomeMediaFromStorage() async {
    try {
      _emitIsLoading(true);
      final savedMedia = await _loadHomeMedia();
      _emitHomeMediaList(savedMedia);
      _emitIsLoading(false);
    } catch (e) {
      log('Error loading home media from storage: $e');
      _emitIsLoading(false);
    }
  }

  Future<void> _saveHomeMediaToStorage() async {
    try {
      await _saveHomeMedia(_homeMediaList);
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

    if (await _clearHomeMedia()) {
      _emitHomeMediaList([]);
    }
  }

  Future<bool> deleteMedia(String path) async {
    final success = await _deleteMedia(path);
    if (success) {
      final updatedList = _homeMediaList.where((m) => m.path != path).toList();
      _emitHomeMediaList(updatedList);
      _saveHomeMediaToStorage();
    }
    return success;
  }

  Future<bool> renameMedia(Media media, String newName) async {
    final updatedMedia = await _renameMedia(RenameMediaParams(media, newName));
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
    return await _shareMedia(path);
  }

  Future<void> syncDeleteMedia(String path) async {
    final updatedList = _homeMediaList.where((m) => m.path != path).toList();
    _emitHomeMediaList(updatedList);
    await _saveHomeMediaToStorage();
  }

  Future<void> syncRenameMedia(Media oldMedia, Media newMedia) async {
    final updatedList = List<Media>.from(_homeMediaList);
    final index = updatedList.indexWhere((m) => m.path == oldMedia.path);
    if (index != -1) {
      updatedList[index] = newMedia;
      _emitHomeMediaList(updatedList);
      await _saveHomeMediaToStorage();
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

  void dispose() {
    log('❌ HomeController DISPOSE');
    _deleteSubscription.cancel();
    _renameSubscription.cancel();
    _homeMediaListController.close();
    _isLoadingController.close();
  }
}
