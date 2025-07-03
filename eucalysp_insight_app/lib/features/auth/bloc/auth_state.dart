// lib/features/auth/bloc/auth_state.dart
import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {} // Initial state of the AuthCubit

class AuthLoading
    extends
        AuthState {} // When authentication process is ongoing (e.g., logging in)

class Authenticated extends AuthState {
  final String userId; // Or a more complex User object
  const Authenticated({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class Unauthenticated extends AuthState {} // User is not logged in

class AuthError extends AuthState {
  final String message;
  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}

// --- NEW STATES FOR SIGNUP ---
class SignupSuccess extends AuthState {
  final String message;
  const SignupSuccess({this.message = 'Account created successfully!'});

  @override
  List<Object?> get props => [message];
}

class SignupFailed extends AuthState {
  final String message;
  const SignupFailed({required this.message});

  @override
  List<Object?> get props => [message];
}
