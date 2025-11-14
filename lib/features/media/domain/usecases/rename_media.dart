import 'package:media_manager/features/media/domain/entities/media.dart';
import 'package:media_manager/features/media/domain/repositories/media_repository.dart';

class RenameMedia {
  final MediaRepository repository;

  RenameMedia(this.repository);

  Future<Media?> execute(RenameMediaParams params) async {
    return await repository.renameMedia(params.media, params.newName);
  }
}

class RenameMediaParams {
  final Media media;
  final String newName;

  RenameMediaParams(this.media, this.newName);
}
