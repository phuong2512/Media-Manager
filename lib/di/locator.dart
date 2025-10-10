import 'package:get_it/get_it.dart';
import 'package:media_manager/controllers/home_controller.dart';
import 'package:media_manager/controllers/media_list_controller.dart';
import 'package:media_manager/interfaces/home_media_storage_interface.dart';
import 'package:media_manager/interfaces/media_interface.dart';
import 'package:media_manager/repositories/media_repository.dart';
import 'package:media_manager/services/duration_service.dart';
import 'package:media_manager/services/media_scanner_service.dart';
import 'package:media_manager/services/media_service.dart';
import 'package:media_manager/services/home_media_storage_service.dart';

final getIt = GetIt.instance;

void setupLocator() {
  getIt.registerLazySingleton(() => DurationService());
  getIt.registerLazySingleton<HomeMediaStorageInterface>(
    () => HomeMediaStorageService(),
  );
  getIt.registerLazySingleton(
    () => MediaScannerService(getIt<DurationService>()),
  );
  getIt.registerLazySingleton<MediaInterface>(
    () => MediaService(scanner: getIt<MediaScannerService>()),
  );

  getIt.registerLazySingleton(
    () => MediaRepository(
      mediaService: getIt<MediaInterface>(),
      homeStorageService: getIt<HomeMediaStorageInterface>(),
    ),
  );

  getIt.registerFactory(
    () => HomeController(repository: getIt<MediaRepository>()),
  );
  getIt.registerFactory(
    () => MediaListController(
      repository: getIt<MediaRepository>(),
      homeController: getIt<HomeController>(),
    ),
  );
}
