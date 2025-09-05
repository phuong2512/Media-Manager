import 'package:flutter/material.dart';
import 'package:media_manager/widgets/option_list_tile.dart';

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
              onTap: () => Navigator.pop(context, 'rename'),
            ),
            OptionListTile(
              title: 'Share',
              icon: Icons.share_outlined,
              onTap: () => Navigator.pop(context),
            ),
            OptionListTile(
              title: 'Delete',
              icon: Icons.delete,
              onTap: () => Navigator.pop(context, 'delete'),
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

Future<String?> showMediaOptionsBottomSheet({required BuildContext context}) {
  return showModalBottomSheet<String>(
    useSafeArea: true,
    isScrollControlled: true,
    context: context,
    backgroundColor: const Color(0xFF19222A),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => const MediaOptionsBottomSheet(),
  );
}
