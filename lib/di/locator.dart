import 'package:get_it/get_it.dart';
import 'package:media_manager/views/home/providers/home_controller.dart';
import 'package:media_manager/views/media_list/providers/media_list_controller.dart';
import 'package:media_manager/widgets/dialogs/media_player_dialog/media_player_controller.dart';
import 'package:media_manager/interfaces/home_media_storage_interface.dart';
import 'package:media_manager/interfaces/media_interface.dart';
import 'package:media_manager/interfaces/media_scanner_interface.dart';
import 'package:media_manager/repositories/home_repository.dart';
import 'package:media_manager/repositories/media_repository.dart';
import 'package:media_manager/services/duration_service.dart';
import 'package:media_manager/services/media_scanner_service.dart';
import 'package:media_manager/services/media_service.dart';
import 'package:media_manager/services/home_media_storage_service.dart';

final getIt = GetIt.instance;

void setupLocator() {
  // service
  getIt.registerLazySingleton(() => DurationService());
  getIt.registerLazySingleton<HomeMediaStorageInterface>(() => HomeMediaStorageService());
  getIt.registerLazySingleton<MediaScannerInterface>(() => MediaScannerService(getIt<DurationService>()));
  getIt.registerLazySingleton<MediaInterface>(() => MediaService(scanner: getIt<MediaScannerInterface>()));

  // repo
  getIt.registerLazySingleton(() => MediaRepository(mediaService: getIt<MediaInterface>()));
  getIt.registerLazySingleton(() =>HomeRepository(homeStorageService: getIt<HomeMediaStorageInterface>()));

  // controller
  getIt.registerFactory(() => MediaPlayerController());
  getIt.registerFactory(() => HomeController(repository: getIt<MediaRepository>(),homeRepository: getIt<HomeRepository>()));
  getIt.registerFactory(() => MediaListController(repository: getIt<MediaRepository>()));
}
