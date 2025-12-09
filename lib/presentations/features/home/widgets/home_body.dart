import 'package:flutter/material.dart';
import 'package:media_manager/core/models/media.dart';
import 'package:media_manager/presentations/features/home/home_controller.dart';
import 'package:media_manager/presentations/features/home/widgets/media_list_tile.dart';
import 'package:provider/provider.dart';

class HomeBody extends StatelessWidget {
  final Function(Media) onPlayMedia;
  final Function(Media) onHandleOptions;

  const HomeBody({
    super.key,
    required this.onPlayMedia,
    required this.onHandleOptions,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.read<HomeController>();

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
                'Media List',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              MediaListTile(
                mediaType: 'Audio',
                mediaList: homeAudioList,
                onTap: onPlayMedia,
                onLongPress: onHandleOptions,
                onIconPress: onHandleOptions,
              ),
              const SizedBox(height: 10),
              MediaListTile(
                mediaType: 'Video',
                mediaList: homeVideoList,
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
