import 'package:eucalysp_insight_app/features/auth/bloc/auth_state.dart';
import 'package:eucalysp_insight_app/features/business/bloc/business_state.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Needed for context.read or context.watch
import 'package:eucalysp_insight_app/app/app_theme.dart'; // Import your custom theme colors and gradients
import 'package:eucalysp_insight_app/features/auth/bloc/auth_cubit.dart'; // AuthCubit for checking state
import 'package:eucalysp_insight_app/features/business/bloc/business_cubit.dart'; // BusinessCubit for checking state

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // Total animation duration
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.0,
          0.7,
          curve: Curves.easeOut,
        ), // Fade in during the first 70% of animation
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.3,
          1.0,
          curve: Curves.elasticOut,
        ), // Scale up after some delay
      ),
    );

    _controller.forward(); // Start the animation

    // Start navigation after animation completes and a short delay
    _navigateToNextScreen();
  }

  _navigateToNextScreen() async {
    // Wait for the animation to complete + a little extra time for visual comfort
    await Future.delayed(
      const Duration(seconds: 2, milliseconds: 500),
    ); // 2.5 seconds total

    if (!mounted) return; // Ensure widget is still in the tree

    // This is where you check your actual app state (authentication, business selection)
    // and redirect using GoRouter.
    final authState = context.read<AuthCubit>().state;
    final businessState = context.read<BusinessCubit>().state;

    // Use GoRouter's go() for direct navigation, clearing the stack
    if (authState is Authenticated) {
      if (businessState is BusinessLoaded) {
        GoRouter.of(
          context,
        ).go('/dashboard'); // User authenticated and business selected
      } else {
        GoRouter.of(context).go(
          '/business-selection',
        ); // Authenticated but no business loaded/selected
      }
    } else {
      GoRouter.of(context).go('/login'); // Not authenticated
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient:
              primaryGradient, // Use the primary gradient defined in app_theme.dart
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scaleAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Image.asset(
                    'assets/images/logo-one.png', // <--- IMPORTANT: Replace with your actual logo path
                    height: 150, // Adjust size as needed
                    width: 150,
                    // If your logo is monochrome and needs to pick up textInverse color
                    // colorBlendMode: BlendMode.srcIn,
                    // color: AppColors.textInverse,
                  ),
                ),
              ),
              const SizedBox(
                height: 32,
              ), // More space as per your spacing scale (e.g., spacing-xl)
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'Eucalyps Insight', // Your app name
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: AppColors.textInverse, // White text for contrast
                    fontWeight: FontWeight.bold,
                    letterSpacing:
                        2.0, // A bit of letter spacing for brand name
                  ),
                ),
              ),
              const SizedBox(height: 12), // Smaller space for tagline
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'Empowering Your Business', // Your tagline
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textInverse.withOpacity(
                      0.8,
                    ), // Slightly muted white for tagline
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
