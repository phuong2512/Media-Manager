import 'package:flutter/material.dart';
import 'package:media_download_manager/widgets/option_list_tile.dart';

class MediaOptionsBottomSheet extends StatelessWidget {
  const MediaOptionsBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(right: 15, left: 15, top: 15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            OptionListTile(
              title: 'Rename',
              icon: Icons.mode_edit_outline_outlined,
              function: () {},
            ),
            OptionListTile(
              title: 'Share',
              icon: Icons.share_outlined,
              function: () {},
            ),
            OptionListTile(
              title: 'Delete',
              icon: Icons.delete,
              function: () {},
            ),
            ListTile(
              textColor: Colors.white,
              title: const Center(child: Text('Cancel')),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showMediaOptionsBottomSheet({required BuildContext context}) {
  return showModalBottomSheet(
    useSafeArea: true,
    isScrollControlled: true,
    context: context,
    backgroundColor: const Color(0xFF19222A),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => MediaOptionsBottomSheet(),
  );
}
