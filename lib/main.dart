import 'package:flutter/material.dart';
import 'package:media_manager/controllers/media_controller.dart';
import 'package:media_manager/repositories/media_repository.dart';
import 'package:media_manager/repositories/media_repository_interface.dart';
import 'package:media_manager/services/duration_service.dart';
import 'package:media_manager/services/media_scanner.dart';
import 'package:media_manager/utils/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:media_manager/views/home/home_screen.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupLocator() {
  getIt.registerLazySingleton<DurationService>(() => DurationService());
  getIt.registerLazySingleton<MediaScannerService>(
    () => MediaScannerService(getIt<DurationService>()),
  );
  getIt.registerLazySingleton<MediaRepositoryInterface>(
    () => MediaRepository(getIt<MediaScannerService>()),
  );
  getIt.registerFactory(() => MediaController(repository: getIt<MediaRepositoryInterface>()));
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MediaController>(
      create: (_) => getIt<MediaController>(),
      child: MaterialApp(
        title: 'Media Manager',
        theme: ThemeData(
          dialogTheme: DialogThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: AppColors.background,
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
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
      ),
    );
  }
}
