import 'package:media_manager/core/models/media.dart';
import 'package:media_manager/core/repositories/media_repository.dart';

class RenameMedia {
  final MediaRepository repository;

  RenameMedia(this.repository);

  Future<Media?> execute(Media media, String newName) async {
    return await repository.renameMedia(media, newName);
  }
}
