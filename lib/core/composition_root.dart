import 'package:flutter_blue_plus/flutter_blue_plus.dart' hide BluetoothService;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:local_auth/local_auth.dart';
import 'package:test_erna/core/bloc/auth_bloc/auth_bloc.dart';
import 'package:test_erna/core/service/bluetooth_service.dart';
import 'package:test_erna/core/service/ios_health_service.dart';
import 'package:test_erna/core/service/smartwatch_data_service.dart';
import 'package:test_erna/core/service/unified_health_service.dart';
import 'package:test_erna/data/dao/auth_dao.dart';
import 'package:test_erna/data/repositories/health_data_repository.dart';
import 'package:test_erna/data/repositories/local_auth_repository.dart';
import 'package:test_erna/presentation/blocs/main_screen_bloc/main_screen_bloc.dart';

import '../data/dao/local_auth_dao.dart';
import '../data/repositories/auth_repository.dart';
import 'router/app_router.dart';

/// Composition root for dependency injection
/// Sets up all app dependencies using get_it
class CompositionRoot {
  static final GetIt _getIt = GetIt.instance;

  /// Get the service locator instance
  static GetIt get getIt => _getIt;

  /// Initialize all dependencies
  static Future<void> init() async {
    // Register core dependencies
    await _registerCore();

    // Register data layer (DAOs)
    await _registerDaos();

    // Register repositories
    await _registerRepositories();

    // Register BLoCs/Cubits
    await _registerBlocs();

    // Register routing
    await _registerRouting();

    // Register services
    await _registerServices();
  }

  /// Register core dependencies (storage, authentication, etc.)
  static Future<void> _registerCore() async {
    // Flutter Secure Storage
    _getIt.registerLazySingleton<FlutterSecureStorage>(
      () => const FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
        iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
      ),
    );

    // Local Authentication
    _getIt.registerLazySingleton<LocalAuthentication>(
      () => LocalAuthentication(),
    );
  }

  /// Register Data Access Objects (DAOs)
  static Future<void> _registerDaos() async {
    // Local Auth DAO
    _getIt.registerLazySingleton<LocalAuthDao>(
      () => LocalAuthDao(_getIt<FlutterSecureStorage>()),
    );

    _getIt.registerLazySingleton<AuthDao>(
      () => AuthDao(_getIt<FlutterSecureStorage>()),
    );

    // Add other DAOs here as needed
    // Example:
    // _getIt.registerLazySingleton<HealthDataDao>(
    //   () => HealthDataDao(_getIt<Database>()),
    // );
  }

  /// Register repositories
  static Future<void> _registerRepositories() async {
    // Auth Repository
    _getIt.registerLazySingleton<LocalAuthRepository>(
      () => LocalAuthRepositoryImpl(
        _getIt<LocalAuthDao>(),
        _getIt<LocalAuthentication>(),
      ),
    );

    _getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(_getIt<AuthDao>()),
    );

    // Health Data Repository
    _getIt.registerLazySingleton<HealthDataRepository>(
      () => HealthDataRepositoryImpl(_getIt<UnifiedHealthService>()),
    );

    // Add other repositories here as needed
    // Example:
    // _getIt.registerLazySingleton<HealthDataRepository>(
    //   () => HealthDataRepository(
    //     _getIt<HealthDataDao>(),
    //     _getIt<ApiService>(),
    //   ),
    // );
  }

  /// Register BLoCs and Cubits
  static Future<void> _registerBlocs() async {
    // Register BLoCs as factories so each screen gets a new instance

    // Auth BLoC - singleton since auth state should be shared across the app
    _getIt.registerLazySingleton<AuthBloc>(
      () => AuthBloc(_getIt<AuthRepository>()),
    );

    // Main Screen BLoC - factory so each instance is fresh
    _getIt.registerFactory<MainScreenBloc>(
      () => MainScreenBloc(
        bluetoothService: _getIt<BluetoothService>(),
        healthDataRepository: _getIt<HealthDataRepository>(),
      ),
    );

    // Add other BLoCs/Cubits here as factories
    // Example:
    // _getIt.registerFactory<DashboardBloc>(
    //   () => DashboardBloc(
    //     _getIt<HealthDataRepository>(),
    //     _getIt<DeviceRepository>(),
    //   ),
    // );
  }

  /// Register routing
  static Future<void> _registerRouting() async {
    // App Router
    _getIt.registerLazySingleton<AppRouter>(() => AppRouter());
  }

  /// Register services (API, notification, etc.)
  static Future<void> _registerServices() async {
    // Bluetooth Service
    _getIt.registerLazySingleton<BluetoothService>(
      () => BluetoothServiceImpl(FlutterBluePlus()),
    );

    // Smartwatch Data Service (standard BLE GATT)
    _getIt.registerLazySingleton<SmartwatchDataService>(
      () => SmartwatchDataServiceImpl(_getIt<BluetoothService>()),
    );

    // iOS Health Service (for getting data from iOS HealthKit)
    _getIt.registerLazySingleton<IosHealthService>(() => IosHealthService());

    // Unified Health Service (автоматически выбирает Huawei, Sahha, iOS Health или BLE)
    _getIt.registerLazySingleton<UnifiedHealthService>(
      () => UnifiedHealthServiceImpl(
        smartwatchDataService: _getIt<SmartwatchDataService>(),
        iosHealthService: _getIt<IosHealthService>(),
        bluetoothService: _getIt<BluetoothService>(),
      ),
    );

    // Add other services here as needed
    // Example:
    // _getIt.registerLazySingleton<ApiService>(
    //   () => ApiService(_getIt<AuthRepository>()),
    // );

    // _getIt.registerLazySingleton<NotificationService>(
    //   () => NotificationService(),
    // );
  }

  /// Reset all dependencies (useful for testing)
  static Future<void> reset() async {
    await _getIt.reset();
  }

  /// Convenience method to get a dependency
  static T get<T extends Object>() {
    return _getIt.get<T>();
  }

  /// Check if a dependency is registered
  static bool isRegistered<T extends Object>() {
    return _getIt.isRegistered<T>();
  }
}

/// Extension to make accessing dependencies easier
extension GetItExtension on GetIt {
  /// Get AuthRepository
  AuthRepository get authRepository => get<AuthRepository>();

  /// Get AuthBloc
  AuthBloc get authBloc => get<AuthBloc>();

  /// Get AppRouter
  AppRouter get appRouter => get<AppRouter>();

  /// Get LocalAuthDao
  LocalAuthDao get localAuthDao => get<LocalAuthDao>();

  /// Get LocalAuthRepository
  LocalAuthRepository get localAuthRepository => get<LocalAuthRepository>();

  /// Get BluetoothService
  BluetoothService get bluetoothService => get<BluetoothService>();

  /// Get SmartwatchDataService
  SmartwatchDataService get smartwatchDataService =>
      get<SmartwatchDataService>();

  /// Get HealthDataRepository
  HealthDataRepository get healthDataRepository => get<HealthDataRepository>();

  // Add more convenience getters as needed
}
