import 'package:flutter/material.dart';
import 'package:media_download_manager/widgets/media_options_bottom_sheet.dart';

class AudioTab extends StatelessWidget {
  final List audioList;

  const AudioTab({super.key, required this.audioList});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: audioList.length,
              itemBuilder: (context, index) {
                final audio = audioList[index];
                return ListTile(
                  leading: Icon(
                    Icons.play_circle_outline,
                    color: Color(0xFFD48403),
                  ),
                  title: Text(
                    audio['path'].split('/').last.split('.').first,
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    "${audio['size']}Mb | ${audio['duration']} | ${audio['path'].split('.').last} ",
                  ),
                  onTap: () {},
                  onLongPress: () => showMediaOptionsBottomSheet(context: context),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
