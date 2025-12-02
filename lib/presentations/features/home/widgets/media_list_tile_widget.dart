import 'package:flutter/material.dart';
import 'package:media_manager/core/models/media.dart';
import 'package:media_manager/core/utils/app_colors.dart';
import 'package:media_manager/core/utils/format.dart';
import 'package:media_manager/presentations/features/home/home_controller.dart';

class MediaListTileWidget extends StatelessWidget {
  final String mediaType;
  final List<Media> mediaList;
  final HomeController controller;
  final void Function(Media) onTap;
  final void Function(Media) onLongPress;
  final void Function(Media) onIconPress;

  const MediaListTileWidget({
    super.key,
    required this.mediaType,
    required this.mediaList,
    required this.controller,
    required this.onTap,
    required this.onLongPress,
    required this.onIconPress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Text(
          mediaType,
          style: const TextStyle(fontSize: 15, color: Colors.white60),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: mediaList.length,
          itemBuilder: (context, index) {
            final media = mediaList[index];
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              leading: media.type == "Audio"
                  ? const Icon(
                      Icons.play_circle_outline,
                      color: AppColors.iconAudio,
                    )
                  : const Icon(
                      Icons.ondemand_video,
                      color: AppColors.iconVideo,
                    ),
              title: Text(
                media.path.split('/').last.split('.').first,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                "${formatBytes(media.size)} | ${media.duration} | ${media.path.split('.').last}",
              ),
              onTap: () => onTap(media),
              onLongPress: () => onLongPress(media),
              trailing: IconButton(
                onPressed: () => onIconPress(media),
                icon: const Icon(Icons.more_horiz),
                color: Colors.white,
              ),
            );
          },
        ),
      ],
    );
  }
}
