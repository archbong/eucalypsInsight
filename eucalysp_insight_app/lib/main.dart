// lib/main.dart - THIS IS THE CORRECT VERSION
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Required for MultiBlocProvider and BlocProvider
import 'package:eucalysp_insight_app/app/core/service_locator.dart'; // For GetIt
import 'package:eucalysp_insight_app/app/app_router.dart'; // Your GoRouter configuration
import 'package:eucalysp_insight_app/features/auth/bloc/auth_cubit.dart'; // AuthCubit
import 'package:eucalysp_insight_app/features/business/bloc/business_cubit.dart'; // BusinessCubit

void main() async {
  // Ensure Flutter widgets are initialized before any Flutter-specific calls
  WidgetsFlutterBinding.ensureInitialized();

  // Set up GetIt service locator for dependency injection
  await setupLocator();

  // Run the application, wrapped with MultiBlocProvider
  // to make AuthCubit and BusinessCubit available throughout the widget tree.
  runApp(
    MultiBlocProvider(
      providers: [
        // Provide AuthCubit: it's fetched from GetIt and its initial auth status is checked.
        BlocProvider(create: (context) => sl<AuthCubit>()..checkAuthStatus()),
        // Provide BusinessCubit: it's fetched from GetIt.
        BlocProvider(create: (context) => sl<BusinessCubit>()),
      ],
      // Use a Builder widget. This is crucial!
      // It provides a new BuildContext that is a descendant of MultiBlocProvider.
      // This ensures that MaterialApp.router (and thus appRouter's redirect logic)
      // has access to the Blocs provided above.
      child: Builder(
        builder: (context) {
          return MaterialApp.router(
            title: 'EncalyspInsight', // Application title
            debugShowCheckedModeBanner:
                false, // Set to true for debugging banner
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
              useMaterial3: true,
            ),
            routerConfig: appRouter, // Your GoRouter configuration
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
