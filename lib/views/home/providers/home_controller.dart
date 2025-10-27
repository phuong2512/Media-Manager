import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:media_manager/models/media.dart';
import 'package:media_manager/repositories/home_repository.dart';
import 'package:media_manager/repositories/media_repository.dart';
import 'package:media_manager/widgets/bottom_sheets/media_options_bottom_sheet.dart';
import 'package:media_manager/widgets/dialogs/delete_media_dialog.dart';
import 'package:media_manager/widgets/dialogs/rename_media_dialog.dart';

class HomeController extends ChangeNotifier {
  final MediaRepository _mediaRepository;
  final HomeRepository _homeRepository;

  late final StreamSubscription _deleteSubscription;
  late final StreamSubscription _renameSubscription;

  HomeController({
    required HomeRepository homeRepository,
    required MediaRepository repository,
  }) : _mediaRepository = repository,
       _homeRepository = homeRepository {
    _homeMediaList = [];
    _isLoadingHomeMedia = true;
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

  late List<Media> _homeMediaList;

  List<Media> get homeMediaList => _homeMediaList;

  bool _isLoadingHomeMedia = true;

  bool get isLoadingHomeMedia => _isLoadingHomeMedia;

  List<Media> get audioList =>
      _homeMediaList.where((media) => media.type == "Audio").toList();

  List<Media> get videoList =>
      _homeMediaList.where((media) => media.type == "Video").toList();

  Future<void> _loadHomeMediaFromStorage() async {
    try {
      _isLoadingHomeMedia = true;
      notifyListeners();

      final savedMedia = await _homeRepository.loadHomeMediaList();
      _homeMediaList = savedMedia;
      _isLoadingHomeMedia = false;
      notifyListeners();
    } catch (e) {
      log('Error loading home media from storage: $e');
      _isLoadingHomeMedia = false;
      notifyListeners();
    }
  }

  Future<void> _saveHomeMediaToStorage() async {
    try {
      await _homeRepository.saveHomeMediaList(_homeMediaList);
    } catch (e) {
      log('Error saving home media to storage: $e');
    }
  }

  void addToHome(Media media) {
    final isExists = _homeMediaList.any((m) => m.path == media.path);
    if (!isExists) {
      _homeMediaList.add(media);
      _saveHomeMediaToStorage();
      notifyListeners();
    }
  }

  Future<void> clearHomeMediaList() async {
    if (_homeMediaList.isEmpty) return;
    if (await _homeRepository.clearHomeMediaList() == true) {
      _homeMediaList.clear();
      notifyListeners();
    }
  }

  Future<bool> deleteMedia(String path) async {
    final success = await _mediaRepository.deleteMedia(path);
    if (success) {
      _homeMediaList.removeWhere((m) => m.path == path);
      _saveHomeMediaToStorage();
      notifyListeners();
    }
    return success;
  }

  Future<bool> renameMedia(Media media, String newName) async {
    final updatedMedia = await _mediaRepository.renameMedia(media, newName);
    if (updatedMedia != null) {
      final homeIndex = _homeMediaList.indexWhere((m) => m.path == media.path);
      if (homeIndex != -1) {
        _homeMediaList[homeIndex] = updatedMedia;
        _saveHomeMediaToStorage();
      }
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> shareMedia(String path) async {
    return await _mediaRepository.shareMedia(path);
  }

  Future<void> syncDeleteMedia(String path) async {
    _homeMediaList.removeWhere((m) => m.path == path);
    await _saveHomeMediaToStorage();
    notifyListeners();
  }

  Future<void> syncRenameMedia(Media oldMedia, Media newMedia) async {
    final index = _homeMediaList.indexWhere((m) => m.path == oldMedia.path);
    if (index != -1) {
      _homeMediaList[index] = newMedia;
      await _saveHomeMediaToStorage();
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

  @override
  void dispose() {
    log('HomeController DISPOSE');
    _deleteSubscription.cancel();
    _renameSubscription.cancel();
    super.dispose();
  }
}
