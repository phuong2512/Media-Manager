import 'package:flutter/material.dart';
import 'package:media_download_manager/views/load_media/load_media_screen.dart';
import 'package:media_download_manager/widgets/media_options_bottom_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List demoAudioList = [
    {
      "path": "audio/audio1.mp3",
      "duration": "05:00",
      "size": 10,
      "last_modified": '2025-09-15 14:30:25',
    },
    {
      "path": "audio/audio2.mp3",
      "duration": "00:50",
      "size": 15,
      "last_modified": '2025-09-15 15:30:25',
    },
    {
      "path": "audio/audio3.mp3",
      "duration": "03:05",
      "size": 20,
      "last_modified": '2025-09-15 14:30:25',
    },
  ];
  List demoVideoList = [
    {
      "path": "video/video1.mp4",
      "duration": "05:00",
      "size": 10,
      "last_modified": '2025-09-14 14:30:25',
    },
    {
      "path": "video/video2.mp4",
      "duration": "00:50",
      "size": 15,
      "last_modified": '2025-09-15 10:30:25',
    },
    {
      "path": "video/video3.mp4",
      "duration": "03:05",
      "size": 20,
      "last_modified": '2025-09-10 14:30:25',
    },
  ];

  @override
  Widget build(BuildContext context) {
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
                _homeMediaListTile('Audio', demoAudioList),
                _homeMediaListTile('Video', demoVideoList),
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
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoadMediaScreen()),
    );
  }

  Widget _homeMediaListTile(String mediaType, List mediaList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          mediaType == "Audio" ? "Audio" : "Video",
          style: const TextStyle(fontSize: 15, color: Colors.white60),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: mediaList.length,
          itemBuilder: (context, index) {
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              leading: mediaType == "Audio"
                  ? Icon(Icons.play_circle_outline, color: Color(0xFFD48403))
                  : const Icon(Icons.ondemand_video, color: Colors.red),
              title: Text(
                mediaList[index]['path'].split('/').last.split('.').first,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                "${mediaList[index]['size']}Mb | ${mediaList[index]['duration']} | ${mediaList[index]['path'].split('.').last} ",
              ),
              onLongPress: () => showMediaOptionsBottomSheet(context: context),
              trailing: IconButton(
                onPressed: () => showMediaOptionsBottomSheet(context: context),
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
