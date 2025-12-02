import 'package:flutter/material.dart';
import 'package:media_manager/core/utils/app_colors.dart';

class MediaSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const MediaSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 35),
      child: TextField(
        style: const TextStyle(color: AppColors.textSecondary),
        cursorColor: AppColors.textSecondary,
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Search in your library...',
          hintStyle: const TextStyle(color: AppColors.textSecondary),
          prefixIcon: const Icon(
            Icons.search,
            size: 30,
            color: AppColors.textSecondary,
          ),
          suffixIcon: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.mic, color: AppColors.textSecondary),
          ),
          contentPadding: EdgeInsets.zero,
          filled: true,
          fillColor: AppColors.fill,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
