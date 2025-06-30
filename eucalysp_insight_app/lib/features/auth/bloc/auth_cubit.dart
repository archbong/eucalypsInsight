// lib/features/auth/bloc/auth_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eucalysp_insight_app/features/auth/bloc/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(Unauthenticated()); // Start in an unauthenticated state

  Future<void> login(String username, String password) async {
    emit(AuthLoading()); // Indicate that login is in progress

    try {
      // Simulate an API call for login
      await Future.delayed(const Duration(seconds: 2));

      if (username == 'user' && password == 'password') {
        emit(const Authenticated(userId: 'user123')); // User is authenticated
      } else {
        emit(
          const AuthError(message: 'Invalid username or password.'),
        ); // Authentication failed
      }
    } catch (e) {
      emit(
        AuthError(message: 'Login failed: ${e.toString()}'),
      ); // Handle any unexpected errors
    }
  }

  void logout() {
    emit(Unauthenticated()); // Transition to unauthenticated state
  }

  // A method to check initial authentication status, e.g., from stored token
  Future<void> checkAuthStatus() async {
    emit(AuthLoading());
    try {
      // Simulate checking a local token or session
      await Future.delayed(const Duration(seconds: 1));
      // For now, assume not authenticated initially
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(message: 'Failed to check auth status: ${e.toString()}'));
    }
  }
}
