import 'package:eucalysp_insight_app/features/business/domain/entities/business.dart';
import 'package:hive/hive.dart';

abstract class BusinessRepository {
  Future<List<Business>> fetchUserBusinesses(String userId);
  Future<void> createBusiness(String userId, Business business);
  Future<void> updateBusiness(String userId, Business business);
  Future<void> deleteBusiness(String userId, String businessId);
}

class HiveBusinessRepository implements BusinessRepository {
  static const String _boxName = 'businesses';

  Future<Box<Business>> _openBox() async {
    return await Hive.openBox<Business>(_boxName);
  }

  @override
  Future<List<Business>> fetchUserBusinesses(String userId) async {
    final box = await _openBox();
    return box.values.toList();
  }

  @override
  Future<void> createBusiness(String userId, Business business) async {
    final box = await _openBox();
    await box.put(business.id, business);
  }

  @override
  Future<void> updateBusiness(String userId, Business business) async {
    final box = await _openBox();
    await box.put(business.id, business);
  }

  @override
  Future<void> deleteBusiness(String userId, String businessId) async {
    final box = await _openBox();
    await box.delete(businessId);
  }
}
