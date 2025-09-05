import 'package:flutter/material.dart';
import 'package:media_manager/models/media.dart';

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
            child: GridView.builder(
              padding: const EdgeInsets.all(5),
              itemCount: videoList.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                      Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFF2F3D4C),
                        ),
                      ),
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Text(
                          video.duration,
                          style: const TextStyle(color: Colors.white),
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
}
