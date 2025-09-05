import 'package:flutter/material.dart';
import 'package:media_manager/controllers/media_controller.dart';
import 'package:provider/provider.dart';
import 'package:media_manager/views/home/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MediaController(),
      child: MaterialApp(
        title: 'Media Manager',
        theme: ThemeData(
          dialogTheme: DialogThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: Color(0xFF19222A),
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          listTileTheme: ListTileThemeData(
            subtitleTextStyle: TextStyle(color: Colors.white30),
          ),
          scaffoldBackgroundColor: Color(0xFF19222A),
          appBarTheme: AppBarTheme(
            centerTitle: true,
            backgroundColor: Color(0xFF19222A),
            titleTextStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
        ),
        debugShowCheckedModeBanner: false,
        home: const HomeScreen(),
      ),
    );
  }
}
