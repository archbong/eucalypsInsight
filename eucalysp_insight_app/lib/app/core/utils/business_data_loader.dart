// lib/app/core/utils/business_data_loader.dart
import 'dart:async';
import 'package:eucalysp_insight_app/features/business/bloc/business_cubit.dart';
import 'package:eucalysp_insight_app/features/business/bloc/business_state.dart';
import 'package:eucalysp_insight_app/app/core/bloc/business_data_bloc.dart';

/// Handles automatic business data loading based on business selection changes
class BusinessDataLoader<State, Cubit extends BusinessDataBloc<State>> {
  final BusinessCubit _businessCubit;
  final Cubit _dataCubit;
  late final StreamSubscription _businessSub;

  BusinessDataLoader({
    required BusinessCubit businessCubit,
    required Cubit dataCubit,
  }) : _businessCubit = businessCubit,
       _dataCubit = dataCubit {
    _init();
  }

  void _init() {
    // Listen to business selection changes
    _businessSub = _businessCubit.stream.listen((businessState) {
      if (businessState is BusinessLoaded &&
          businessState.selectedBusiness != null) {
        _dataCubit.loadData(businessState.selectedBusiness!.id);
      } else if (businessState is BusinessLoaded &&
          businessState.selectedBusiness == null) {
        _dataCubit.emit(BusinessDataInitial());
      }
    });

    // Initial load if business already selected
    if (_businessCubit.state is BusinessLoaded &&
        (_businessCubit.state as BusinessLoaded).selectedBusiness != null) {
      _dataCubit.loadData(
        (_businessCubit.state as BusinessLoaded).selectedBusiness!.id,
      );
    }
  }

  /// Clean up resources
  void dispose() {
    _businessSub.cancel();
  }
}
