import 'package:media_manager/features/home/domain/repositories/home_repository.dart';
import 'package:media_manager/features/media/domain/entities/media.dart';

class LoadHomeMedia {
  final HomeRepository repository;

  LoadHomeMedia(this.repository);

  Future<List<Media>> execute() async {
    return await repository.loadHomeMediaList();
  }
}
