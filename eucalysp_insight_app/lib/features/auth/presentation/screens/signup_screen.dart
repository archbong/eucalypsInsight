// lib/features/auth/presentation/screens/signup_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:eucalysp_insight_app/features/auth/bloc/auth_cubit.dart';
import 'package:eucalysp_insight_app/features/auth/bloc/auth_state.dart';
import 'package:eucalysp_insight_app/app/core/services/layout_service.dart'; // For responsive layout
import 'package:eucalysp_insight_app/app/app_theme.dart'; // For AppRadius and AppColors (or AppThemeColors)

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>(); // For form validation

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
    final double buttonHeight = isMobile
        ? 50.0
        : 55.0; // Slightly taller buttons on desktop

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is SignupSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: appColors.textInverse,
                  ),
                ),
                backgroundColor: appColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
            // Optionally navigate to login after successful signup
            context.go('/login');
          } else if (state is SignupFailed) {
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
          // Note: AuthLoading is handled by the button/indicator directly in the builder
        },
        child: Center(
          child: SingleChildScrollView(
            // Use SingleChildScrollView to prevent overflow on small screens
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              // Constrain width for desktop
              constraints: BoxConstraints(maxWidth: formWidth),
              child: Form(
                // Use Form for validation
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment
                      .stretch, // Stretch children to fill width
                  children: [
                    Text(
                      'Create Your Account',
                      style: Theme.of(context).textTheme.headlineMedium!
                          .copyWith(
                            color: appColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'Enter your email address',
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          borderSide: BorderSide(color: colorScheme.outline),
                        ),
                        enabledBorder: OutlineInputBorder(
                          // Consistent border for enabled state
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          borderSide: BorderSide(color: colorScheme.outline),
                        ),
                        focusedBorder: OutlineInputBorder(
                          // Highlight border for focused state
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          borderSide: BorderSide(
                            color: colorScheme.primary,
                            width: 2.0,
                          ),
                        ),
                        labelStyle: TextStyle(
                          color: appColors.textSecondary,
                        ), // Use textSecondary for label
                        hintStyle: TextStyle(
                          color: appColors.textMuted,
                        ), // Use textMuted for hint
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email.';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Please enter a valid email address.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password.';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters long.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        hintText: 'Re-enter your password',
                        prefixIcon: Icon(
                          Icons.lock_reset_outlined,
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password.';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, state) {
                        return ElevatedButton(
                          onPressed: state is AuthLoading
                              ? null
                              : _signup, // Disable when loading
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
                            minimumSize: Size(
                              double.infinity,
                              buttonHeight,
                            ), // Full width and specified height
                          ),
                          child: state is AuthLoading
                              ? SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: appColors.textInverse,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'Sign Up',
                                  style: Theme.of(context).textTheme.labelLarge!
                                      .copyWith(
                                        color: appColors.textInverse,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        context.go('/login'); // Navigate back to login
                      },
                      child: Text(
                        'Already have an account? Log In',
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color:
                              colorScheme.primary, // Make it look like a link
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _signup() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().signup(
        _emailController.text.trim(), // Trim whitespace from email
        _passwordController.text,
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
