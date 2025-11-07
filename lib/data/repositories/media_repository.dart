import 'package:media_manager/data/models/media.dart';

abstract class MediaRepository {
  Future<bool> checkPermissions();

  Future<bool> deleteMedia(String path);

  Future<Media?> renameMedia(Media media, String newName);

  Future<bool> shareMedia(String path);

  Future<List<Media>> scanDeviceDirectory();

  Stream<String> get onMediaDeleted;

  Stream<Map<String, Media>> get onMediaRenamed;
}
