import 'package:flutter/material.dart';
import 'package:media_manager/core/di/locator.dart';
import 'package:media_manager/core/models/media.dart';
import 'package:media_manager/core/utils/app_colors.dart';
import 'package:media_manager/presentations/features/home/widgets/media_player/media_player_controller.dart';
import 'package:media_manager/presentations/features/home/widgets/media_controller_widget.dart';
import 'package:media_manager/presentations/features/home/widgets/player_widget.dart';
import 'package:provider/provider.dart';

Future<void> showMediaPlayerDialog(BuildContext context, Media media) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return MediaPlayerDialog(media: media);
    },
  );
}

class MediaPlayerDialog extends StatelessWidget {
  final Media media;

  const MediaPlayerDialog({super.key, required this.media});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MediaPlayerController>(
      create: (_) => getIt<MediaPlayerController>()..playMedia(media),
      child: _MediaPlayerDialogContent(),
    );
  }
}

class _MediaPlayerDialogContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = context.read<MediaPlayerController>();

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
                PlayerWidget(),
                MediaControllerWidget(),
              ],
            ),
          ),
        );
      },
    );
  }
}
