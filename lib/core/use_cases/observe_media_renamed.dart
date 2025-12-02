import 'package:media_manager/core/models/media.dart';
import 'package:media_manager/core/repositories/media_repository.dart';

class ObserveMediaRenamed {
  final MediaRepository _repository;

  ObserveMediaRenamed(this._repository);

  Stream<Map<String, Media>> execute() {
    return _repository.onMediaRenamed;
  }
}
