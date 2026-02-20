// lib/services/vehicle_category_service.dart
import '../models/vehicle_category.dart';
import 'api_client.dart';

class VehicleCategoryService {
  final ApiClient api;

  VehicleCategoryService(this.api);

  Future<List<VehicleCategory>> getAll({
    int page = 1,
    int limit = 100,
    String? q,
  }) async {
    final query = <String, String>{
      'page': '$page',
      'limit': '$limit',
      if (q != null && q.trim().isNotEmpty) 'q': q.trim(),
    };

    final data = await api.getJson('/api/v1/vehicle-categories', query: query);

    // supports {items:[...]} OR plain list [...]
    final list = (data is Map && data['items'] is List)
        ? (data['items'] as List)
        : (data is List ? data : <dynamic>[]);

    return list
        .map((e) => VehicleCategory.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
