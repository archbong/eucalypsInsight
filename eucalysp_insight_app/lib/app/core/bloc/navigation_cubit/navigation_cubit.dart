// lib/app/core/blocs/navigation_cubit/navigation_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';

// State represents the current selected index
class NavigationCubit extends Cubit<int> {
  // Initial state is 0 (Dashboard)
  NavigationCubit() : super(0);

  // Method to update the selected index
  void updateIndex(int newIndex) {
    emit(newIndex);
  }
}
