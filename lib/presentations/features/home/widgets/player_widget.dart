import 'package:flutter/material.dart';
import 'package:media_manager/core/utils/app_colors.dart';
import 'package:media_manager/presentations/features/home/widgets/media_player/media_player_controller.dart';
import 'package:media_manager/presentations/features/home/widgets/video_widget.dart';
import 'package:provider/provider.dart';

class PlayerWidget extends StatelessWidget {

  const PlayerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.read<MediaPlayerController>();

    return Expanded(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: controller.isVideo
                        ? AppColors.iconVideo.withValues(alpha: 0.2)
                        : AppColors.iconAudio.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    controller.isVideo
                        ? Icons.ondemand_video
                        : Icons.play_circle_outline,
                    color: controller.isVideo
                        ? AppColors.iconVideo
                        : AppColors.iconAudio,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.currentMedia!.path
                            .split('/')
                            .last
                            .split('.')
                            .first,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        controller.currentMedia!.type,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 24),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          if (controller.isVideo)
            Expanded(child: VideoWidget()),
        ],
      ),
    );
  }
}
