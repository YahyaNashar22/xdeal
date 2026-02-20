// lib/services/property_category_service.dart
import '../models/property_category.dart';
import 'api_client.dart';

class PropertyCategoryService {
  final ApiClient api;

  PropertyCategoryService(this.api);

  Future<List<PropertyCategory>> getAll({
    int page = 1,
    int limit = 100,
    String? q,
  }) async {
    final query = <String, String>{
      'page': '$page',
      'limit': '$limit',
      if (q != null && q.trim().isNotEmpty) 'q': q.trim(),
    };

    final data = await api.getJson('/api/v1/property-categories', query: query);

    final list = (data is Map && data['items'] is List)
        ? (data['items'] as List)
        : (data is List ? data : <dynamic>[]);

    return list
        .map((e) => PropertyCategory.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
