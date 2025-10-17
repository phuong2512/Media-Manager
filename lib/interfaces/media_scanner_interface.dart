import 'dart:io';

import 'package:media_manager/models/media.dart';

abstract class MediaScannerInterface {
  Future<List<Media>> scanDeviceDirectory();

  Future<bool> requestStoragePermissions();

  Future<List<Directory>> getCandidateRoots();
}
