import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:media_manager/interfaces/home_media_storage_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:media_manager/models/media.dart';
import 'dart:io';

class HomeMediaStorageService implements HomeMediaStorageInterface {
  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();

  @override
  Future<bool> saveHomeMediaList(List<Media> mediaList) async {
    try {
      final jsonList = mediaList.map((media) => media.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      await _prefs.setString('homeMediaList', jsonString);
      return true;
    } catch (e) {
      debugPrint('Error saving home media list: $e');
      return false;
    }
  }

  @override
  Future<List<Media>> loadHomeMediaList() async {
    try {
      final jsonString = await _prefs.getString('homeMediaList');

      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final List<dynamic> jsonList = jsonDecode(jsonString);
      final mediaList = jsonList.map((json) => Media.fromJson(json)).toList();

      final homeMediaList = <Media>[];
      for (final media in mediaList) {
        final file = File(media.path);
        if (await file.exists()) {
          homeMediaList.add(media);
        }
      }

      if (homeMediaList.length != mediaList.length) {
        await saveHomeMediaList(homeMediaList);
      }

      return homeMediaList;
    } catch (e) {
      debugPrint('Error loading home media list: $e');
      return [];
    }
  }
}
