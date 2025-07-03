// lib/features/business/bloc/business_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eucalysp_insight_app/features/business/bloc/business_state.dart';
import 'package:eucalysp_insight_app/features/business/domain/entities/business.dart';
import 'package:eucalysp_insight_app/features/business/data/repositories/business_repository.dart';

class BusinessCubit extends Cubit<BusinessState> {
  final BusinessRepository _businessRepository;

  BusinessCubit({required BusinessRepository businessRepository})
    : _businessRepository = businessRepository,
      super(BusinessInitial());

  Future<void> fetchBusinesses(String userId) async {
    emit(BusinessLoading());
    try {
      final businesses = await _businessRepository.fetchUserBusinesses(userId);
      emit(BusinessLoaded(availableBusinesses: businesses));
    } catch (e) {
      emit(
        BusinessError(message: 'Failed to load businesses: ${e.toString()}'),
      );
    }
  }

  void selectBusiness(Business business) {
    if (state is BusinessLoaded) {
      final currentState = state as BusinessLoaded;
      emit(
        BusinessLoaded(
          availableBusinesses: currentState.availableBusinesses,
          selectedBusiness: business,
        ),
      );
    }
  }

  Future<void> createBusiness(Business business) async {
    emit(BusinessLoading());
    try {
      await _businessRepository.createBusiness('userId', business);
      final businesses = await _businessRepository.fetchUserBusinesses(
        'userId',
      );
      emit(BusinessLoaded(availableBusinesses: businesses));
    } catch (e) {
      emit(
        BusinessError(message: 'Failed to create business: ${e.toString()}'),
      );
    }
  }

  Future<void> updateBusiness(Business business) async {
    emit(BusinessLoading());
    try {
      await _businessRepository.updateBusiness('userId', business);
      final businesses = await _businessRepository.fetchUserBusinesses(
        'userId',
      );
      emit(BusinessLoaded(availableBusinesses: businesses));
    } catch (e) {
      emit(
        BusinessError(message: 'Failed to update business: ${e.toString()}'),
      );
    }
  }

  Future<void> deleteBusiness(String businessId) async {
    emit(BusinessLoading());
    try {
      await _businessRepository.deleteBusiness('userId', businessId);
      final businesses = await _businessRepository.fetchUserBusinesses(
        'userId',
      );
      emit(BusinessLoaded(availableBusinesses: businesses));
    } catch (e) {
      emit(
        BusinessError(message: 'Failed to delete business: ${e.toString()}'),
      );
    }
  }

  // Method to clear selected business, useful on logout
  void clearSelectedBusiness() {
    if (state is BusinessLoaded) {
      final currentState = state as BusinessLoaded;
      emit(
        BusinessLoaded(
          availableBusinesses: currentState.availableBusinesses,
          selectedBusiness: null,
        ),
      );
    } else {
      // If not in Loaded state, reset to initial or loading if needed
      emit(BusinessInitial());
    }
  }
}
