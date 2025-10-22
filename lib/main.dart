import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_manager/utils/app_colors.dart';
import 'package:media_manager/di/locator.dart';
import 'package:media_manager/views/home/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  setupLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Media Manager',
      theme: ThemeData(
        dialogTheme: DialogThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: AppColors.background,
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
        ),
        listTileTheme: ListTileThemeData(
          subtitleTextStyle: TextStyle(color: Colors.white30),
        ),
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: AppBarTheme(
          centerTitle: true,
          backgroundColor: AppColors.background,
          titleTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}
