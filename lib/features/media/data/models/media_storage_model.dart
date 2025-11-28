import 'package:media_manager/features/media/domain/entities/media.dart';

class MediaStorageModel {
  final String path;
  final String duration;
  final int size;
  final DateTime lastModified;
  final String type;

  MediaStorageModel({
    required this.path,
    required this.duration,
    required this.size,
    required this.lastModified,
    required this.type,
  });

  factory MediaStorageModel.fromJson(Map<String, dynamic> json) {
    return MediaStorageModel(
      path: json["path"],
      duration: json["duration"],
      size: json["size"],
      lastModified: DateTime.parse(json["lastModified"]),
      type: json["type"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "path": path,
      "duration": duration,
      "size": size,
      "lastModified": lastModified.toIso8601String(),
      "type": type,
    };
  }

  Media toEntity() {
    return Media(
      path: path,
      duration: duration,
      size: size,
      lastModified: lastModified,
      type: type,
    );
  }

  factory MediaStorageModel.fromEntity(Media media) {
    return MediaStorageModel(
      path: media.path,
      duration: media.duration,
      size: media.size,
      lastModified: media.lastModified,
      type: media.type,
    );
  }
}
