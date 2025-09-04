import 'package:flutter/material.dart';
import 'package:media_download_manager/models/media.dart';

class RenameMediaDialog extends StatelessWidget {
  final Media media;

  const RenameMediaDialog({super.key, required this.media});

  @override
  Widget build(BuildContext context) {
    final mediaNameController = TextEditingController(
      text: media.path.split('/').last.split('.').first,
    );
    return AlertDialog(
      title: const Center(child: Text('Rename')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            style: const TextStyle(color: Color(0xFF90C5E0)),
            cursorColor: const Color(0xFF90C5E0),
            controller: mediaNameController,
            decoration: InputDecoration(
              suffixIcon: IconButton(
                color: Colors.white,
                onPressed: () => mediaNameController.clear(),
                icon: const Icon(Icons.close),
              ),
              hintText: 'Enter new file name',
              hintStyle: const TextStyle(color: Colors.white),
              filled: true,
              fillColor: const Color(0xFF2F3D4C),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              width: 100,
              child: TextButton(
                style: ButtonStyle(
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                      side: const BorderSide(color: Color(0xFF3C3F42)),
                    ),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
            ),
            SizedBox(
              width: 100,
              child: TextButton(
                onPressed: () {
                  final newName = mediaNameController.text.trim();
                  if (newName.isNotEmpty) {
                    Navigator.pop(context, newName);
                  }
                }
                ,
                style: TextButton.styleFrom(
                  backgroundColor: Colors.cyan,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'OK',
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

Future<String?> showRenameMediaDialog(BuildContext context, Media media) {
  return showDialog<String>(
    context: context,
    builder: (context) => RenameMediaDialog(media: media),
  );
}
