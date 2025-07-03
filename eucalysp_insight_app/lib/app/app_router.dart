import 'package:eucalysp_insight_app/app/core/bloc/business_data_bloc.dart';
import 'package:eucalysp_insight_app/app/core/bloc/navigation_cubit/navigation_cubit.dart';
import 'package:eucalysp_insight_app/features/business/bloc/business_cubit.dart';
import 'package:eucalysp_insight_app/features/business/bloc/business_state.dart';
import 'package:eucalysp_insight_app/features/business/presentation/screens/business_selection_screen.dart';
import 'package:eucalysp_insight_app/features/inventory/bloc/inventory_cubit.dart';
import 'package:eucalysp_insight_app/features/inventory/presentation/screens/inventory_management_screen.dart';
import 'package:eucalysp_insight_app/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:eucalysp_insight_app/features/sales/bloc/sales_cubit.dart';
import 'package:eucalysp_insight_app/features/sales/domain/entities/sale.dart';
import 'package:eucalysp_insight_app/features/sales/presentation/screens/sales_management_screen.dart';
import 'package:eucalysp_insight_app/features/sales/presentation/screens/sales_analytics_screen.dart';
import 'package:eucalysp_insight_app/features/splash/presentation/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:eucalysp_insight_app/app/main_app_shell.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eucalysp_insight_app/app/core/service_locator.dart';
import 'package:eucalysp_insight_app/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:eucalysp_insight_app/features/dashboard/bloc/dashboard_cubit.dart';
import 'package:eucalysp_insight_app/features/auth/presentation/screens/login_screen.dart';
import 'package:eucalysp_insight_app/features/auth/presentation/screens/signup_screen.dart';
import 'package:eucalysp_insight_app/features/auth/bloc/auth_cubit.dart';
import 'package:eucalysp_insight_app/features/auth/bloc/auth_state.dart';
import 'dart:async';
import 'package:async/async.dart';
import 'package:hive/hive.dart';

// Key for storing onboarding status in Hive
const String _onboardingBoxName = 'appSettings';
const String _onboardingKey = 'hasSeenOnboarding';

GoRouter buildAppRouter({
  required AuthCubit authCubit,
  required BusinessCubit businessCubit,
}) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) =>
            const SplashScreen(), // This is your SplashScreen
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
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
                  businessCubit: context.read<BusinessCubit>(),
                  inventoryCubit: context.read<InventoryCubit>(),
                  salesCubit: context.read<SalesCubit>(),
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
                  businessCubit: context.read<BusinessCubit>(),
                ),
                child: const InventoryManagementScreen(),
              ),
            ),
          ),
          GoRoute(
            path: '/sales',
            pageBuilder: (context, state) => NoTransitionPage(
              child: BlocProvider<BusinessDataBloc<List<Sale>>>(
                create: (context) => SalesCubit(
                  salesRepository: sl(),
                  businessCubit: context.read<BusinessCubit>(),
                ),
                child: const SalesManagementScreen(),
              ),
            ),
          ),
          GoRoute(
            path: '/sales/analytics',
            pageBuilder: (context, state) =>
                NoTransitionPage(child: const SalesAnalyticsScreen()),
          ),
        ],
      ),
    ],
    debugLogDiagnostics: true,
    redirect: (BuildContext context, GoRouterState state) async {
      final authState = authCubit.state;
      final businessState = businessCubit.state;

      final bool isAuthenticated = authState is Authenticated;
      final bool hasSelectedBusiness =
          businessState is BusinessLoaded &&
          businessState.selectedBusiness != null;

      final bool hasBusiness = businessCubit.state is BusinessLoaded;

      final bool onOnboarding = state.fullPath == '/onboarding';
      final bool isLoggingIn = state.uri.path == '/login';
      final bool onSplash = state.fullPath == '/';
      final bool isSelectingBusiness = state.uri.path == '/select-business';

      // Check onboarding status from Hive
      final settingsBox = await Hive.openBox(_onboardingBoxName);
      final bool hasSeenOnboarding = settingsBox.get(_onboardingKey) ?? false;

      // Handle Splash screen initial load
      if (onSplash) {
        return null; // Let the splash screen handle its own navigation after its delay
      }

      // If user hasn't seen onboarding and is not already on it
      if (!hasSeenOnboarding && !onOnboarding) {
        return '/onboarding';
      }

      // Skip authentication checks if on onboarding
      if (onOnboarding) {
        return null;
      }

      // If onboarding is completed and user is not logged in, redirect to login
      if (hasSeenOnboarding && !isAuthenticated && !isLoggingIn) {
        return '/login';
      }

      // If logged in but no business selected/created
      if (isAuthenticated &&
          !hasBusiness &&
          !state.fullPath!.startsWith('/business')) {
        return '/select-business';
      }

      // If logged in and has business, but trying to access login/onboarding
      if (isAuthenticated && hasBusiness && (isLoggingIn || onOnboarding)) {
        return '/dashboard';
      }

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
      StreamGroup.merge([authCubit.stream, businessCubit.stream]),
    ),
  );
}

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
