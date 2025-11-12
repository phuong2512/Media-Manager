import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:media_manager/core/di/locator.dart';
import 'package:media_manager/features/home/presentation/widgets/media_player/media_player_controller.dart';
import 'package:media_manager/core/utils/app_colors.dart';
import 'package:media_manager/features/media/domain/entities/media.dart';

Future<void> showMediaPlayerDialog(BuildContext context, Media media) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Provider<MediaPlayerController>(
        create: (_) => getIt<MediaPlayerController>(),
        dispose: (_, controller) => controller.dispose(),
        child: MediaPlayerDialog(media: media),
      );
    },
  );
}

class MediaPlayerDialog extends StatefulWidget {
  final Media media;

  const MediaPlayerDialog({super.key, required this.media});

  @override
  State<MediaPlayerDialog> createState() => _MediaPlayerDialogState();
}

class _MediaPlayerDialogState extends State<MediaPlayerDialog> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Provider.of<MediaPlayerController>(
        context,
        listen: false,
      );
      controller.playMedia(widget.media);
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<MediaPlayerController>(
      context,
      listen: false,
    );

    return StreamBuilder<bool>(
      stream: controller.isInitializedStream,
      initialData: controller.isInitialized,
      builder: (context, initSnapshot) {
        final isInitialized = initSnapshot.data ?? false;

        if (!isInitialized) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.cyan),
          );
        }

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: controller.isVideo ? 600 : 200,
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
      },
    );
  }

  Widget _buildPlayer(BuildContext context, MediaPlayerController controller) {
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
            Expanded(child: _buildVideoPlayer(controller)),
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
        StreamBuilder<Duration>(
          stream: controller.positionStream,
          initialData: controller.position,
          builder: (context, positionSnapshot) {
            return StreamBuilder<Duration>(
              stream: controller.durationStream,
              initialData: controller.duration,
              builder: (context, durationSnapshot) {
                final position = positionSnapshot.data ?? Duration.zero;
                final duration = durationSnapshot.data ?? Duration.zero;

                return Slider(
                  value: position.inSeconds.toDouble(),
                  min: 0,
                  max: duration.inSeconds.toDouble(),
                  onChanged: (value) {
                    controller.seek(Duration(seconds: value.toInt()));
                  },
                );
              },
            );
          },
        ),
        Container(
          padding: const EdgeInsets.all(10),
          child: StreamBuilder<bool>(
            stream: controller.isPlayingStream,
            initialData: controller.isPlaying,
            builder: (context, playingSnapshot) {
              final isPlaying = playingSnapshot.data ?? false;

              return Container(
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
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () => controller.togglePlayPause(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
