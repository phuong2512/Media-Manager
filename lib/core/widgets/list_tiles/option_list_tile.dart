import 'package:flutter/material.dart';
import 'package:media_manager/core/utils/app_colors.dart';

class OptionListTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const OptionListTile({
    required this.title,
    required this.icon,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      textColor: AppColors.textPrimary,
      iconColor: AppColors.textPrimary,
      title: Text(title),
      leading: Icon(icon),
      onTap: onTap,
    );
  }
}
