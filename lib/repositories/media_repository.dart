import 'package:media_manager/interfaces/media_interface.dart';
import 'package:media_manager/interfaces/home_media_storage_interface.dart';
import 'package:media_manager/models/media.dart';

class MediaRepository {
  final MediaInterface _mediaService;
  final HomeMediaStorageInterface _homeStorageService;

  MediaRepository({
    required MediaInterface mediaService,
    required HomeMediaStorageInterface homeStorageService,
  }) : _mediaService = mediaService,
       _homeStorageService = homeStorageService;

  Future<List<Media>> loadHomeMediaList() async {
    return await _homeStorageService.loadHomeMediaList();
  }

  Future<bool> saveHomeMediaList(List<Media> mediaList) async {
    return await _homeStorageService.saveHomeMediaList(mediaList);
  }

  Future<bool> clearHomeMediaList() async {
    return await _homeStorageService.clearHomeMediaList();
  }

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
