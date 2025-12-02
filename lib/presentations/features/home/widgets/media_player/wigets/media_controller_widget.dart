import 'package:flutter/material.dart';
import 'package:media_manager/presentations/features/home/widgets/media_player/media_player_controller.dart';

class MediaControllerWidget extends StatelessWidget {
  final MediaPlayerController controller;

  const MediaControllerWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
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
