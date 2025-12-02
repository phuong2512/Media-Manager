import 'package:get_it/get_it.dart';
import 'package:media_manager/core/repositories/home_repository.dart';
import 'package:media_manager/core/repositories/media_repository.dart';
import 'package:media_manager/core/services/home/home_service.dart';
import 'package:media_manager/core/services/media/duration_service.dart';
import 'package:media_manager/core/services/media/media_scanner_service.dart';
import 'package:media_manager/core/services/media/media_service.dart';
import 'package:media_manager/presentations/features/home/home_controller.dart';
import 'package:media_manager/presentations/features/home/widgets/media_player/media_player_controller.dart';
import 'package:media_manager/presentations/features/media/media_list_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

final getIt = GetIt.instance;

Future<void> setupLocator() async {
  final prefs = SharedPreferencesAsync();
  getIt.registerLazySingleton(() => prefs);

  /// Home
  // Services
  getIt.registerLazySingleton<HomeService>(
    () => HomeServiceImpl(prefs: getIt<SharedPreferencesAsync>()),
  );
  // Repositories
  getIt.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(service: getIt<HomeService>()),
  );

  // Controllers
  getIt.registerFactory(
    () => HomeController(
      homeRepository: getIt<HomeRepository>(),
      mediaRepository: getIt<MediaRepository>(),
    ),
  );
  getIt.registerFactory(() => MediaPlayerController());

  /// Media
  // Services
  getIt.registerLazySingleton<DurationService>(() => DurationServiceImpl());
  getIt.registerLazySingleton<MediaScannerService>(
    () => MediaScannerServiceImpl(getIt<DurationService>()),
  );
  getIt.registerLazySingleton<MediaService>(
    () => MediaServiceImpl(scanner: getIt<MediaScannerService>()),
  );

  // Repositories
  getIt.registerLazySingleton<MediaRepository>(
    () => MediaRepositoryImpl(service: getIt<MediaService>()),
  );

  // Controllers
  getIt.registerFactory(
    () => MediaListController(repository: getIt<MediaRepository>()),
  );
}
