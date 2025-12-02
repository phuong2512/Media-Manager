import 'package:flutter/material.dart';
import 'package:media_manager/core/di/locator.dart';
import 'package:media_manager/core/models/media.dart';
import 'package:media_manager/presentations/features/home/home_controller.dart';
import 'package:media_manager/presentations/features/home/widgets/floating_action_button_widget.dart';
import 'package:media_manager/presentations/features/home/widgets/home_body.dart';
import 'package:media_manager/presentations/features/home/widgets/media_player/media_player_dialog.dart';
import 'package:media_manager/presentations/features/media/media_list_screen.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HomeController>(
      create: (_) => getIt<HomeController>(),
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
                      _controller.clearHomeMediaList();
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: StreamBuilder<bool>(
            stream: _controller.isLoadingStream,
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

              return HomeBody(
                controller: _controller,
                onPlayMedia: _playMedia,
                onHandleOptions: _handleMediaOptions,
              );
            },
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButtonWidget(
        controller: _controller,
        onPress: _addMediaToHome,
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
      builder: (context) => const MediaListScreen(),
    );

    if (result != null && result is Media) {
      if (!context.mounted) return;
      _controller.addToHome(result);
    }
  }

  void _handleMediaOptions(Media media) async {
    final message = await _controller.handleMediaOptions(context, media);

    if (message != null && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _playMedia(Media media) {
    showMediaPlayerDialog(context, media);
  }
}
