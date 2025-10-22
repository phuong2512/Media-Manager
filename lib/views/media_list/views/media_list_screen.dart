import 'package:flutter/material.dart';
import 'package:media_manager/di/locator.dart';
import 'package:media_manager/views/media_list/provider/media_list_controller.dart';
import 'package:media_manager/utils/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:media_manager/models/media.dart';
import 'package:media_manager/views/media_list/views/audio_tab.dart';
import 'package:media_manager/views/media_list/views/video_tab.dart';

class MediaListScreen extends StatelessWidget {
  const MediaListScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<MediaListController>(),
      child: _MediaListScreenView(),
    );
  }
}

class _MediaListScreenView extends StatefulWidget {
  @override
  State<_MediaListScreenView> createState() => _MediaListScreenViewState();
}

class _MediaListScreenViewState extends State<_MediaListScreenView> {
  int selectedTabIndex = 0;
  String searchMedia = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMediaLibrary();
  }

  Future<void> _loadMediaLibrary() async {
    final controller = context.read<MediaListController>();
    if (!controller.isLibraryScanned && !controller.isScanning) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await controller.scanDeviceDirectory();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleMediaOptions(Media media) async {
    final controller = context.read<MediaListController>();
    final message = await controller.handleMediaOptions(context, media);

    if (message != null && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MediaListController>();
    final isScanning = controller.isScanning;

    return isScanning
        ? SafeArea(
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
          )
        : Scaffold(
            appBar: AppBar(
              leading: Padding(
                padding: const EdgeInsets.only(left: 25),
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                    ),
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
                      onChanged: (value) {
                        setState(() {
                          searchMedia = value;
                        });
                      },
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
                    child: selectedTabIndex == 0
                        ? AudioTab(
                            audioList: controller.filteredLibrary(
                              type: "Audio",
                              query: _searchController.text,
                            ),
                            onMediaOptionsPressed: _handleMediaOptions,
                          )
                        : VideoTab(
                            videoList: controller.filteredLibrary(
                              type: "Video",
                              query: _searchController.text,
                            ),
                            onMediaOptionsPressed: _handleMediaOptions,
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
    final controller = context.read<MediaListController>();
    showDialog(
      context: context,
      builder: (context) {
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
                      if (controller.sortOrder == SortOrder.newestFirst)
                        const Icon(Icons.check, color: Colors.cyan, size: 45),
                    ],
                  ),
                ),
                onTap: () {
                  controller.sortToggleByLastModified(SortOrder.newestFirst);
                  Navigator.pop(context);
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
                      if (controller.sortOrder == SortOrder.oldestFirst)
                        const Icon(Icons.check, color: Colors.cyan, size: 45),
                    ],
                  ),
                ),
                onTap: () {
                  controller.sortToggleByLastModified(SortOrder.oldestFirst);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
