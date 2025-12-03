import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:media_manager/presentations/features/home/widgets/media_player/media_player_controller.dart';

class VideoWidget extends StatelessWidget {
  final MediaPlayerController controller;

  const VideoWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Video(controller: controller.videoController!, controls: null),
        ),
      ),
    );
  }
}
