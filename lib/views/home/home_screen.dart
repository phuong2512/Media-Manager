import 'package:flutter/material.dart';
import 'package:media_manager/controllers/media_controller.dart';
import 'package:media_manager/utils/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:media_manager/models/media.dart';
import 'package:media_manager/views/load_media/load_media_screen.dart';
import 'package:media_manager/utils/format.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MediaController>();
    final homeAudioList = controller.audioList;
    final homeVideoList = controller.videoList;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Settings'),
                  content: ElevatedButton(
                    onPressed: () {
                      controller.clearHomeMediaList();
                      Navigator.pop(context);
                    },
                    child: const Text('Delete Home Media List'),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Drum Removal', style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold, color: Colors.white),),

                _homeMediaListTile("Audio", homeAudioList),
                const SizedBox(height: 10),
                _homeMediaListTile("Video", homeVideoList),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Colors.blue, Colors.purple],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: IconButton(
          icon: const Icon(Icons.add, size: 35, color: Colors.white),
          onPressed: _addMediaToHome,
        ),
      ),
    );
  }

  void _addMediaToHome() async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => const LoadMediaScreen(),
    );

    if (result != null && result is Media) {
      if (!mounted) return;
      context.read<MediaController>().addToHome(result);
    }
  }

  void _handleMediaOptions(Media media) async {
    final controller = context.read<MediaController>();
    final message = await controller.handleMediaOptions(context, media);

    if (message != null && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Widget _homeMediaListTile(String mediaType, List mediaList) {
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
              onLongPress: () => _handleMediaOptions(media),
              trailing: IconButton(
                onPressed: () => _handleMediaOptions(media),
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
