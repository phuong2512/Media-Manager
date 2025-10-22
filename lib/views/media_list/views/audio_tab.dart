import 'package:flutter/material.dart';
import 'package:media_manager/models/media.dart';
import 'package:media_manager/utils/app_colors.dart';
import 'package:media_manager/utils/format.dart';

class AudioTab extends StatelessWidget {
  final List audioList;
  final Function(Media) onMediaOptionsPressed;

  const AudioTab({
    super.key,
    required this.audioList,
    required this.onMediaOptionsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: audioList.isEmpty
                ? const Center(
                    child: Text(
                      "There is no audio",
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: audioList.length,
                    itemBuilder: (context, index) {
                      final audio = audioList[index];
                      return ListTile(
                        leading: const Icon(
                          Icons.play_circle_outline,
                          color: AppColors.iconAudio,
                        ),
                        title: Text(
                          audio.path.split('/').last.split('.').first,
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          "${formatBytes(audio.size)} | ${audio.duration} | ${audio.path.split('.').last}",
                        ),
                        onTap: () {
                          Navigator.pop(context, audio);
                        },
                        onLongPress: () => onMediaOptionsPressed(audio),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
