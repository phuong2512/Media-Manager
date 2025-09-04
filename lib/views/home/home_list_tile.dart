import 'package:flutter/material.dart';

class HomeListTile extends StatelessWidget {
  final String mediaType;
  final List mediaList;

  const HomeListTile({
    super.key,
    required this.mediaType,
    required this.mediaList,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          mediaType == "Audio" ? "Audio" : "Video",
          style: const TextStyle(fontSize: 15, color: Colors.white60),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: mediaList.length,
          itemBuilder: (context, index) {
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              leading: mediaType == "Audio"
                  ? Icon(Icons.play_circle_outline, color: Colors.amber)
                  : const Icon(Icons.ondemand_video, color: Colors.red),
              title: Text(
                mediaList[index]['name'],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                "${mediaList[index]['size']}Mb | ${mediaList[index]['duraion']} | ${mediaList[index]['path'].split('.').last} ",
              ),
              onLongPress: () {},
              trailing: IconButton(
                onPressed: () {},
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
