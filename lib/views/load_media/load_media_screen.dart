import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:media_download_manager/models/media.dart';
import 'package:media_download_manager/views/load_media/audio_tab.dart';
import 'package:media_download_manager/views/load_media/video_tab.dart';

class LoadMediaScreen extends StatefulWidget {
  const LoadMediaScreen({super.key});

  @override
  State<LoadMediaScreen> createState() => _LoadMediaScreenState();
}

class _LoadMediaScreenState extends State<LoadMediaScreen> {
  int selectedTabIndex = 0;
  String searchMedia = '';
  bool isSortNewestFirst = true;
  final TextEditingController _searchController = TextEditingController();

  List<Media> demoMediaList = [
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

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List get filteredMediaList => demoMediaList.where((m) {
    final isType = selectedTabIndex == 0 ? m.type == "Audio" : m.type == "Video";
    final name =
        m.path.split('/').last.split('.').first.toLowerCase();
    final query = searchMedia.toLowerCase();
    return isType && name.contains(query);
  }).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings, color: Color(0xFF215B9D)),
          ),
        ],
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            "Cancel",
            style: TextStyle(color: Color(0XFF90C5E0), fontSize: 15),
          ),
        ),
        leadingWidth: 75,
        title: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(3),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTabSwitch("Audio", 0),
              _buildTabSwitch("Video", 1),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                style: const TextStyle(color: Color(0xFF718CA5)),
                cursorColor: const Color(0xFF718CA5),
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    searchMedia = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search in your library...',
                  hintStyle: const TextStyle(color: Color(0xFF718CA5)),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF718CA5),
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.mic, color: Color(0xFF718CA5)),
                  ),
                  filled: true,
                  fillColor: const Color(0xFF2F3D4C),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: selectedTabIndex == 0
                  ? AudioTab(audioList: filteredMediaList)
                  : VideoTab(videoList: filteredMediaList),
            ),
            const SizedBox(height: 10),
            IconButton(
              onPressed: () => _showSortOptionsDialog(context),
              icon: const Icon(
                Icons.filter_list,
                color: Color(0xFF215B9D),
                size: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabSwitch(String label, int index) {
    final bool isSelected = selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => selectedTabIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2F3D4C) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            color: isSelected
                ? const Color(0XFF90C5E0)
                : const Color(0xFF394753),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showSortOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Sort by time',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ListTile(
                title: const Text('Newest to Oldest'),
                trailing: isSortNewestFirst == true
                    ? const Icon(Icons.check, color: Colors.cyan, size: 45)
                    : null,
                onTap: () {
                  isSortNewestFirst == false ? sortToggle() : null;
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Oldest to Newest'),
                trailing: isSortNewestFirst == false
                    ? const Icon(Icons.check, color: Colors.cyan, size: 45)
                    : null,
                onTap: () {
                  isSortNewestFirst == true ? sortToggle() : null;
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void sortToggle() {
    setState(() {
      demoMediaList.sort((a, b) => isSortNewestFirst
          ? a.lastModified.compareTo(b.lastModified)
          : b.lastModified.compareTo(a.lastModified));
      isSortNewestFirst = !isSortNewestFirst;
      log('$isSortNewestFirst');
    });
  }
}
