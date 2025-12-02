import 'package:flutter/material.dart';
import 'package:media_manager/core/di/locator.dart';
import 'package:media_manager/core/models/media.dart';
import 'package:media_manager/core/utils/app_colors.dart';
import 'package:media_manager/core/utils/format.dart';
import 'package:media_manager/presentations/features/home/home_controller.dart';
import 'package:media_manager/presentations/features/home/widgets/media_player/media_player_dialog.dart';
import 'package:media_manager/presentations/features/media/media_list_screen.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider<HomeController>(
      create: (_) => getIt<HomeController>(),
      dispose: (_, controller) => controller.dispose(),
      child: const _HomeScreenContent(),
    );
  }
}

class _HomeScreenContent extends StatefulWidget {
  const _HomeScreenContent();

  @override
  State<_HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<_HomeScreenContent>
    with WidgetsBindingObserver {
  late final _controller = context.read<HomeController>();

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _controller.loadHomeMediaFromStorage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<HomeController>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Settings'),
                  content: ElevatedButton(
                    onPressed: () {
                      controller.clearHomeMediaList();
                      Navigator.pop(dialogContext);
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
      body: const _HomeBody(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildFAB(context, controller),
    );
  }

  Widget _buildFAB(BuildContext context, HomeController controller) {
    return Container(
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
        onPressed: () => _addMediaToHome(context, controller),
      ),
    );
  }

  void _addMediaToHome(BuildContext context, HomeController controller) async {
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
      if (!context.mounted) return;
      controller.addToHome(result);
    }
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<HomeController>(context, listen: false);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: StreamBuilder<bool>(
          stream: controller.isLoadingStream,
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
                      _homeMediaListTile(
                        "Audio",
                        homeAudioList,
                        context,
                        controller,
                      ),
                      const SizedBox(height: 10),
                      _homeMediaListTile(
                        "Video",
                        homeVideoList,
                        context,
                        controller,
                      ),
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
    HomeController controller,
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
              onLongPress: () =>
                  _handleMediaOptions(media, context, controller),
              trailing: IconButton(
                onPressed: () =>
                    _handleMediaOptions(media, context, controller),
                icon: const Icon(Icons.more_horiz),
                color: Colors.white,
              ),
            );
          },
        ),
      ],
    );
  }

  void _handleMediaOptions(
    Media media,
    BuildContext context,
    HomeController controller,
  ) async {
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
