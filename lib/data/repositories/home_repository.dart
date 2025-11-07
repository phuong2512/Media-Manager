import 'package:media_manager/data/models/media.dart';

abstract class HomeRepository {
  Future<bool> saveHomeMediaList(List<Media> mediaList);

  Future<List<Media>> loadHomeMediaList();

  Future<bool> clearHomeMediaList();
}
