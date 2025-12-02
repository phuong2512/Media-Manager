class Media {
  final String path;
  final String duration;
  final int size;
  final DateTime lastModified;
  final String type;

  const Media({
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

  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
      path: json["path"] ?? '',
      duration: json["duration"] ?? '',
      size: (json["size"] is int) ? json["size"] : 0,
      lastModified: json["lastModified"] != null
          ? DateTime.tryParse(json["lastModified"]) ?? DateTime.now()
          : DateTime.now(),
      type: json["type"] ?? '',
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
}
