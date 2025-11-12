class Media {
  final String path;
  final String duration;
  final int size;
  final DateTime lastModified;
  final String type;

  Media({
    required this.path,
    required this.duration,
    required this.size,
    required this.lastModified,
    required this.type,
  });

  Media copyWith({
    String? path,
    String? duration,
    int? size,
    DateTime? lastModified,
    String? type,
  }) {
    return Media(
      path: path ?? this.path,
      duration: duration ?? this.duration,
      size: size ?? this.size,
      lastModified: lastModified ?? this.lastModified,
      type: type ?? this.type,
    );
  }
}
