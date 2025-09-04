import 'package:flutter/material.dart';
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

  List demoAudioList = [
    {
      "name": "Audio 1",
      "path": "audio/audio1.mp3",
      "duration": "05:00",
      "size": 10,
    },
    {
      "name": "Audio 2",
      "path": "audio/audio2.mp3",
      "duration": "0:50",
      "size": 15,
    },
    {
      "name": "Audio 3",
      "path": "audio/audio3.mp3",
      "duration": "03:05",
      "size": 20,
    },
  ];
  List demoVideoList = [
    {
      "path": "video/video1.mp4",
      "duration": "05:00",
      "size": 10,
    },
    {
      "path": "video/video2.mp4",
      "duration": "0:50",
      "size": 15,
    },
    {
      "path": "video/video3.mp4",
      "duration": "03:05",
      "size": 20,
    },
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
            Expanded(child: selectedTabIndex == 0 ? AudioTab(audioList: demoAudioList,) : VideoTab(videoList: demoVideoList,)),
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
                trailing: isSortNewestFirst
                    ? const Icon(Icons.check, color: Colors.cyan, size: 45)
                    : null,
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Oldest to Newest'),
                trailing: !isSortNewestFirst
                    ? const Icon(Icons.check, color: Colors.cyan, size: 45)
                    : null,
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
