import 'package:get_it/get_it.dart';
import 'package:media_manager/controllers/media_controller.dart';
import 'package:media_manager/services/duration_service.dart';
import 'package:media_manager/services/media_scanner_service.dart';
import 'package:media_manager/services/media_service.dart';

final getIt = GetIt.instance;

void setupLocator() {
  getIt.registerLazySingleton(() => DurationService());
  getIt.registerLazySingleton(
    () => MediaScannerService(getIt<DurationService>()),
  );
  getIt.registerLazySingleton(
    () => MediaService(scanner: getIt<MediaScannerService>()),
  );
  getIt.registerLazySingleton(
    () => MediaController(service: getIt<MediaService>()),
  );
}
