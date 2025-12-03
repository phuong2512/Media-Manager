import 'dart:typed_data'; // Import để dùng Uint8List

import 'package:flutter/material.dart';
import 'package:media_manager/core/models/media.dart';
import 'package:media_manager/core/utils/app_colors.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class VideoTab extends StatelessWidget {
  final List videoList;
  final Function(Media) onMediaOptionsPressed;

  const VideoTab({
    super.key,
    required this.videoList,
    required this.onMediaOptionsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: videoList.isEmpty
                ? const Center(
                    child: Text(
                      "There is no video",
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(5),
                    itemCount: videoList.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 5,
                          mainAxisSpacing: 5,
                        ),
                    itemBuilder: (context, index) {
                      final video = videoList[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.pop(context, video);
                        },
                        onLongPress: () => onMediaOptionsPressed(video),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            _buildThumbnail(video.path),

                            Positioned(
                              bottom: 4,
                              right: 4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.7),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  video.duration,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnail(String path) {
    return FutureBuilder<Uint8List?>(
      future: VideoThumbnail.thumbnailData(
        video: path,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 128,
        quality: 100,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.data != null) {
          return Image.memory(snapshot.data!, fit: BoxFit.cover);
        }
        return Container(
          color: AppColors.fill,
          child: const Center(
            child: Icon(
              Icons.play_circle_outline,
              color: Colors.white24,
              size: 30,
            ),
          ),
        );
      },
    );
  }
}
