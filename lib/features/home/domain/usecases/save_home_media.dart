import 'package:media_manager/features/home/domain/repositories/home_repository.dart';
import 'package:media_manager/features/media/domain/entities/media.dart';

class SaveHomeMedia {
  final HomeRepository repository;

  SaveHomeMedia(this.repository);

  Future<bool> call(List<Media> mediaList) async {
    return await repository.saveHomeMediaList(mediaList);
  }
}
