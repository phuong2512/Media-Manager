import 'package:get_it/get_it.dart';
import 'package:media_manager/core/repositories/home/home_repository.dart';
import 'package:media_manager/core/repositories/home/home_repository_impl.dart';
import 'package:media_manager/core/repositories/media/media_repository.dart';
import 'package:media_manager/core/repositories/media/media_repository_impl.dart';
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
  getIt.registerLazySingleton(
    () => HomeService(getIt<SharedPreferencesAsync>()),
  );
  // Repositories
  getIt.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(dataSource: getIt<HomeService>()),
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
  getIt.registerLazySingleton(() => DurationService());
  getIt.registerLazySingleton(
    () => MediaScannerService(getIt<DurationService>()),
  );
  getIt.registerLazySingleton(
    () => MediaService(scanner: getIt<MediaScannerService>()),
  );

  // Repositories
  getIt.registerLazySingleton<MediaRepository>(
    () => MediaRepositoryImpl(dataSource: getIt<MediaService>()),
  );

  // Controllers
  getIt.registerFactory(
    () => MediaListController(repository: getIt<MediaRepository>()),
  );
}
