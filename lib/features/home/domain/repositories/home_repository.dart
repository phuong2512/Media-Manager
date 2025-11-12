import 'package:media_manager/features/media/domain/entities/media.dart';

abstract class HomeRepository {
  Future<bool> saveHomeMediaList(List<Media> mediaList);

  Future<List<Media>> loadHomeMediaList();

  Future<bool> clearHomeMediaList();
}
