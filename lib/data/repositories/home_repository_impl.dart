import 'package:media_manager/data/repositories/home_repository.dart';
import 'package:media_manager/data/models/media.dart';
import 'package:media_manager/data/services/home_service.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeService _service;

  HomeRepositoryImpl({required HomeService service}) : _service = service;

  @override
  Future<List<Media>> loadHomeMediaList() => _service.loadHomeMediaList();

  @override
  Future<bool> saveHomeMediaList(List<Media> mediaList) =>
      _service.saveHomeMediaList(mediaList);

  @override
  Future<bool> clearHomeMediaList() => _service.clearHomeMediaList();
}
