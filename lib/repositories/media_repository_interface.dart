import 'package:media_manager/models/media.dart';

abstract class MediaRepositoryInterface {
  Future<List<Media>> scanAllMedia();

  Future<bool> deleteMedia(String path);

  Future<bool> renameMedia(Media media, String newName);

  Future<bool> shareMedia(String path);

  Future<bool> checkPermissions();
}
