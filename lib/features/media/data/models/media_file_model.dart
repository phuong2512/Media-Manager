import 'package:media_manager/features/media/domain/entities/media.dart';

class MediaFileModel {
  final String path;
  final String duration;
  final int size;
  final DateTime lastModified;
  final String type;

  MediaFileModel({
    required this.path,
    required this.duration,
    required this.size,
    required this.lastModified,
    required this.type,
  });

  Media toEntity() {
    return Media(
      path: path,
      duration: duration,
      size: size,
      lastModified: lastModified,
      type: type,
    );
  }

  factory MediaFileModel.fromEntity(Media media) {
    return MediaFileModel(
      path: media.path,
      duration: media.duration,
      size: media.size,
      lastModified: media.lastModified,
      type: media.type,
    );
  }
}
