import 'package:flutter/material.dart';

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
      textColor: const Color(0XFF90C5E0),
      iconColor: const Color(0XFF90C5E0),
      title: Text(title),
      leading: Icon(icon),
      onTap: onTap,
    );
  }
}
