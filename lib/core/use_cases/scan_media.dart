import 'package:media_manager/core/models/media.dart';
import 'package:media_manager/core/repositories/media_repository.dart';

class ScanDevice {
  final MediaRepository repository;

  ScanDevice(this.repository);

  Future<List<Media>> execute() async {
    return await repository.scanDeviceDirectory();
  }
}
