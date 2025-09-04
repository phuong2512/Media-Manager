import 'dart:io';
import 'package:flutter/material.dart';
import 'package:media_download_manager/views/home/home_list_tile.dart';
import 'package:media_download_manager/views/load_media/load_media_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List demoAudioList = [
    {
      "path": "audio/audio1.mp3",
      "duraion": "05:00",
      "size": 10,
    },
    {
      "path": "audio/audio2.mp3",
      "duraion": "0:50",
      "size": 15,
    },
    {
      "path": "audio/audio3.mp3",
      "duraion": "03:05",
      "size": 20,
    },
  ];
  List demoVideoList = [
    {
      "path": "video/video1.mp4",
      "duraion": "05:00",
      "size": 10,
    },
    {
      "path": "video/video2.mp4",
      "duraion": "0:50",
      "size": 15,
    },
    {
      "path": "video/video3.mp4",
      "duraion": "03:05",
      "size": 20,
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
                HomeListTile(mediaType: 'Audio', mediaList: demoAudioList,),
                HomeListTile(mediaType: 'Video', mediaList: demoVideoList,),
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
    Navigator.push(context, MaterialPageRoute(builder: (context) => const LoadMediaScreen()));
  }

}
