import 'package:flutter/material.dart';
import 'package:media_manager/core/utils/app_colors.dart';
import 'package:media_manager/features/media/domain/entities/media.dart';

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
                            Container(
                              decoration: const BoxDecoration(
                                color: AppColors.fill,
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
