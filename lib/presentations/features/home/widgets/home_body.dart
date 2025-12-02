import 'package:flutter/material.dart';
import 'package:media_manager/core/models/media.dart';
import 'package:media_manager/presentations/features/home/home_controller.dart';
import 'package:media_manager/presentations/features/home/widgets/media_list_tile_widget.dart';

class HomeBody extends StatelessWidget {
  final HomeController controller;
  final Function(Media) onPlayMedia;
  final Function(Media) onHandleOptions;

  const HomeBody({
    super.key,
    required this.controller,
    required this.onPlayMedia,
    required this.onHandleOptions,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Media>>(
      stream: controller.homeMediaListStream,
      builder: (context, mediaSnapshot) {
        final homeAudioList = controller.audioList;
        final homeVideoList = controller.videoList;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Drum Removal',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              MediaListTileWidget(
                mediaType: 'Audio',
                mediaList: homeAudioList,
                controller: controller,
                onTap: onPlayMedia,
                onLongPress: onHandleOptions,
                onIconPress: onHandleOptions,
              ),
              const SizedBox(height: 10),
              MediaListTileWidget(
                mediaType: 'Video',
                mediaList: homeVideoList,
                controller: controller,
                onTap: onPlayMedia,
                onLongPress: onHandleOptions,
                onIconPress: onHandleOptions,
              ),
            ],
          ),
        );
      },
    );
  }
}
