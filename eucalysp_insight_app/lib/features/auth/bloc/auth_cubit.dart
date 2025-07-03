// lib/features/auth/bloc/auth_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eucalysp_insight_app/features/auth/bloc/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(Unauthenticated());

  final List<Map<String, String>> _registeredUsers = [
    {'username': 'user', 'password': 'password'}, // Your existing test user
  ];
  // Start in an unauthenticated state

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

  Future<void> signup(String username, String password) async {
    emit(AuthLoading()); // Indicate that signup is in progress

    try {
      // Simulate an API call for signup
      await Future.delayed(const Duration(seconds: 2));

      // Simulate checking if username already exists
      if (_registeredUsers.any((user) => user['username'] == username)) {
        emit(
          const SignupFailed(
            message: 'Username already exists. Please choose another.',
          ),
        );
      } else {
        // Simulate successful registration
        _registeredUsers.add({'username': username, 'password': password});
        emit(
          const SignupSuccess(
            message: 'Account created successfully! You can now log in.',
          ),
        );
      }
    } catch (e) {
      emit(
        SignupFailed(message: 'Signup failed: ${e.toString()}'),
      ); // Handle any unexpected errors during signup
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
