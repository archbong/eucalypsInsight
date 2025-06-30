import 'package:eucalysp_insight_app/features/auth/bloc/auth_cubit.dart';
import 'package:eucalysp_insight_app/features/business/bloc/business_cubit.dart';
import 'package:eucalysp_insight_app/features/business/data/repositories/business_repository.dart';
import 'package:eucalysp_insight_app/features/dashboard/bloc/dashboard_cubit.dart';
import 'package:eucalysp_insight_app/features/dashboard/data/repositories/dashboard_repository.dart';
import 'package:eucalysp_insight_app/features/dashboard/data/repositories/mock_dashboard_repository.dart';
import 'package:eucalysp_insight_app/features/inventory/bloc/inventory_cubit.dart';
import 'package:eucalysp_insight_app/features/inventory/data/repositories/inventory_repository.dart';
import 'package:eucalysp_insight_app/features/sales/bloc/sales_cubit.dart';
import 'package:eucalysp_insight_app/features/sales/data/repositories/sales_repository.dart';
import 'package:get_it/get_it.dart';

final GetIt sl = GetIt.instance;

Future<void> setupLocator() async {
  // --- Register Repositories ---
  sl.registerLazySingleton<DashboardRepository>(
    () => MockDashboardRepository(),
  );
  sl.registerLazySingleton<BusinessRepository>(() => MockBusinessRepository());
  // NEW: Register InventoryRepository implementation
  sl.registerLazySingleton<InventoryRepository>(
    () => MockInventoryRepository(),
  );
  // Register SalesRepository implementation (from upcoming Sales module)
  sl.registerLazySingleton<SalesRepository>(() => MockSalesRepository());

  // --- Register Blocs/Cubits (as factories) ---
  sl.registerFactory(() => AuthCubit());
  sl.registerFactory(() => BusinessCubit(businessRepository: sl()));
  sl.registerFactory(
    () => DashboardCubit(dashboardRepository: sl(), businessCubit: sl()),
  );
  // Register InventoryCubit, which now correctly gets its dependency
  sl.registerFactory(
    () => InventoryCubit(
      inventoryRepository: sl(), // This will now find InventoryRepository
      businessCubit: sl(),
    ),
  );
  // Register SalesCubit (from upcoming Sales module)
  sl.registerFactory(
    () => SalesCubit(salesRepository: sl(), businessCubit: sl()),
  );
}
