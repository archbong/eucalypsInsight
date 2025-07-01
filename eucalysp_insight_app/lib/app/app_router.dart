// lib/app/app_router.dart

import 'package:eucalysp_insight_app/app/core/bloc/business_data_bloc.dart';
import 'package:eucalysp_insight_app/app/core/bloc/navigation_cubit/navigation_cubit.dart';
import 'package:eucalysp_insight_app/features/business/bloc/business_cubit.dart';
import 'package:eucalysp_insight_app/features/business/bloc/business_state.dart';
import 'package:eucalysp_insight_app/features/business/presentation/screens/business_selection_screen.dart';
import 'package:eucalysp_insight_app/features/inventory/bloc/inventory_cubit.dart';
import 'package:eucalysp_insight_app/features/inventory/presentation/screens/inventory_list_screen.dart';
import 'package:eucalysp_insight_app/features/sales/bloc/sales_cubit.dart';
import 'package:eucalysp_insight_app/features/sales/domain/entities/sale.dart';
import 'package:eucalysp_insight_app/features/sales/presentation/screens/sales_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:eucalysp_insight_app/app/main_app_shell.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eucalysp_insight_app/app/core/service_locator.dart';
import 'package:eucalysp_insight_app/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:eucalysp_insight_app/features/dashboard/bloc/dashboard_cubit.dart';
import 'package:eucalysp_insight_app/features/auth/presentation/screens/login_screen.dart';
import 'package:eucalysp_insight_app/features/auth/bloc/auth_cubit.dart';
import 'package:eucalysp_insight_app/features/auth/bloc/auth_state.dart';
import 'dart:async';
import 'package:async/async.dart';

// Placeholder screens for Inventory and Sales for now
class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Inventory Screen Content'));
  }
}

class SalesScreen extends StatelessWidget {
  const SalesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Sales Screen Content'));
  }
}

// MAKE appRouter A FUNCTION THAT TAKES CUBITS
GoRouter buildAppRouter({
  required AuthCubit authCubit,
  required BusinessCubit businessCubit,
}) {
  return GoRouter(
    initialLocation: '/dashboard',
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/select-business',
        builder: (context, state) => const BusinessSelectionScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return BlocProvider(
            create: (context) => NavigationCubit(),
            child: MainAppShell(child: child),
          );
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            pageBuilder: (context, state) => NoTransitionPage(
              child: BlocProvider(
                create: (context) => DashboardCubit(
                  dashboardRepository: sl(),
                  // Now safe to read BusinessCubit as it's provided higher up
                  businessCubit: context.read<BusinessCubit>(),
                ),
                child: const DashboardScreen(),
              ),
            ),
          ),
          GoRoute(
            path: '/inventory',
            pageBuilder: (context, state) => NoTransitionPage(
              child: BlocProvider(
                create: (context) => InventoryCubit(
                  inventoryRepository: sl(),
                  // Now safe to read BusinessCubit as it's provided higher up
                  businessCubit: context.read<BusinessCubit>(),
                ),
                child: const InventoryListScreen(),
              ),
            ),
          ),
          GoRoute(
            path: '/sales',
            pageBuilder: (context, state) => NoTransitionPage(
              child: BlocProvider<BusinessDataBloc<List<Sale>>>(
                create: (context) => SalesCubit(
                  salesRepository: sl(),
                  // Now safe to read BusinessCubit as it's provided higher up
                  businessCubit: context.read<BusinessCubit>(),
                ),
                child: const SalesListScreen(),
              ),
            ),
          ),
        ],
      ),
    ],
    debugLogDiagnostics: true,
    // USE THE PASSED CUBITS HERE
    redirect: (BuildContext context, GoRouterState state) {
      final authState = authCubit.state; // Use the passed cubit
      final businessState = businessCubit.state; // Use the passed cubit

      final bool isAuthenticated = authState is Authenticated;
      final bool hasSelectedBusiness =
          businessState is BusinessLoaded &&
          businessState.selectedBusiness != null;
      final bool isLoggingIn = state.uri.path == '/login';
      final bool isSelectingBusiness = state.uri.path == '/select-business';

      if (!isAuthenticated && !isLoggingIn) {
        return '/login';
      }
      if (isAuthenticated && !hasSelectedBusiness && !isSelectingBusiness) {
        return '/select-business';
      }
      if (isAuthenticated &&
          hasSelectedBusiness &&
          (isLoggingIn || isSelectingBusiness)) {
        return '/dashboard';
      }
      return null;
    },
    // Pass the streams from the provided cubits
    refreshListenable: GoRouterRefreshStream(
      StreamGroup.merge([
        authCubit.stream,
        businessCubit.stream,
      ]), // Use the passed cubits
    ),
  );
}

// Helper to merge streams for refreshListenable
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
