import 'package:flutter/material.dart';
import 'package:media_manager/core/di/locator.dart';
import 'package:media_manager/core/utils/app_colors.dart';
import 'package:media_manager/features/home/presentation/controller/home_controller.dart';
import 'package:media_manager/features/home/presentation/widgets/media_player/media_player_dialog.dart';
import 'package:media_manager/features/media/domain/entities/media.dart';
import 'package:media_manager/features/media/presentation/pages/media_list_screen.dart';
import 'package:media_manager/core/utils/format.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = getIt<HomeController>();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                      _controller.clearHomeMediaList();
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
      body: _HomeBody(controller: _controller),
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
              color: Colors.black.withAlpha(77),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: IconButton(
          icon: const Icon(Icons.add, size: 35, color: Colors.white),
          onPressed: () => _addMediaToHome(context),
        ),
      ),
    );
  }

  void _addMediaToHome(BuildContext context) async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => const MediaListScreen(),
    );

    if (result != null && result is Media) {
      if (!mounted) return;
      _controller.addToHome(result);
    }
  }
}

class _HomeBody extends StatelessWidget {
  final HomeController controller;

  const _HomeBody({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: StreamBuilder<bool>(
          stream: controller.isLoadingStream,
          initialData: controller.isLoadingHomeMedia,
          builder: (context, loadingSnapshot) {
            final isLoading = loadingSnapshot.data ?? true;

            if (isLoading) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.cyan),
                    SizedBox(height: 10),
                    Text('Loading', style: TextStyle(color: Colors.white60)),
                  ],
                ),
              );
            }

            return StreamBuilder<List<Media>>(
              stream: controller.homeMediaListStream,
              initialData: controller.homeMediaList,
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
                      _homeMediaListTile("Audio", homeAudioList, context),
                      const SizedBox(height: 10),
                      _homeMediaListTile("Video", homeVideoList, context),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _homeMediaListTile(
    String mediaType,
    List<Media> mediaList,
    BuildContext context,
  ) {
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
              onTap: () => _playMedia(media, context),
              onLongPress: () => _handleMediaOptions(media, context),
              trailing: IconButton(
                onPressed: () => _handleMediaOptions(media, context),
                icon: const Icon(Icons.more_horiz),
                color: Colors.white,
              ),
            );
          },
        ),
      ],
    );
  }

  void _handleMediaOptions(Media media, BuildContext context) async {
    final message = await controller.handleMediaOptions(context, media);

    if (message != null && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _playMedia(Media media, BuildContext context) {
    showMediaPlayerDialog(context, media);
  }
}
