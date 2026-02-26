import '../models/property_listing.dart';
import 'api_client.dart';

class PropertyListingService {
  final ApiClient api;

  PropertyListingService(this.api);

  Future<List<PropertyListing>> getAll({
    int page = 1,
    int limit = 20,
    String? q,
    String? categoryId,
    String? userId,
    bool? isFeatured,
    bool? isSponsored,
    bool? isListed,
    bool? onSale,
    bool? isRent,
    String? agentType,
    int? bedroomsMin,
    int? bedroomsMax,
    int? bathroomsMin,
    int? bathroomsMax,
    int? spaceMin,
    int? spaceMax,
    String sortBy = "createdAt",
    String sortDir = "desc",
  }) async {
    final query = <String, String>{
      'page': '$page',
      'limit': '$limit',
      'sortBy': sortBy,
      'sortDir': sortDir,
      if (q != null && q.trim().isNotEmpty) 'q': q.trim(),
      if (categoryId != null && categoryId.trim().isNotEmpty)
        'category': categoryId.trim(),
      if (userId != null && userId.trim().isNotEmpty) 'user_id': userId.trim(),
      if (isFeatured != null) 'is_featured': '$isFeatured',
      if (isSponsored != null) 'is_sponsored': '$isSponsored',
      if (isListed != null) 'is_listed': '$isListed',
      if (onSale != null) 'on_sale': '$onSale',
      if (isRent != null) 'is_rent': '$isRent',
      if (agentType != null && agentType.trim().isNotEmpty)
        'agent_type': agentType.trim(),
      if (bedroomsMin != null) 'bedrooms_min': '$bedroomsMin',
      if (bedroomsMax != null) 'bedrooms_max': '$bedroomsMax',
      if (bathroomsMin != null) 'bathrooms_min': '$bathroomsMin',
      if (bathroomsMax != null) 'bathrooms_max': '$bathroomsMax',
      if (spaceMin != null) 'space_min': '$spaceMin',
      if (spaceMax != null) 'space_max': '$spaceMax',
    };

    final data = await api.getJson('/api/v1/property-listing', query: query);

    final list = (data is Map && data['items'] is List)
        ? (data['items'] as List)
        : (data is List ? data : <dynamic>[]);

    return list
        .map((e) => PropertyListing.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<PropertyListing> getById(String id) async {
    final data = await api.getJson('/api/v1/property-listing/$id');
    return PropertyListing.fromJson(Map<String, dynamic>.from(data));
  }

  Future<PropertyListing> create(PropertyListing listing) async {
    final data = await api.postJson(
      '/api/v1/property-listing',
      body: listing.toJson(),
    );
    return PropertyListing.fromJson(Map<String, dynamic>.from(data));
  }

  Future<PropertyListing> update(String id, Map<String, dynamic> patch) async {
    final data = await api.putJson('/api/v1/property-listing/$id', body: patch);
    return PropertyListing.fromJson(Map<String, dynamic>.from(data));
  }

  Future<void> delete(String id) async {
    await api.deleteJson('/api/v1/property-listing/$id');
  }

  Future<PropertyListing> incrementViews(String id) async {
    final data = await api.patchJson('/api/v1/property-listing/$id/views');
    return PropertyListing.fromJson(Map<String, dynamic>.from(data));
  }
}
