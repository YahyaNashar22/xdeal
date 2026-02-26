import 'package:xdeal/models/saved_search.dart';
import 'package:xdeal/services/api_client.dart';

class SavedSearchService {
  final ApiClient api;

  SavedSearchService(this.api);

  Future<List<SavedSearch>> getAll(String userId) async {
    final res = await api.getJson(
      '/api/v1/saved-searches',
      query: {'user_id': userId},
    );

    final raw = (res is Map && res['items'] is List)
        ? (res['items'] as List)
        : <dynamic>[];

    final items = raw
        .whereType<Map>()
        .map((e) => SavedSearch.fromJson(Map<String, dynamic>.from(e)))
        .where((e) => e.searchTerm.trim().isNotEmpty)
        .toList();

    // keep unique terms, newest first
    final seen = <String>{};
    final deduped = <SavedSearch>[];
    for (final item in items) {
      final key = item.searchTerm.trim().toLowerCase();
      if (seen.contains(key)) continue;
      seen.add(key);
      deduped.add(item);
    }

    return deduped;
  }

  Future<void> create({
    required String userId,
    required String searchTerm,
  }) async {
    await api.postJson(
      '/api/v1/saved-searches',
      body: {'user_id': userId, 'search_term': searchTerm.trim()},
    );
  }

  Future<void> deleteById(String id) async {
    await api.deleteJson('/api/v1/saved-searches/$id');
  }
}
