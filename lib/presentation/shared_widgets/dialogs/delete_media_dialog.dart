import 'package:flutter/material.dart';
import 'package:media_manager/core/utils/app_colors.dart';
import 'package:media_manager/features/media/domain/entities/media.dart';

class DeleteMediaDialog extends StatelessWidget {
  final Media media;

  const DeleteMediaDialog({super.key, required this.media});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Center(child: Text('Confirm Deletion')),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "If you continue, this file will be deleted, and you won't be able to access it later",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white60, fontSize: 16),
          ),
        ],
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SizedBox(
              width: 100,
              child: TextButton(
                style: ButtonStyle(
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                      side: const BorderSide(color: AppColors.borderSecondary),
                    ),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ),
            ),
            SizedBox(
              width: 100,
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

Future<bool?> showDeleteMediaDialog(BuildContext context, Media media) {
  return showDialog(
    context: context,
    builder: (context) => DeleteMediaDialog(media: media),
  );
}
