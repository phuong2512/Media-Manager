import 'package:get_it/get_it.dart';
import 'package:media_manager/data/repositories/home_repository.dart';
import 'package:media_manager/data/repositories/media_repository.dart';
import 'package:media_manager/data/services/home_service.dart';
import 'package:media_manager/data/services/media_scanner_service.dart';
import 'package:media_manager/data/services/media_service.dart';
import 'package:media_manager/data/services/duration_service.dart';
import 'package:media_manager/data/repositories/home_repository_impl.dart';
import 'package:media_manager/data/repositories/media_repository_impl.dart';
import 'package:media_manager/presentation/home/home_controller.dart';
import 'package:media_manager/presentation/media_list/media_list_controller.dart';
import 'package:media_manager/presentation/home/media_player_dialog/media_player_controller.dart';

final getIt = GetIt.instance;

void setupLocator() {
  // Services
  getIt.registerLazySingleton(() => DurationService());
  getIt.registerLazySingleton(
    () => MediaScannerService(getIt<DurationService>()),
  );
  getIt.registerLazySingleton(
    () => MediaService(scanner: getIt<MediaScannerService>()),
  );
  getIt.registerLazySingleton(() => HomeService());

  // Repositories
  getIt.registerLazySingleton<MediaRepository>(
    () => MediaRepositoryImpl(service: getIt<MediaService>()),
  );

  getIt.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(service: getIt<HomeService>()),
  );

  // Controllers
  getIt.registerFactory(() => MediaPlayerController());
  getIt.registerFactory(
    () => HomeController(
      homeRepository: getIt<HomeRepository>(),
      mediaRepository: getIt<MediaRepository>(),
    ),
  );
  getIt.registerFactory(
    () => MediaListController(repository: getIt<MediaRepository>()),
  );
}
