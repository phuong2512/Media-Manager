import 'package:get_it/get_it.dart';
import 'package:media_manager/core/repositories/home_repository.dart';
import 'package:media_manager/core/repositories/media_repository.dart';
import 'package:media_manager/core/services/home/home_service.dart';
import 'package:media_manager/core/services/media/duration_service.dart';
import 'package:media_manager/core/services/media/media_scanner_service.dart';
import 'package:media_manager/core/services/media/media_service.dart';
import 'package:media_manager/core/use_cases/check_permissions.dart';
import 'package:media_manager/core/use_cases/clear_home_media.dart';
import 'package:media_manager/core/use_cases/delete_media.dart';
import 'package:media_manager/core/use_cases/load_home_media.dart';
import 'package:media_manager/core/use_cases/observe_media_deleted.dart';
import 'package:media_manager/core/use_cases/observe_media_renamed.dart';
import 'package:media_manager/core/use_cases/rename_media.dart';
import 'package:media_manager/core/use_cases/save_home_media.dart';
import 'package:media_manager/core/use_cases/scan_media.dart';
import 'package:media_manager/core/use_cases/share_media.dart';
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
      mediaRepository: getIt<MediaRepository>(),
      clearHomeMedia: getIt<ClearHomeMedia>(),
      loadHomeMedia: getIt<LoadHomeMedia>(),
      saveHomeMedia: getIt<SaveHomeMedia>(),
      deleteMedia: getIt<DeleteMedia>(),
      renameMedia: getIt<RenameMedia>(),
      shareMedia: getIt<ShareMedia>(),
      observeMediaDeleted: getIt<ObserveMediaDeleted>(),
      observeMediaRenamed: getIt<ObserveMediaRenamed>(),
    ),
  );
  getIt.registerFactory(() => MediaPlayerController());

  // Use cases
  getIt.registerFactory(() => LoadHomeMedia(getIt<HomeRepository>()));
  getIt.registerFactory(() => SaveHomeMedia(getIt<HomeRepository>()));
  getIt.registerFactory(() => ClearHomeMedia(getIt<HomeRepository>()));

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

  // Use cases
  getIt.registerFactory(() => CheckPermissions(getIt<MediaRepository>()));
  getIt.registerFactory(() => DeleteMedia(getIt<MediaRepository>()));
  getIt.registerFactory(() => RenameMedia(getIt<MediaRepository>()));
  getIt.registerFactory(() => ShareMedia(getIt<MediaRepository>()));
  getIt.registerFactory(() => ScanDevice(getIt<MediaRepository>()));
  getIt.registerFactory(() => ObserveMediaDeleted(getIt<MediaRepository>()));
  getIt.registerFactory(() => ObserveMediaRenamed(getIt<MediaRepository>()));
}
