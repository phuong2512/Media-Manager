import 'dart:async';

import 'package:media_manager/interfaces/media_interface.dart';
import 'package:media_manager/models/media.dart';

class MediaRepository {
  final MediaInterface _mediaService;

  MediaRepository({required MediaInterface mediaService})
    : _mediaService = mediaService;

  final _mediaDeletedController = StreamController<String>.broadcast();

  Stream<String> get onMediaDeleted => _mediaDeletedController.stream;

  final _mediaRenamedController =
      StreamController<Map<String, Media>>.broadcast();

  Stream<Map<String, Media>> get onMediaRenamed =>
      _mediaRenamedController.stream;

  Future<List<Media>> scanDeviceDirectory() async {
    return await _mediaService.scanDeviceDirectory();
  }

  Future<bool> deleteMedia(String path) async {
    final success = await _mediaService.deleteMedia(path);
    if (success) {
      _mediaDeletedController.add(path);
    }
    return success;
  }

  Future<Media?> renameMedia(Media media, String newName) async {
    final updatedMedia = await _mediaService.renameMedia(media, newName);
    if (updatedMedia != null) {
      _mediaRenamedController.add({'old': media, 'new': updatedMedia});
    }
    return updatedMedia;
  }

  Future<bool> shareMedia(String path) async {
    return await _mediaService.shareMedia(path);
  }

  Future<bool> checkPermissions() async {
    return await _mediaService.checkPermissions();
  }
}
