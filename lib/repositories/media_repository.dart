import 'package:media_manager/interfaces/media_interface.dart';
import 'package:media_manager/models/media.dart';

class MediaRepository {
  final MediaInterface _mediaService;

  MediaRepository({required MediaInterface mediaService})
    : _mediaService = mediaService;

  Future<List<Media>> scanDeviceDirectory() async {
    return await _mediaService.scanDeviceDirectory();
  }

  Future<bool> deleteMedia(String path) async {
    return await _mediaService.deleteMedia(path);
  }

  Future<Media?> renameMedia(Media media, String newName) async {
    return await _mediaService.renameMedia(media, newName);
  }

  Future<bool> shareMedia(String path) async {
    return await _mediaService.shareMedia(path);
  }

  Future<bool> checkPermissions() async {
    return await _mediaService.checkPermissions();
  }
}
