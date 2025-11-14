import 'package:media_manager/features/home/domain/repositories/home_repository.dart';

class ClearHomeMedia {
  final HomeRepository repository;

  ClearHomeMedia(this.repository);

  Future<bool> execute() async {
    return await repository.clearHomeMediaList();
  }
}