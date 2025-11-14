import 'package:media_manager/features/media/domain/entities/media.dart';
import 'package:media_manager/features/media/domain/repositories/media_repository.dart';

class ScanDevice {
  final MediaRepository repository;

  ScanDevice(this.repository);

  Future<List<Media>> execute() async {
    return await repository.scanDeviceDirectory();
  }
}
