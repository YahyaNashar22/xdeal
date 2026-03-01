import 'package:xdeal/models/ad.dart';
import 'package:xdeal/services/api_client.dart';

class AdsService {
  final ApiClient api;

  AdsService(this.api);

  Map<String, String> _authHeaders(String token) => {
    'Authorization': 'Bearer $token',
  };

  Future<List<Ad>> getAds({int page = 1, int limit = 20}) async {
    final res = await api.getJson(
      '/api/v1/ads',
      query: {'page': '$page', 'limit': '$limit'},
    );

    final raw = (res is Map && res['items'] is List)
        ? (res['items'] as List)
        : <dynamic>[];

    return raw
        .whereType<Map>()
        .map((e) => Ad.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<Ad> createAd({
    required String token,
    required String title,
    required String image,
  }) async {
    final res = await api.postJson(
      '/api/v1/ads',
      headers: _authHeaders(token),
      body: {'title': title.trim(), 'image': image.trim()},
    );
    return Ad.fromJson(Map<String, dynamic>.from(res as Map));
  }

  Future<void> deleteAd({
    required String token,
    required String adId,
  }) async {
    await api.deleteJson(
      '/api/v1/ads/$adId',
      headers: _authHeaders(token),
    );
  }
}

