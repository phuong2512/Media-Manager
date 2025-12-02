import 'package:media_manager/core/repositories/media_repository.dart';

class ShareMedia {
  final MediaRepository repository;

  ShareMedia(this.repository);

  Future<bool> execute(String path) async {
    return await repository.shareMedia(path);
  }
}
