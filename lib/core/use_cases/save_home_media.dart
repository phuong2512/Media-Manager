import 'package:media_manager/core/models/media.dart';
import 'package:media_manager/core/repositories/home_repository.dart';

class SaveHomeMedia {
  final HomeRepository repository;

  SaveHomeMedia(this.repository);

  Future<bool> execute(List<Media> mediaList) async {
    return await repository.saveHomeMediaList(mediaList);
  }
}
