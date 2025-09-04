import 'package:flutter/material.dart';
import 'package:media_download_manager/models/media.dart';
import 'package:media_download_manager/views/load_media/load_media_screen.dart';
import 'package:media_download_manager/widgets/bottom_sheets/media_options_bottom_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
  Widget build(BuildContext context) {
    final audioList = demoMediaList.where((m) => m.type == "Audio").toList();
    final videoList = demoMediaList.where((m) => m.type == "Video").toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Media Loader'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings, color: Color(0xFF215B9D)),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _homeMediaListTile("Audio", audioList),
                _homeMediaListTile("Video", videoList),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Colors.blue, Colors.purple],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: IconButton(
          icon: const Icon(Icons.add, color: Colors.white),
          onPressed: _addMediaToHome,
        ),
      ),
    );
  }

  void _addMediaToHome() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoadMediaScreen()),
    );

    if (result != null && result is Media) {
      setState(() {
        demoMediaList.add(result);
      });
    }
  }

  Widget _homeMediaListTile(String mediaType, List mediaList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          mediaType,
          style: const TextStyle(fontSize: 15, color: Colors.white60),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: mediaList.length,
          itemBuilder: (context, index) {
            final media = mediaList[index];
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              leading: media.type == "Audio"
                  ? Icon(Icons.play_circle_outline, color: Color(0xFFD48403))
                  : const Icon(Icons.ondemand_video, color: Colors.red),
              title: Text(
                media.path.split('/').last.split('.').first,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                "${media.size}Mb | ${media.duration} | ${media.path.split('.').last} ",
              ),
              onLongPress: () => showMediaOptionsBottomSheet(context: context, media: media),
              trailing: IconButton(
                onPressed: () => showMediaOptionsBottomSheet(context: context, media: media),
                icon: const Icon(Icons.more_horiz),
                color: Colors.white,
              ),
            );
          },
        ),
      ],
    );
  }
}
