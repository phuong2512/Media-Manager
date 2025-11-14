import 'package:media_manager/features/media/domain/repositories/media_repository.dart';

class CheckPermissions {
  final MediaRepository repository;

  CheckPermissions(this.repository);

  Future<bool> execute() async {
    return await repository.checkPermissions();
  }
}
