import 'package:media_manager/models/media.dart';

abstract class HomeMediaStorageInterface {
  Future<bool> saveHomeMediaList(List<Media> mediaList);
  Future<List<Media>> loadHomeMediaList();
  Future<bool> clearHomeMediaList();
}