import 'package:media_manager/features/home/data/datasources/home_data_source.dart';
import 'package:media_manager/features/home/domain/repositories/home_repository.dart';
import 'package:media_manager/features/media/data/models/media.dart';
import 'package:media_manager/features/media/domain/entities/media.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeDataSource _dataSource;

  HomeRepositoryImpl({required HomeDataSource dataSource})
    : _dataSource = dataSource;

  @override
  Future<List<Media>> loadHomeMediaList() async {
    final mediaModels = await _dataSource.loadHomeMediaList();
    return mediaModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<bool> saveHomeMediaList(List<Media> mediaList) {
    final List<MediaModel> models = mediaList
        .map((media) => MediaModel.fromEntity(media))
        .toList();
    return _dataSource.saveHomeMediaList(models);
  }

  @override
  Future<bool> clearHomeMediaList() => _dataSource.clearHomeMediaList();
}
