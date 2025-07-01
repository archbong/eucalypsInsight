// lib/main.dart - THIS IS THE CORRECT VERSION
import 'package:flutter/foundation.dart'; // Added for debugPrint
import 'package:eucalysp_insight_app/features/inventory/bloc/inventory_cubit.dart';
import 'package:eucalysp_insight_app/features/inventory/data/repositories/inventory_repository.dart';
import 'package:eucalysp_insight_app/features/inventory/domain/entities/product.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Required for MultiBlocProvider and BlocProvider
import 'package:eucalysp_insight_app/app/core/service_locator.dart'; // For GetIt
import 'package:eucalysp_insight_app/app/app_router.dart'; // Your GoRouter configuration
import 'package:eucalysp_insight_app/features/auth/bloc/auth_cubit.dart'; // AuthCubit
import 'package:eucalysp_insight_app/features/business/bloc/business_cubit.dart';
import 'package:hive_flutter/adapters.dart'; // BusinessCubit

// ADD THIS IMPORT STATEMENT FOR THE GENERATED ADAPTER

void main() async {
  debugPrint('[MAIN] Starting app initialization');
  // Ensure Flutter widgets are initialized before any Flutter-specific calls
  WidgetsFlutterBinding.ensureInitialized();

  debugPrint('[MAIN] Initializing Hive...');
  try {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(0)) {
      debugPrint('[MAIN] Registering ProductAdapter');
      Hive.registerAdapter(ProductAdapter());
    }
    debugPrint('[MAIN] Hive initialized successfully');
  } catch (e) {
    debugPrint('[ERROR] Hive initialization failed: $e');
    rethrow;
  }

  debugPrint('[MAIN] Setting up service locator...');
  try {
    await setupLocator();
    debugPrint('[MAIN] Service locator setup complete');
  } catch (e) {
    debugPrint('[ERROR] Service locator setup failed: $e');
    rethrow;
  }

  debugPrint('[MAIN] Initializing Bloc providers...');
  // Run the application, wrapped with MultiBlocProvider
  // to make AuthCubit and BusinessCubit available throughout the widget tree.
  runApp(
    MultiBlocProvider(
      providers: [
        // Provide AuthCubit: it's fetched from GetIt and its initial auth status is checked.
        BlocProvider(create: (context) => sl<AuthCubit>()..checkAuthStatus()),
        // Provide BusinessCubit: it's fetched from GetIt.
        BlocProvider(create: (context) => sl<BusinessCubit>()),
        BlocProvider(create: (context) => sl<InventoryCubit>()),
      ],
      // Use a Builder widget. This is crucial!
      // It provides a new BuildContext that is a descendant of MultiBlocProvider.
      // This ensures that MaterialApp.router (and thus appRouter's redirect logic)
      // has access to the Blocs provided above.
      child: Builder(
        builder: (context) {
          final authCubit = context.read<AuthCubit>();
          final businessCubit = context.read<BusinessCubit>();
          debugPrint('[MAIN] Building MaterialApp.router...');
          return MaterialApp.router(
            title: 'EncalyspInsight', // Application title
            debugShowCheckedModeBanner:
                false, // Set to true for debugging banner
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
              useMaterial3: true,
            ),
            routerConfig: buildAppRouter(
              authCubit: authCubit,
              businessCubit: businessCubit,
            ),
          );
        },
      ),
    ),
  );
}

// IMPORTANT: The 'MainAppShell' class definition MUST NOT be in this 'main.dart' file.
// It should be in 'lib/app/main_app_shell.dart'.
// If it's currently in your main.dart, please delete it from here.
// You do not need to paste it into this response, just ensure it's in its correct file.
