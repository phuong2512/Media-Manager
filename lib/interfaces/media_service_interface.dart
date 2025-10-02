import 'package:media_manager/models/media.dart';

abstract class MediaServiceInterface {
  Future<bool> checkPermissions();

  Future<bool> deleteMedia(String path);

  Future<Media?> renameMedia(Media media, String newName);

  Future<bool> shareMedia(String path);

  Future<List<Media>> scanDeviceDirectory();
}
