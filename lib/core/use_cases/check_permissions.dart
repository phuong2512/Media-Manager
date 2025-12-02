import 'package:media_manager/core/repositories/media_repository.dart';

class CheckPermissions {
  final MediaRepository repository;

  CheckPermissions(this.repository);

  Future<bool> execute() async {
    return await repository.checkPermissions();
  }
}
