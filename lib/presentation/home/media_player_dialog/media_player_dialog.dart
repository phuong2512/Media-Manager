import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:media_manager/presentation/home/media_player_dialog/media_player_controller.dart';
import 'package:media_manager/core/di/locator.dart';
import 'package:media_manager/data/models/media.dart';
import 'package:media_manager/core/utils/app_colors.dart';

Future<void> showMediaPlayerDialog(BuildContext context, Media media) async {
  final controller = getIt<MediaPlayerController>();

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) =>
        MediaPlayerDialog(media: media, controller: controller),
  );

  // Dispose controller sau khi dialog đóng
  await controller.dispose();
}

class MediaPlayerDialog extends StatefulWidget {
  final Media media;
  final MediaPlayerController controller;

  const MediaPlayerDialog({
    super.key,
    required this.media,
    required this.controller,
  });

  @override
  State<MediaPlayerDialog> createState() => _MediaPlayerDialogState();
}

class _MediaPlayerDialogState extends State<MediaPlayerDialog> {
  @override
  void initState() {
    super.initState();
    widget.controller.playMedia(widget.media);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: widget.controller.isInitializedStream,
      initialData: widget.controller.isInitialized,
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
              maxHeight: widget.controller.isVideo ? 600 : 200,
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
              children: [_buildPlayer(context), _buildControls()],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlayer(BuildContext context) {
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
                    color: widget.controller.isVideo
                        ? AppColors.iconVideo.withValues(alpha: 0.2)
                        : AppColors.iconAudio.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    widget.controller.isVideo
                        ? Icons.ondemand_video
                        : Icons.play_circle_outline,
                    color: widget.controller.isVideo
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
                        widget.controller.currentMedia!.path
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
                        widget.controller.currentMedia!.type,
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
          if (widget.controller.isVideo) Expanded(child: _buildVideoPlayer()),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer() {
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
          child: Video(
            controller: widget.controller.videoController!,
            controls: null,
          ),
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Column(
      children: [
        StreamBuilder<Duration>(
          stream: widget.controller.positionStream,
          initialData: widget.controller.position,
          builder: (context, positionSnapshot) {
            return StreamBuilder<Duration>(
              stream: widget.controller.durationStream,
              initialData: widget.controller.duration,
              builder: (context, durationSnapshot) {
                final position = positionSnapshot.data ?? Duration.zero;
                final duration = durationSnapshot.data ?? Duration.zero;

                return Slider(
                  value: position.inSeconds.toDouble(),
                  min: 0,
                  max: duration.inSeconds.toDouble(),
                  onChanged: (value) {
                    widget.controller.seek(Duration(seconds: value.toInt()));
                  },
                );
              },
            );
          },
        ),
        Container(
          padding: const EdgeInsets.all(10),
          child: StreamBuilder<bool>(
            stream: widget.controller.isPlayingStream,
            initialData: widget.controller.isPlaying,
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
                  onPressed: () => widget.controller.togglePlayPause(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
