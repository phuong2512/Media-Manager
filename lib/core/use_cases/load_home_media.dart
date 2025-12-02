import 'package:media_manager/core/models/media.dart';
import 'package:media_manager/core/repositories/home_repository.dart';

class LoadHomeMedia {
  final HomeRepository repository;

  LoadHomeMedia(this.repository);

  Future<List<Media>> execute() async {
    return await repository.loadHomeMediaList();
  }
}
