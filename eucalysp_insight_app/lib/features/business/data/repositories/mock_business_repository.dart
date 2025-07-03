// business-app/eucalypsInsight/eucalysp_insight_app/lib/test/mocks/mock_business_repository.dart
// (This is a suggested path for your mock files)

import 'package:eucalysp_insight_app/features/business/domain/entities/business.dart';
import 'package:eucalysp_insight_app/features/business/data/repositories/business_repository.dart'; // Import the abstract class

class MockBusinessRepository implements BusinessRepository {
  // A map to simulate in-memory storage, keyed by userId
  // Each userId will have a list of businesses associated with it.
  final Map<String, List<Business>> _businessesByUser = {
    'user1': [
      const Business(
        id: 'biz1_user1',
        name: 'Alpha Solutions',
        description: 'Providing top-tier IT services.',
      ),
      const Business(
        id: 'biz2_user1',
        name: 'Beta Ventures',
        description: 'Investment and consulting firm.',
      ),
    ],
    'user2': [
      const Business(
        id: 'biz3_user2',
        name: 'Gamma Tech',
        description: 'Cutting-edge hardware development.',
      ),
    ],
    // Add more mock data for different users as needed for your tests
  };

  @override
  Future<List<Business>> fetchUserBusinesses(String userId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    // Return a copy to prevent external modification of internal mock state
    return _businessesByUser[userId]?.toList() ?? [];
  }

  @override
  Future<void> createBusiness(String userId, Business business) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    // Add the business to the user's list, creating the list if it doesn't exist
    _businessesByUser.putIfAbsent(userId, () => []).add(business);
  }

  @override
  Future<void> updateBusiness(String userId, Business business) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    final userBusinesses = _businessesByUser[userId];
    if (userBusinesses != null) {
      final index = userBusinesses.indexWhere((b) => b.id == business.id);
      if (index != -1) {
        userBusinesses[index] = business;
      } else {
        // Optionally throw an error or add the business if not found, depending on desired mock behavior
        throw Exception(
          'Business with ID ${business.id} not found for user $userId',
        );
      }
    } else {
      throw Exception('User $userId has no businesses to update.');
    }
  }

  @override
  Future<void> deleteBusiness(String userId, String businessId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    final userBusinesses = _businessesByUser[userId];
    if (userBusinesses != null) {
      final initialLength = userBusinesses.length;
      userBusinesses.removeWhere((b) => b.id == businessId);
      if (userBusinesses.length == initialLength) {
        // Business was not found
        throw Exception(
          'Business with ID $businessId not found for user $userId',
        );
      }
    } else {
      throw Exception('User $userId has no businesses to delete from.');
    }
  }

  // --- Utility method for testing ---
  // You can add methods like this to reset the mock state between tests
  void reset() {
    _businessesByUser.clear();
    // Re-populate with initial data if needed for subsequent tests
    _businessesByUser['user1'] = [
      const Business(
        id: 'biz1_user1',
        name: 'Alpha Solutions',
        description: 'Providing top-tier IT services.',
      ),
      const Business(
        id: 'biz2_user1',
        name: 'Beta Ventures',
        description: 'Investment and consulting firm.',
      ),
    ];
    _businessesByUser['user2'] = [
      const Business(
        id: 'biz3_user2',
        name: 'Gamma Tech',
        description: 'Cutting-edge hardware development.',
      ),
    ];
  }
}
