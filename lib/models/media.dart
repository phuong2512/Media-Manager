class Media {
  final String path;
  String duration;
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

  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
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
}
