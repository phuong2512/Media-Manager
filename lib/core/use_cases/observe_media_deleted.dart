import 'package:media_manager/core/repositories/media_repository.dart';

class ObserveMediaDeleted {
  final MediaRepository _repository;

  ObserveMediaDeleted(this._repository);

  Stream<String> execute() {
    return _repository.onMediaDeleted;
  }
}
