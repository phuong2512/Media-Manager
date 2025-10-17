import 'package:media_manager/interfaces/home_media_storage_interface.dart';
import 'package:media_manager/models/media.dart';

class HomeRepository {
  final HomeMediaStorageInterface _homeStorageService;

  HomeRepository({required HomeMediaStorageInterface homeStorageService})
    : _homeStorageService = homeStorageService;

  Future<List<Media>> loadHomeMediaList() async {
    return await _homeStorageService.loadHomeMediaList();
  }

  Future<bool> saveHomeMediaList(List<Media> mediaList) async {
    return await _homeStorageService.saveHomeMediaList(mediaList);
  }

  Future<bool> clearHomeMediaList() async {
    return await _homeStorageService.clearHomeMediaList();
  }
}
