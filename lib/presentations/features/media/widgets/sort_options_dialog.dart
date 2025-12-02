import 'package:flutter/material.dart';
import 'package:media_manager/presentations/features/media/media_list_controller.dart';

class SortOptionsDialog extends StatelessWidget {
  final SortOrder currentSortOrder;
  final Function(SortOrder) onSortSelected;

  const SortOptionsDialog({
    super.key,
    required this.currentSortOrder,
    required this.onSortSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.symmetric(vertical: 10),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Sắp xếp theo thời gian',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildOption(context, 'Từ mới đến cũ', SortOrder.newestFirst),
          _buildOption(context, 'Từ cũ đến mới', SortOrder.oldestFirst),
        ],
      ),
    );
  }

  Widget _buildOption(BuildContext context, String title, SortOrder order) {
    return ListTile(
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Row(
          children: [
            Text(title, style: const TextStyle(fontSize: 19)),
            const SizedBox(width: 10),
            if (currentSortOrder == order)
              const Icon(Icons.check, color: Colors.cyan, size: 45),
          ],
        ),
      ),
      onTap: () {
        onSortSelected(order);
        Navigator.pop(context);
      },
    );
  }
}
