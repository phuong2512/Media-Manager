import 'package:flutter/material.dart';
import 'package:media_manager/core/di/locator.dart';
import 'package:media_manager/presentation/media_list/media_list_controller.dart';
import 'package:media_manager/core/utils/app_colors.dart';
import 'package:media_manager/data/models/media.dart';
import 'package:media_manager/presentation/media_list/audio_tab.dart';
import 'package:media_manager/presentation/media_list/video_tab.dart';

class MediaListScreen extends StatefulWidget {
  const MediaListScreen({super.key});

  @override
  State<MediaListScreen> createState() => _MediaListScreenState();
}

class _MediaListScreenState extends State<MediaListScreen> {
  late final MediaListController _controller;
  int selectedTabIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = getIt<MediaListController>();
    _loadMediaLibrary();
  }

  Future<void> _loadMediaLibrary() async {
    if (!_controller.isLibraryScanned && !_controller.isScanning) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _controller.scanDeviceDirectory();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleMediaOptions(Media media) async {
    final message = await _controller.handleMediaOptions(context, media);

    if (message != null && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: _controller.isScanningStream,
      initialData: _controller.isScanning,
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
                    CircularProgressIndicator(color: Colors.cyan),
                    SizedBox(height: 10),
                    Text('Loading', style: TextStyle(color: Colors.white60)),
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
                    stream: _controller.mediaListStream,
                    initialData: _controller.libraryMediaList,
                    builder: (context, mediaSnapshot) {
                      final filteredList = _controller.filteredLibrary(
                        type: selectedTabIndex == 0 ? "Audio" : "Video",
                        query: _searchController.text,
                      );

                      return selectedTabIndex == 0
                          ? AudioTab(
                              audioList: filteredList,
                              onMediaOptionsPressed: _handleMediaOptions,
                            )
                          : VideoTab(
                              videoList: filteredList,
                              onMediaOptionsPressed: _handleMediaOptions,
                            );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                IconButton(
                  onPressed: () => _showSortOptionsDialog(context),
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

  void _showSortOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return StreamBuilder<SortOrder>(
          stream: _controller.sortOrderStream,
          initialData: _controller.sortOrder,
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
                          SizedBox(width: 10),
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
                      _controller.sortToggleByLastModified(
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
                          SizedBox(width: 10),
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
                      _controller.sortToggleByLastModified(
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
