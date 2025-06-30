// lib/app/app_router.dart
import 'package:eucalysp_insight_app/app/core/bloc/navigation_cubit/navigation_cubit.dart';
import 'package:eucalysp_insight_app/features/business/bloc/business_cubit.dart';
import 'package:eucalysp_insight_app/features/business/bloc/business_state.dart';
import 'package:eucalysp_insight_app/features/business/presentation/screens/business_selection_screen.dart';
import 'package:eucalysp_insight_app/features/inventory/bloc/inventory_cubit.dart';
import 'package:eucalysp_insight_app/features/inventory/presentation/screens/inventory_list_screen.dart';
import 'package:eucalysp_insight_app/features/sales/bloc/sales_cubit.dart';
import 'package:eucalysp_insight_app/features/sales/presentation/sales_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:eucalysp_insight_app/app/main_app_shell.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Import BlocProvider
import 'package:eucalysp_insight_app/app/core/service_locator.dart';
import 'package:eucalysp_insight_app/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:eucalysp_insight_app/features/dashboard/bloc/dashboard_cubit.dart';
import 'package:eucalysp_insight_app/features/auth/presentation/screens/login_screen.dart'; // Import LoginScreen
import 'package:eucalysp_insight_app/features/auth/bloc/auth_cubit.dart'; // Import AuthCubit
import 'package:eucalysp_insight_app/features/auth/bloc/auth_state.dart'; // Import AuthState
import 'dart:async'; // Required for StreamSubscription
import 'package:async/async.dart'; // Add this import at the top of app_router.dart if missing

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

final GoRouter appRouter = GoRouter(
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
              create: (context) => sl<DashboardCubit>(),
              child: const DashboardScreen(),
            ),
          ),
        ),
        GoRoute(
          path: '/inventory',
          pageBuilder: (context, state) => NoTransitionPage(
            // Changed from const NoTransitionPage
            child: BlocProvider(
              // NEW: Provide InventoryCubit here
              create: (context) => sl<InventoryCubit>(),
              child: const InventoryListScreen(),
            ),
          ),
        ),
        GoRoute(
          path: '/sales',
          pageBuilder: (context, state) => NoTransitionPage(
            child: BlocProvider(
              // NEW: Provide SalesCubit here
              create: (context) => sl<SalesCubit>(),
              child: const SalesListScreen(), // Use the new SalesListScreen
            ),
          ),
        ),
      ],
    ),
  ],
  redirect: (BuildContext context, GoRouterState state) {
    final authState = context.read<AuthCubit>().state;
    final businessState = context.read<BusinessCubit>().state;

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
  refreshListenable: GoRouterRefreshStream(
    StreamGroup.merge([sl<AuthCubit>().stream, sl<BusinessCubit>().stream]),
  ),
);

// Helper to merge streams for refreshListenable

// A simple refreshListenable for GoRouter
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
