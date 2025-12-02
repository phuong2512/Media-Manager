import 'package:media_manager/core/models/media.dart';
import 'package:media_manager/core/services/home/home_service.dart';

abstract class HomeRepository {
  Future<bool> saveHomeMediaList(List<Media> mediaList);
  Future<List<Media>> loadHomeMediaList();
  Future<bool> clearHomeMediaList();
}

class HomeRepositoryImpl implements HomeRepository {
  final HomeService _service;

  HomeRepositoryImpl({required HomeService service}) : _service = service;

  @override
  Future<List<Media>> loadHomeMediaList() async {
    return await _service.loadHomeMediaList();
  }

  @override
  Future<bool> saveHomeMediaList(List<Media> mediaList) {
    return _service.saveHomeMediaList(mediaList);
  }

  @override
  Future<bool> clearHomeMediaList() => _service.clearHomeMediaList();
}
