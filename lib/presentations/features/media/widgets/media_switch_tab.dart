import 'package:flutter/material.dart';
import 'package:media_manager/core/utils/app_colors.dart';

class MediaSwitchTab extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const MediaSwitchTab({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [_buildTab("Audio", 0), _buildTab("Video", 1)],
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final bool isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () => onTabSelected(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.fill : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            color: isSelected ? AppColors.textPrimary : AppColors.textTertiary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
