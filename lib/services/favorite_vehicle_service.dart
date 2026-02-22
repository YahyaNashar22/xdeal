import '../services/api_client.dart';
import '../models/user.dart';

class FavoriteVehicleService {
  final ApiClient api;

  FavoriteVehicleService(this.api);

  Map<String, String> _authHeaders(User user) => {
    'Authorization': 'Bearer ${user.token}',
  };

  /// POST /api/v1/favorite-vehicles  body: { vehicle_id }
  Future<void> add(User user, String vehicleId) async {
    await api.postJson(
      '/api/v1/favorite-vehicles',
      headers: _authHeaders(user),
      body: {'vehicle_id': vehicleId},
    );
  }

  /// DELETE /api/v1/favorite-vehicles/:vehicleId
  Future<bool> remove(User user, String vehicleId) async {
    final res = await api.deleteJson(
      '/api/v1/favorite-vehicles/$vehicleId',
      headers: _authHeaders(user),
    );

    if (res is Map && res['removed'] is bool) return res['removed'] as bool;
    return true; // fallback
  }

  /// POST /api/v1/favorite-vehicles/toggle body: { vehicle_id }
  Future<bool> toggle(User user, String vehicleId) async {
    final res = await api.postJson(
      '/api/v1/favorite-vehicles/toggle',
      headers: _authHeaders(user),
      body: {'vehicle_id': vehicleId},
    );

    if (res is Map && res['favorited'] is bool) return res['favorited'] as bool;
    throw Exception('Unexpected response');
  }

  /// GET /api/v1/favorite-vehicles/check/:vehicleId  -> { favorited: boolean }
  Future<bool> isFavorited(User user, String vehicleId) async {
    final res = await api.getJson(
      '/api/v1/favorite-vehicles/check/$vehicleId',
      headers: _authHeaders(user),
    );

    if (res is Map && res['favorited'] is bool) return res['favorited'] as bool;
    return false;
  }

  /// GET /api/v1/favorite-vehicles/me/ids -> [vehicleId]
  Future<List<String>> myFavoriteVehicleIds(User user) async {
    final res = await api.getJson(
      '/api/v1/favorite-vehicles/me/ids',
      headers: _authHeaders(user),
    );

    if (res is List) return res.map((e) => e.toString()).toList();
    return [];
  }

  /// GET /api/v1/favorite-vehicles/me?page=&limit=
  /// Returns raw map, because you may populate vehicle_id (full vehicle object).
  Future<Map<String, dynamic>> myFavorites(
    User user, {
    int page = 1,
    int limit = 20,
  }) async {
    final res = await api.getJson(
      '/api/v1/favorite-vehicles/me',
      headers: _authHeaders(user),
      query: {'page': '$page', 'limit': '$limit'},
    );

    if (res is Map) return Map<String, dynamic>.from(res);
    throw Exception('Unexpected response');
  }
}
