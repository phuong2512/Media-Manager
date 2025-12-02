import 'package:media_manager/core/models/media.dart';
import 'package:media_manager/core/repositories/home/home_repository.dart';
import 'package:media_manager/core/services/home/home_service.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeService _service;

  HomeRepositoryImpl({required HomeService dataSource}) : _service = dataSource;

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
