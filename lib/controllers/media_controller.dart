import 'package:flutter/material.dart';
import 'package:media_download_manager/models/media.dart';

class MediaController extends ChangeNotifier {
  MediaController() {
    _libraryMediaList = [
      Media(
        path: "audio/audio1.mp3",
        duration: "05:00",
        size: 15,
        lastModified: DateTime.parse('2025-09-15 14:30:25'),
        type: "Audio",
      ),
      Media(
        path: "audio/audio2.mp3",
        duration: "00:50",
        size: 50,
        lastModified: DateTime.parse('2025-09-15 15:30:25'),
        type: "Audio",
      ),
      Media(
        path: "audio/audio3.mp3",
        duration: "03:05",
        size: 20,
        lastModified: DateTime.parse('2025-09-15 14:30:25'),
        type: "Audio",
      ),
      Media(
        path: "video/video1.mp4",
        duration: "05:00",
        size: 50,
        lastModified: DateTime.parse('2025-09-14 14:00:25'),
        type: "Video",
      ),
      Media(
        path: "video/video2.mp4",
        duration: "14:05",
        size: 125,
        lastModified: DateTime.parse('2025-09-15 17:23:25'),
        type: "Video",
      ),
      Media(
        path: "video/video3.mp4",
        duration: "03:20",
        size: 300,
        lastModified: DateTime.parse('2025-08-14 14:00:25'),
        type: "Video",
      ),
    ];
    _homeMediaList = [];
  }

  late List<Media> _libraryMediaList;
  late List<Media> _homeMediaList;
  bool _isSortNewestFirst = true;

  List<Media> get libraryMediaList => _libraryMediaList;

  List<Media> get homeMediaList => _homeMediaList;

  bool get isSortNewestFirst => _isSortNewestFirst;

  List<Media> get audioList =>
      _homeMediaList.where((media) => media.type == "Audio").toList();

  List<Media> get videoList =>
      _homeMediaList.where((media) => media.type == "Video").toList();

  List<Media> filteredLibrary({required String type, required String query}) {
    final lowered = query.toLowerCase();
    return _libraryMediaList.where((media) {
      final isType = media.type == type;
      final name = media.path.split('/').last.split('.').first.toLowerCase();
      return isType && name.contains(lowered);
    }).toList();
  }

  void addToHome(Media media) {
    final isExists = _homeMediaList.any((m) => m.path == media.path);
    if (!isExists) {
      _homeMediaList.add(media);
      notifyListeners();
    }
  }

  void deleteByPath(String path) {
    _libraryMediaList.removeWhere((m) => m.path == path);
    _homeMediaList.removeWhere((m) => m.path == path);
    notifyListeners();
  }

  void rename(Media target, String newName) {
    final index = _libraryMediaList.indexWhere((m) => m.path == target.path);
    if (index == -1) return;
    final oldMedia = _libraryMediaList[index];
    final pathParts = oldMedia.path.split('/');
    final extension = pathParts.last.split('.').last;
    pathParts[pathParts.length - 1] = '$newName.$extension';
    final newPath = pathParts.join('/');
    final updated = Media(
      path: newPath,
      duration: oldMedia.duration,
      size: oldMedia.size,
      lastModified: oldMedia.lastModified,
      type: oldMedia.type,
    );
    _libraryMediaList[index] = updated;

    final homeIndex = _homeMediaList.indexWhere((m) => m.path == target.path);
    if (homeIndex != -1) {
      _homeMediaList[homeIndex] = updated;
    }
    notifyListeners();
  }

  void sortToggleByLastModified() {
    _libraryMediaList.sort(
      (a, b) => _isSortNewestFirst
          ? a.lastModified.compareTo(b.lastModified)
          : b.lastModified.compareTo(a.lastModified),
    );
    _isSortNewestFirst = !_isSortNewestFirst;
    notifyListeners();
  }
}
