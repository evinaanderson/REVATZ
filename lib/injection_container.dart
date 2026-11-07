import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/database/app_database.dart';
import 'core/utils/id_generator.dart';
import 'core/utils/uuid_generator.dart';
import 'features/backup/data/datasources/backup_archive_service.dart';
import 'features/backup/data/datasources/backup_prefs_datasource.dart';
import 'features/backup/data/datasources/drive_datasource.dart';
import 'features/backup/data/repositories/backup_repository_impl.dart';
import 'features/backup/domain/repositories/backup_repository.dart';
import 'features/backup/domain/usecases/backup_usecases.dart';
import 'features/category/data/repositories/category_repository_impl.dart';
import 'features/category/domain/repositories/category_repository.dart';
import 'features/category/domain/usecases/add_category.dart';
import 'features/category/domain/usecases/delete_category.dart';
import 'features/category/domain/usecases/get_categories.dart';
import 'features/category/domain/usecases/update_category.dart';
import 'features/sermon/data/repositories/sermon_repository_impl.dart';
import 'features/sermon/domain/repositories/sermon_repository.dart';
import 'features/sermon/domain/usecases/add_sermon.dart';
import 'features/sermon/domain/usecases/delete_sermon.dart';
import 'features/sermon/domain/usecases/get_sermon.dart';
import 'features/sermon/domain/usecases/get_sermons.dart';
import 'features/sermon/domain/usecases/get_sermons_by_category.dart';
import 'features/sermon/domain/usecases/search_sermons.dart';
import 'features/sermon/domain/usecases/update_sermon.dart';
import 'features/user/data/datasources/google_auth_datasource.dart';
import 'features/user/data/repositories/user_repository_impl.dart';
import 'features/user/domain/repositories/user_repository.dart';
import 'features/user/domain/usecases/user_usecases.dart';

final sl = GetIt.instance;

/// À appeler dans main() : `await initDependencies();`
Future<void> initDependencies() async {
  // --- Externes
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);
  sl.registerLazySingleton<AppDatabase>(() => AppDatabase());
  sl.registerLazySingleton<IdGenerator>(() => UuidGenerator());

  // --- Data sources
  sl.registerLazySingleton(() => GoogleAuthDataSource());
  sl.registerLazySingleton(() => DriveDataSource(sl()));
  sl.registerLazySingleton(() => BackupArchiveService());
  sl.registerLazySingleton(() => BackupPrefsDataSource(sl()));

  // --- Repositories (interfaces du Domain)
  sl.registerLazySingleton<SermonRepository>(
      () => SermonRepositoryImpl(sl<AppDatabase>().sermonDao));
  sl.registerLazySingleton<CategoryRepository>(
      () => CategoryRepositoryImpl(sl<AppDatabase>().categoryDao));
  sl.registerLazySingleton<UserRepository>(() => UserRepositoryImpl(sl()));
  sl.registerLazySingleton<BackupRepository>(
      () => BackupRepositoryImpl(sl(), sl(), sl()));

  // --- Use cases : sermons
  sl.registerFactory(() => AddSermon(sl(), sl()));
  sl.registerFactory(() => UpdateSermon(sl()));
  sl.registerFactory(() => DeleteSermon(sl()));
  sl.registerFactory(() => GetSermon(sl()));
  sl.registerFactory(() => GetSermons(sl()));
  sl.registerFactory(() => WatchSermons(sl()));
  sl.registerFactory(() => GetSermonsByCategory(sl()));
  sl.registerFactory(() => SearchSermons(sl()));

  // --- Use cases : catégories
  sl.registerFactory(() => AddCategory(sl(), sl()));
  sl.registerFactory(() => UpdateCategory(sl()));
  sl.registerFactory(() => DeleteCategory(sl(), sl()));
  sl.registerFactory(() => GetCategories(sl()));
  sl.registerFactory(() => WatchCategories(sl()));

  // --- Use cases : utilisateur
  sl.registerFactory(() => SignInWithGoogle(sl()));
  sl.registerFactory(() => SignOut(sl()));
  sl.registerFactory(() => GetCurrentUser(sl()));

  // --- Use cases : sauvegarde
  sl.registerFactory(() => BackupToDrive(sl(), sl(), sl()));
  sl.registerFactory(() => RestoreFromDrive(sl(), sl(), sl()));
  sl.registerFactory(() => ExportToZip(sl(), sl(), sl()));
  sl.registerFactory(() => GetBackupInfo(sl()));
}
