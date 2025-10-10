import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:media_manager/controllers/media_player_controller.dart';
import 'package:media_manager/models/media.dart';
import 'package:media_manager/utils/app_colors.dart';
import 'package:provider/provider.dart';

Future<void> showMediaPlayerDialog(BuildContext context, Media media) async {
  final playerController = context.read<MediaPlayerController>();

  await playerController.playMedia(media);

  if (!context.mounted) return;

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => ChangeNotifierProvider.value(
      value: playerController,
      child: const MediaPlayerDialog(),
    ),
  );

  await playerController.disposePlayer();
}

class MediaPlayerDialog extends StatelessWidget {
  const MediaPlayerDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MediaPlayerController>();

    if (!controller.isInitialized) {
      return const Center(child: CircularProgressIndicator(color: Colors.cyan));
    }

    final isVideo = controller.isVideo;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: isVideo ? 600 : 200,
          maxWidth: 500,
        ),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.7),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPlayer(context, controller),
            _buildControls(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayer(
    BuildContext context,
    MediaPlayerController controller,
  ) {
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
                    controller.isVideo ? Icons.ondemand_video : Icons.play_circle_outline,
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
          Expanded(child: controller.isVideo ? _buildVideoPlayer(controller) : SizedBox()),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer(MediaPlayerController controller) {
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

  Widget _buildControls(MediaPlayerController controller) {
    return Column(
      children: [
        Slider(
          value: controller.position.inSeconds.toDouble(),
          min: 0,
          max: controller.duration.inSeconds.toDouble(),
          onChanged: (value) {
            controller.seek(Duration(seconds: value.toInt()));
          },
        ),
        Container(
          padding: const EdgeInsets.all(10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade400, Colors.purple.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: IconButton(
              iconSize: 48,
              icon: Icon(
                controller.isPlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                color: Colors.white,
              ),
              onPressed: () => controller.togglePlayPause(),
            ),
          ),
        ),
      ],
    );
  }
}
