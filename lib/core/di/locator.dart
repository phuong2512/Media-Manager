import 'package:get_it/get_it.dart';
import 'package:media_manager/features/home/data/datasources/home_data_source.dart';
import 'package:media_manager/features/home/data/repositories/home_repository_impl.dart';
import 'package:media_manager/features/home/domain/repositories/home_repository.dart';
import 'package:media_manager/features/home/domain/usecases/clear_home_media.dart';
import 'package:media_manager/features/home/domain/usecases/load_home_media.dart';
import 'package:media_manager/features/home/domain/usecases/save_home_media.dart';
import 'package:media_manager/features/home/presentation/controller/home_controller.dart';
import 'package:media_manager/features/home/presentation/widgets/media_player/media_player_controller.dart';
import 'package:media_manager/features/media/data/datasources/duration_data_source.dart';
import 'package:media_manager/features/media/data/datasources/media_data_source.dart';
import 'package:media_manager/features/media/data/datasources/media_scanner_data_source.dart';
import 'package:media_manager/features/media/data/repositories/media_repository_impl.dart';
import 'package:media_manager/features/media/domain/repositories/media_repository.dart';
import 'package:media_manager/features/media/domain/usecases/check_permissions.dart';
import 'package:media_manager/features/media/domain/usecases/delete_media.dart';
import 'package:media_manager/features/media/domain/usecases/rename_media.dart';
import 'package:media_manager/features/media/domain/usecases/scan_device.dart';
import 'package:media_manager/features/media/domain/usecases/share_media.dart';
import 'package:media_manager/features/media/presentation/controller/media_list_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

final getIt = GetIt.instance;

Future<void> setupLocator() async {
  final prefs = SharedPreferencesAsync();
  getIt.registerLazySingleton(() => prefs);

  /// Home
  // DataSources
  getIt.registerLazySingleton(
    () => HomeDataSource(getIt<SharedPreferencesAsync>()),
  );
  // Repositories
  getIt.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(dataSource: getIt<HomeDataSource>()),
  );

  // Usecases
  getIt.registerLazySingleton(() => LoadHomeMedia(getIt<HomeRepository>()));
  getIt.registerLazySingleton(() => SaveHomeMedia(getIt<HomeRepository>()));
  getIt.registerLazySingleton(() => ClearHomeMedia(getIt<HomeRepository>()));

  // Controllers
  getIt.registerFactory(
    () => HomeController(
      loadHomeMedia: getIt<LoadHomeMedia>(),
      saveHomeMedia: getIt<SaveHomeMedia>(),
      clearHomeMedia: getIt<ClearHomeMedia>(),
      deleteMedia: getIt<DeleteMedia>(),
      renameMedia: getIt<RenameMedia>(),
      shareMedia: getIt<ShareMedia>(),
      mediaRepository: getIt<MediaRepository>(),
    ),
  );
  getIt.registerFactory(() => MediaPlayerController());

  /// Media
  // DataSources
  getIt.registerLazySingleton(() => DurationDataSource());
  getIt.registerLazySingleton(
    () => MediaScannerDataSource(getIt<DurationDataSource>()),
  );
  getIt.registerLazySingleton(
    () => MediaDataSource(scanner: getIt<MediaScannerDataSource>()),
  );

  // Repositories
  getIt.registerLazySingleton<MediaRepository>(
    () => MediaRepositoryImpl(dataSource: getIt<MediaDataSource>()),
  );

  // Usecases
  getIt.registerLazySingleton(() => ScanDevice(getIt<MediaRepository>()));
  getIt.registerLazySingleton(() => DeleteMedia(getIt<MediaRepository>()));
  getIt.registerLazySingleton(() => RenameMedia(getIt<MediaRepository>()));
  getIt.registerLazySingleton(() => ShareMedia(getIt<MediaRepository>()));
  getIt.registerLazySingleton(() => CheckPermissions(getIt<MediaRepository>()));

  // Controllers
  getIt.registerFactory(
    () => MediaListController(
      scanDevice: getIt<ScanDevice>(),
      deleteMedia: getIt<DeleteMedia>(),
      renameMedia: getIt<RenameMedia>(),
      shareMedia: getIt<ShareMedia>(),
      repository: getIt<MediaRepository>(),
    ),
  );
}
