// lib/features/business/data/repositories/business_repository.dart
import 'package:eucalysp_insight_app/features/business/domain/entities/business.dart';

abstract class BusinessRepository {
  Future<List<Business>> fetchUserBusinesses(String userId);
  // In a real app, you might also have selectBusinessOnBackend() if selection is persisted server-side.
}

class MockBusinessRepository implements BusinessRepository {
  @override
  Future<List<Business>> fetchUserBusinesses(String userId) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Return dummy businesses based on userId (though userId isn't used here for simplicity)
    return const [
      Business(
        id: 'biz1',
        name: 'Alpha Solutions Inc.',
        description: 'Software Development',
      ),
      Business(
        id: 'biz2',
        name: 'Beta Retail Stores',
        description: 'Retail Chain',
      ),
      Business(
        id: 'biz3',
        name: 'Gamma Logistics Ltd.',
        description: 'Shipping & Delivery',
      ),
    ];
  }
}
