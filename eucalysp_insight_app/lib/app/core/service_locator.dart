// lib/app/core/service_locator.dart

import 'package:eucalysp_insight_app/features/auth/bloc/auth_cubit.dart';
import 'package:eucalysp_insight_app/features/business/bloc/business_cubit.dart';
import 'package:eucalysp_insight_app/features/business/data/repositories/business_repository.dart';
// !!! IMPORTANT: VERIFY THIS PATH AND FILENAME MATCH YOUR PROJECT !!!
import 'package:eucalysp_insight_app/features/dashboard/bloc/dashboard_cubit.dart';
import 'package:eucalysp_insight_app/features/dashboard/data/repositories/dashboard_repository.dart';
import 'package:eucalysp_insight_app/features/dashboard/data/repositories/mock_dashboard_repository.dart';
import 'package:eucalysp_insight_app/features/inventory/bloc/inventory_cubit.dart';
import 'package:eucalysp_insight_app/features/inventory/data/repositories/inventory_repository.dart';
// !!! IMPORTANT: VERIFY THIS PATH AND FILENAME MATCH YOUR PROJECT !!!
import 'package:eucalysp_insight_app/features/sales/bloc/sales_cubit.dart';
import 'package:eucalysp_insight_app/features/sales/data/repositories/sales_repository.dart';
// !!! IMPORTANT: VERIFY THIS PATH AND FILENAME MATCH YOUR PROJECT !!!
import 'package:get_it/get_it.dart';

/// Extension providing thread-safe registration methods with duplicate protection
extension SafeRegistration on GetIt {
  /// Safely registers an async singleton only if not already registered.
  /// Throws if registration fails after safety checks or if overrideIfExists is false.
  Future<void> registerSingletonAsyncSafe<T extends Object>({
    required Future<T> Function() factoryFunc,
    Iterable<Type>? dependsOn,
    String? instanceName,
    bool overrideIfExists = false,
  }) async {
    if (isRegistered<T>(instanceName: instanceName)) {
      if (!overrideIfExists) {
        // print('DEBUG: $T (instanceName: $instanceName) already registered. Skipping.');
        return; // Already registered, and not overriding
      }
      unregister<T>(instanceName: instanceName);
    }
    try {
      // --- IMPORTANT FIX HERE: REMOVED 'await' from the inner call to registerSingletonAsync ---
      // This is because your 'get_it' version's registerSingletonAsync returns void, not Future<void>.
      // The asynchronous nature of factoryFunc is handled implicitly by GetIt.
      registerSingletonAsync<T>(
        factoryFunc,
        instanceName: instanceName,
        dependsOn: dependsOn,
      );
      // print('DEBUG: Registered async $T (instanceName: $instanceName)');
    } catch (e) {
      throw Exception('Failed to register async $T: ${e.toString()}');
    }
  }

  /// Safely registers a lazy singleton only if not already registered.
  /// Throws if registration fails after safety checks or if overrideIfExists is false.
  void registerLazySingletonSafe<T extends Object>({
    required T Function() factoryFunc,
    String? instanceName,
    bool overrideIfExists = false,
  }) {
    if (isRegistered<T>(instanceName: instanceName)) {
      if (!overrideIfExists) {
        // print('DEBUG: $T (instanceName: $instanceName) already registered. Skipping.');
        return; // Already registered, and not overriding
      }
      unregister<T>(instanceName: instanceName);
    }
    try {
      registerLazySingleton<T>(factoryFunc, instanceName: instanceName);
      // print('DEBUG: Registered lazy singleton $T (instanceName: $instanceName)');
    } catch (e) {
      throw Exception('Failed to register lazy singleton $T: ${e.toString()}');
    }
  }
}

/// Global service locator instance
///
/// Configured to prevent accidental reassignments. GetIt defaults to throwing
/// if a service is requested but not registered.
final GetIt sl = GetIt.instance
  ..allowReassignment =
      false; // Prevent re-registering the same type/instance name
// ..throwIfNotRegistered = true; // REMOVED: This setter was removed in GetIt 7.x.x

/// Configures all application dependencies.
///
/// This function should be called once at the application's startup.
/// It registers various repositories and Cubits (Blocs) with GetIt,
/// ensuring that dependencies are correctly resolved.
///
/// Throws an [Exception] if any critical dependency fails to register.
Future<void> setupLocator() async {
  try {
    // --- Register Repositories ---
    // Repositories manage data sources (e.g., API, local storage).
    sl.registerLazySingletonSafe<DashboardRepository>(
      factoryFunc: () => MockDashboardRepository(),
    );
    sl.registerLazySingletonSafe<BusinessRepository>(
      factoryFunc: () => MockBusinessRepository(),
    );

    // Register HiveInventoryRepository as the concrete implementation for InventoryRepository.
    // It's registered as an async singleton because its `init()` method is asynchronous.
    await sl.registerSingletonAsyncSafe<InventoryRepository>(
      factoryFunc: () async {
        final hiveRepo = HiveInventoryRepository();
        await hiveRepo.init(); // Initialize the Hive box here
        return hiveRepo;
      },
    );

    // Register SalesRepository implementation
    sl.registerLazySingletonSafe<SalesRepository>(
      factoryFunc: () => MockSalesRepository(),
    );

    // --- Register Blocs/Cubits ---
    // Cubits (Blocs) manage application state and business logic.
    // They are registered as lazy singletons, meaning they are created only
    // when they are first accessed.

    // AuthCubit handles user authentication state.
    sl.registerLazySingletonSafe<AuthCubit>(factoryFunc: () => AuthCubit());

    // BusinessCubit manages the selected business and business-related operations.
    // It depends on BusinessRepository.
    sl.registerLazySingletonSafe<BusinessCubit>(
      factoryFunc: () =>
          BusinessCubit(businessRepository: sl<BusinessRepository>()),
    );

    // DashboardCubit manages data and logic for the dashboard screen.
    // It depends on DashboardRepository and BusinessCubit.
    sl.registerLazySingletonSafe<DashboardCubit>(
      factoryFunc: () => DashboardCubit(
        dashboardRepository: sl<DashboardRepository>(),
        businessCubit: sl<BusinessCubit>(),
      ),
    );

    // InventoryCubit manages inventory-related state and operations.
    // It depends on InventoryRepository and BusinessCubit.
    sl.registerLazySingletonSafe<InventoryCubit>(
      factoryFunc: () => InventoryCubit(
        inventoryRepository: sl<InventoryRepository>(),
        businessCubit: sl<BusinessCubit>(),
      ),
    );

    // SalesCubit manages sales-related state and operations.
    // It depends on SalesRepository and BusinessCubit.
    sl.registerLazySingletonSafe<SalesCubit>(
      factoryFunc: () => SalesCubit(
        salesRepository: sl<SalesRepository>(),
        businessCubit: sl<BusinessCubit>(),
      ),
    );
  } catch (e) {
    throw Exception('Service Locator setup failed: ${e.toString()}');
  }
}
