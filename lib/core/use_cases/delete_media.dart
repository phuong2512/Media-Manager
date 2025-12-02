import 'package:media_manager/core/repositories/media_repository.dart';

class DeleteMedia {
  final MediaRepository repository;

  DeleteMedia(this.repository);

  Future<bool> execute(String path) async {
    return await repository.deleteMedia(path);
  }
}
