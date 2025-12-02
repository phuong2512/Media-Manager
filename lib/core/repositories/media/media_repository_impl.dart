import 'dart:async';

import 'package:media_manager/core/models/media.dart';
import 'package:media_manager/core/repositories/media/media_repository.dart';
import 'package:media_manager/core/services/media/media_service.dart';

class MediaRepositoryImpl implements MediaRepository {
  final MediaService _service;

  final _mediaDeletedController = StreamController<String>.broadcast();
  final _mediaRenamedController =
      StreamController<Map<String, Media>>.broadcast();

  MediaRepositoryImpl({required MediaService dataSource})
    : _service = dataSource;

  @override
  Stream<String> get onMediaDeleted => _mediaDeletedController.stream;

  @override
  Stream<Map<String, Media>> get onMediaRenamed =>
      _mediaRenamedController.stream;

  @override
  Future<List<Media>> scanDeviceDirectory() async {
    return await _service.scanDeviceDirectory();
  }

  @override
  Future<bool> deleteMedia(String path) async {
    final success = await _service.deleteMedia(path);
    if (success) _mediaDeletedController.add(path);
    return success;
  }

  @override
  Future<Media?> renameMedia(Media media, String newName) async {
    final updatedMedia = await _service.renameMedia(media, newName);

    if (updatedMedia != null) {
      _mediaRenamedController.add({'old': media, 'new': updatedMedia});
      return updatedMedia;
    }

    return null;
  }

  @override
  Future<bool> shareMedia(String path) async => _service.shareMedia(path);

  @override
  Future<bool> checkPermissions() async => _service.checkPermissions();
}
