import 'dart:async';
import 'package:media_manager/features/media/data/datasources/media_data_source.dart';
import 'package:media_manager/features/media/data/models/media.dart';
import 'package:media_manager/features/media/domain/entities/media.dart';
import 'package:media_manager/features/media/domain/repositories/media_repository.dart';

class MediaRepositoryImpl implements MediaRepository {
  final MediaDataSource _dataSource;

  final _mediaDeletedController = StreamController<String>.broadcast();
  final _mediaRenamedController =
      StreamController<Map<String, Media>>.broadcast();

  MediaRepositoryImpl({required MediaDataSource dataSource})
    : _dataSource = dataSource;

  @override
  Stream<String> get onMediaDeleted => _mediaDeletedController.stream;

  @override
  Stream<Map<String, Media>> get onMediaRenamed =>
      _mediaRenamedController.stream;

  @override
  Future<List<Media>> scanDeviceDirectory() async {
    final mediaModels = await _dataSource.scanDeviceDirectory();
    return mediaModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<bool> deleteMedia(String path) async {
    final success = await _dataSource.deleteMedia(path);
    if (success) _mediaDeletedController.add(path);
    return success;
  }

  @override
  Future<Media?> renameMedia(Media media, String newName) async {
    final mediaModel = MediaModel.fromEntity(media);

    final updatedModel = await _dataSource.renameMedia(mediaModel, newName);

    if (updatedModel != null) {
      final updatedEntity = updatedModel.toEntity();

      _mediaRenamedController.add({'old': media, 'new': updatedEntity});

      return updatedEntity;
    }

    return null;
  }

  @override
  Future<bool> shareMedia(String path) async => _dataSource.shareMedia(path);

  @override
  Future<bool> checkPermissions() async => _dataSource.checkPermissions();
}
