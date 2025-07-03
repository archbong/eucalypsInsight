// lib/features/auth/presentation/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:eucalysp_insight_app/features/auth/bloc/auth_cubit.dart';
import 'package:eucalysp_insight_app/features/auth/bloc/auth_state.dart';
import 'package:eucalysp_insight_app/app/core/services/layout_service.dart'; // Import for responsiveness
import 'package:eucalysp_insight_app/app/app_theme.dart'; // Import AppThemeColors, AppRadius

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailOrUsernameController =
      TextEditingController(); // Renamed for clarity
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final bool isMobile = LayoutService.isMobileLayout(context);
    final AppThemeColors appColors = Theme.of(
      context,
    ).extension<AppThemeColors>()!;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    // Define widths based on layout
    final double formWidth = isMobile
        ? MediaQuery.of(context).size.width * 0.9
        : 400.0;
    final double buttonHeight = isMobile ? 50.0 : 55.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Logged in successfully!',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: appColors.textInverse,
                  ),
                ),
                backgroundColor: appColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
            context.go('/dashboard');
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: appColors.textInverse,
                  ),
                ),
                backgroundColor: appColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          return Center(
            child: SingleChildScrollView(
              // Added SingleChildScrollView
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                // Added ConstrainedBox for width control
                constraints: BoxConstraints(maxWidth: formWidth),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch, // Stretch children
                  children: [
                    Text(
                      'Welcome Back!',
                      style: Theme.of(context).textTheme.headlineMedium!
                          .copyWith(
                            color: appColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    TextField(
                      controller:
                          _emailOrUsernameController, // Renamed controller
                      keyboardType:
                          TextInputType.emailAddress, // Suggest email keyboard
                      decoration: InputDecoration(
                        labelText:
                            'Email or Username (for demo)', // Updated label
                        hintText: 'Enter your email or username',
                        prefixIcon: Icon(
                          Icons.person_outline,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          borderSide: BorderSide(color: colorScheme.outline),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          borderSide: BorderSide(color: colorScheme.outline),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          borderSide: BorderSide(
                            color: colorScheme.primary,
                            width: 2.0,
                          ),
                        ),
                        labelStyle: TextStyle(color: appColors.textSecondary),
                        hintStyle: TextStyle(color: appColors.textMuted),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter your password',
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          borderSide: BorderSide(color: colorScheme.outline),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          borderSide: BorderSide(color: colorScheme.outline),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          borderSide: BorderSide(
                            color: colorScheme.primary,
                            width: 2.0,
                          ),
                        ),
                        labelStyle: TextStyle(color: appColors.textSecondary),
                        hintStyle: TextStyle(color: appColors.textMuted),
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (state is AuthLoading)
                      Center(
                        child: CircularProgressIndicator(
                          color: appColors.primary,
                        ),
                      )
                    else
                      ElevatedButton(
                        onPressed: () {
                          context.read<AuthCubit>().login(
                            _emailOrUsernameController.text.trim(),
                            _passwordController.text,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: appColors.primary,
                          foregroundColor: appColors.textInverse,
                          padding: EdgeInsets.symmetric(
                            vertical:
                                (buttonHeight -
                                    Theme.of(
                                      context,
                                    ).textTheme.labelLarge!.fontSize!) /
                                2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                          ),
                          minimumSize: Size(double.infinity, buttonHeight),
                        ),
                        child: Text(
                          'Login',
                          style: Theme.of(context).textTheme.labelLarge!
                              .copyWith(
                                color: appColors.textInverse,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    // --- NEW: Link to Signup Screen ---
                    TextButton(
                      onPressed: () {
                        context.go('/signup'); // Navigate to signup screen
                      },
                      child: Text(
                        "Don't have an account? Sign Up",
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color:
                              colorScheme.primary, // Make it look like a link
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    // Optional: A simple logout button for testing authenticated state
                    if (state is Authenticated) ...[
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          context.read<AuthCubit>().logout();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              appColors.error, // Use theme error color
                          foregroundColor: appColors
                              .textInverse, // Use theme inverse text color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                          ),
                        ),
                        child: const Text('Logout'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _emailOrUsernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
