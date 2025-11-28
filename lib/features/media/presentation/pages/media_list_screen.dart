import 'package:flutter/material.dart';
import 'package:media_manager/core/di/locator.dart';
import 'package:media_manager/core/utils/app_colors.dart';
import 'package:media_manager/features/media/domain/entities/media.dart';
import 'package:media_manager/features/media/presentation/controller/media_list_controller.dart';
import 'package:media_manager/features/media/presentation/widgets/audio_tab.dart';
import 'package:media_manager/features/media/presentation/widgets/video_tab.dart';
import 'package:provider/provider.dart';

class MediaListScreen extends StatelessWidget {
  const MediaListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider<MediaListController>(
      create: (_) {
        final controller = getIt<MediaListController>();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          controller.scanDeviceDirectory();
        });
        return controller;
      },
      dispose: (_, controller) => controller.dispose(),
      child: const _MediaListScreenContent(),
    );
  }
}

class _MediaListScreenContent extends StatefulWidget {
  const _MediaListScreenContent();

  @override
  State<_MediaListScreenContent> createState() =>
      _MediaListScreenContentState();
}

class _MediaListScreenContentState extends State<_MediaListScreenContent>
    with WidgetsBindingObserver {
  int selectedTabIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    final controller = Provider.of<MediaListController>(context, listen: false);
    switch (state) {
      case AppLifecycleState.resumed:
        if (controller.isLibraryScanned) {
          controller.rescanDeviceDirectory();
        }
      case AppLifecycleState.detached:
      //TODO: Handle this case.
      case AppLifecycleState.inactive:
      //TODO: Handle this case.
      case AppLifecycleState.hidden:
      //TODO: Handle this case.
      case AppLifecycleState.paused:
      //TODO: Handle this case.
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<MediaListController>(context, listen: false);
    return StreamBuilder<bool>(
      stream: controller.isScanningStream,
      initialData: controller.isScanning,
      builder: (context, scanningSnapshot) {
        final isScanning = scanningSnapshot.data ?? false;

        if (isScanning) {
          return SafeArea(
            bottom: false,
            child: Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: Colors.cyan),
                    const SizedBox(height: 10),
                    const Text(
                      'Loading',
                      style: TextStyle(color: Colors.white60),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            leading: Padding(
              padding: const EdgeInsets.only(left: 25),
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 15),
                ),
              ),
            ),
            leadingWidth: 100,
            title: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTabSwitch("Audio", 0),
                  _buildTabSwitch("Video", 1),
                ],
              ),
            ),
          ),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 35),
                  child: TextField(
                    style: const TextStyle(color: AppColors.textSecondary),
                    cursorColor: AppColors.textSecondary,
                    controller: _searchController,
                    onChanged: (value) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search in your library...',
                      hintStyle: const TextStyle(
                        color: AppColors.textSecondary,
                      ),
                      prefixIcon: const Icon(
                        size: 30,
                        Icons.search,
                        color: AppColors.textSecondary,
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.mic,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      contentPadding: EdgeInsets.zero,
                      filled: true,
                      fillColor: AppColors.fill,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: StreamBuilder<List<Media>>(
                    stream: controller.mediaListStream,
                    builder: (context, mediaSnapshot) {
                      final filteredList = controller.filteredLibrary(
                        type: selectedTabIndex == 0 ? "Audio" : "Video",
                        query: _searchController.text,
                      );
                      return selectedTabIndex == 0
                          ? AudioTab(
                              audioList: filteredList,
                              onMediaOptionsPressed: (media) =>
                                  _handleMediaOptions(media, controller),
                            )
                          : VideoTab(
                              videoList: filteredList,
                              onMediaOptionsPressed: (media) =>
                                  _handleMediaOptions(media, controller),
                            );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                IconButton(
                  onPressed: () => _showSortOptionsDialog(context, controller),
                  icon: const Icon(
                    Icons.filter_list,
                    color: AppColors.iconPrimary,
                    size: 30,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabSwitch(String label, int index) {
    final bool isSelected = selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => selectedTabIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.fill : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            color: isSelected ? AppColors.textPrimary : AppColors.textTertiary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _handleMediaOptions(Media media, MediaListController controller) async {
    final message = await controller.handleMediaOptions(context, media);

    if (message != null && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _showSortOptionsDialog(
    BuildContext context,
    MediaListController controller,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return StreamBuilder<SortOrder>(
          stream: controller.sortOrderStream,
          initialData: controller.sortOrder,
          builder: (context, snapshot) {
            final currentSortOrder = snapshot.data ?? SortOrder.none;

            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Sắp xếp theo thời gian',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    title: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Row(
                        children: [
                          const Text(
                            'Từ mới đến cũ',
                            style: TextStyle(fontSize: 19),
                          ),
                          const SizedBox(width: 10),
                          if (currentSortOrder == SortOrder.newestFirst)
                            const Icon(
                              Icons.check,
                              color: Colors.cyan,
                              size: 45,
                            ),
                        ],
                      ),
                    ),
                    onTap: () {
                      controller.sortToggleByLastModified(
                        SortOrder.newestFirst,
                      );
                      Navigator.pop(dialogContext);
                    },
                  ),
                  ListTile(
                    title: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Row(
                        children: [
                          const Text(
                            'Từ cũ đến mới',
                            style: TextStyle(fontSize: 19),
                          ),
                          const SizedBox(width: 10),
                          if (currentSortOrder == SortOrder.oldestFirst)
                            const Icon(
                              Icons.check,
                              color: Colors.cyan,
                              size: 45,
                            ),
                        ],
                      ),
                    ),
                    onTap: () {
                      controller.sortToggleByLastModified(
                        SortOrder.oldestFirst,
                      );
                      Navigator.pop(dialogContext);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
