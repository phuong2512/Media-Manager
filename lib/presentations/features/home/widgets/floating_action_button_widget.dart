import 'package:flutter/material.dart';
import 'package:media_manager/presentations/features/home/home_controller.dart';

class FloatingActionButtonWidget extends StatelessWidget {
  final HomeController controller;
  final VoidCallback onPress;

  const FloatingActionButtonWidget({
    super.key,
    required this.controller,
    required this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Colors.blue, Colors.purple],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(77),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: IconButton(
        icon: const Icon(Icons.add, size: 35, color: Colors.white),
        onPressed: onPress,
      ),
    );
  }
}
