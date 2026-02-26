import 'api_client.dart';

class FavoritePropertyService {
  final ApiClient api;

  FavoritePropertyService(this.api);

  Future<void> add({
    required String userId,
    required String propertyId,
  }) async {
    await api.postJson(
      '/api/v1/favorite-property',
      body: {'user_id': userId, 'property_id': propertyId},
    );
  }

  Future<void> remove({
    required String userId,
    required String propertyId,
  }) async {
    await api.postJson(
      '/api/v1/favorite-property/toggle',
      body: {'user_id': userId, 'property_id': propertyId},
    );
  }

  Future<bool> toggle({
    required String userId,
    required String propertyId,
  }) async {
    final res = await api.postJson(
      '/api/v1/favorite-property/toggle',
      body: {'user_id': userId, 'property_id': propertyId},
    );

    if (res is Map && res['isFavorited'] is bool) {
      return res['isFavorited'] as bool;
    }
    throw Exception('Unexpected response');
  }

  Future<bool> isFavorited({
    required String userId,
    required String propertyId,
  }) async {
    final res = await api.getJson(
      '/api/v1/favorite-property/check',
      query: {'user_id': userId, 'property_id': propertyId},
    );

    if (res is Map && res['isFavorited'] is bool) {
      return res['isFavorited'] as bool;
    }
    return false;
  }

  Future<Map<String, dynamic>> myFavorites({
    required String userId,
  }) async {
    final res = await api.getJson('/api/v1/favorite-property/user/$userId');
    if (res is Map) return Map<String, dynamic>.from(res);
    throw Exception('Unexpected response');
  }
}
