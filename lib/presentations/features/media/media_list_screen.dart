import 'package:flutter/material.dart';
import 'package:media_manager/core/di/locator.dart';
import 'package:media_manager/core/models/media.dart';
import 'package:media_manager/core/utils/app_colors.dart';
import 'package:media_manager/presentations/features/media/media_list_controller.dart';
import 'package:media_manager/presentations/features/media/widgets/audio_tab.dart';
import 'package:media_manager/presentations/features/media/widgets/media_search_bar.dart';
import 'package:media_manager/presentations/features/media/widgets/media_switch_tab.dart';
import 'package:media_manager/presentations/features/media/widgets/sort_options_dialog.dart';
import 'package:media_manager/presentations/features/media/widgets/video_tab.dart';
import 'package:provider/provider.dart';

class MediaListScreen extends StatelessWidget {
  const MediaListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MediaListController>(
      create: (_) {
        final controller = getIt<MediaListController>();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          controller.scanDeviceDirectory();
        });
        return controller;
      },
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
  late final _controller = context.read<MediaListController>();

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
    if (state == AppLifecycleState.resumed) {
      _controller.rescanDeviceDirectory();
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
          return const Scaffold(
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
            title: MediaSwitchTab(
              selectedIndex: selectedTabIndex,
              onTabSelected: (index) =>
                  setState(() => selectedTabIndex = index),
            ),
          ),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MediaSearchBar(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: StreamBuilder<List<Media>>(
                    stream: _controller.mediaListStream,
                    builder: (context, mediaSnapshot) {
                      final filteredList = _controller.filteredLibrary(
                        type: selectedTabIndex == 0 ? "Audio" : "Video",
                        query: _searchController.text,
                      );
                      return selectedTabIndex == 0
                          ? AudioTab(
                              audioList: filteredList,
                              onMediaOptionsPressed: handleOptions,
                            )
                          : VideoTab(
                              videoList: filteredList,
                              onMediaOptionsPressed: handleOptions,
                            );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                IconButton(
                  onPressed: () => _showSortOptions(context),
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

  Future<void> handleOptions(Media media) => _handleMediaOptions(media);

  Future<void> _handleMediaOptions(Media media) async {
    final message = await _controller.handleMediaOptions(context, media);
    if (message != null && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _showSortOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => StreamBuilder<SortOrder>(
        stream: _controller.sortOrderStream,
        initialData: _controller.sortOrder,
        builder: (context, snapshot) {
          return SortOptionsDialog(
            currentSortOrder: snapshot.data ?? SortOrder.none,
            onSortSelected: _controller.sortToggleByLastModified,
          );
        },
      ),
    );
  }
}
