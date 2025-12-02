import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:media_manager/core/models/media.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class HomeService {
  Future<bool> saveHomeMediaList(List<Media> mediaList);
  Future<List<Media>> loadHomeMediaList();
  Future<bool> clearHomeMediaList();
}

class HomeServiceImpl implements HomeService {
  final SharedPreferencesAsync _prefs;

  HomeServiceImpl({required SharedPreferencesAsync prefs}) : _prefs = prefs;

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

  @override
  Future<bool> clearHomeMediaList() async {
    try {
      await _prefs.remove('homeMediaList');
      return true;
    } catch (e) {
      debugPrint('Error clearing home media list: $e');
      return false;
    }
  }
}
