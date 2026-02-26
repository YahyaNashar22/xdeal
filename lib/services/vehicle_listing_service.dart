// lib/services/vehicle_listing_service.dart
import '../models/vehicle_listing.dart';
import 'api_client.dart';

class VehicleListingService {
  final ApiClient api;

  VehicleListingService(this.api);

  Future<List<VehicleListing>> getAll({
    int page = 1,
    int limit = 20,
    String? q,
    String? categoryId,
    String? userId,
    bool? isFeatured,
    bool? isSponsored,
    bool? isListed,
    bool? onSale,
    String? condition, // new/used
    String? brand,
    String? model,
    String? fuelType,
    String? transmissionType,
    String? bodyType,
    String? paymentOption,
    int? yearMin,
    int? yearMax,
    int? kmMin,
    int? kmMax,
    double? lat,
    double? lng,
    double? radiusKm,
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
      if (condition != null && condition.trim().isNotEmpty)
        'condition': condition.trim(),
      if (brand != null && brand.trim().isNotEmpty) 'brand': brand.trim(),
      if (model != null && model.trim().isNotEmpty) 'model': model.trim(),
      if (fuelType != null && fuelType.trim().isNotEmpty)
        'fuel_type': fuelType.trim(),
      if (transmissionType != null && transmissionType.trim().isNotEmpty)
        'transmission_type': transmissionType.trim(),
      if (bodyType != null && bodyType.trim().isNotEmpty)
        'body_type': bodyType.trim(),
      if (paymentOption != null && paymentOption.trim().isNotEmpty)
        'payment_option': paymentOption.trim(),
      if (yearMin != null) 'year_min': '$yearMin',
      if (yearMax != null) 'year_max': '$yearMax',
      if (kmMin != null) 'km_min': '$kmMin',
      if (kmMax != null) 'km_max': '$kmMax',
      if (lat != null) 'lat': '$lat',
      if (lng != null) 'lng': '$lng',
      if (radiusKm != null) 'radius_km': '$radiusKm',
    };

    final data = await api.getJson('/api/v1/vehicle-listing', query: query);

    final list = (data is Map && data['items'] is List)
        ? (data['items'] as List)
        : (data is List ? data : <dynamic>[]);

    return list
        .map((e) => VehicleListing.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<VehicleListing> getById(String id) async {
    final data = await api.getJson('/api/v1/vehicle-listing/$id');
    return VehicleListing.fromJson(Map<String, dynamic>.from(data));
  }

  Future<VehicleListing> create(VehicleListing listing) async {
    final data = await api.postJson(
      '/api/v1/vehicle-listing',
      body: listing.toJson(),
    );
    return VehicleListing.fromJson(Map<String, dynamic>.from(data));
  }

  Future<VehicleListing> createFromMap(Map<String, dynamic> payload) async {
    final data = await api.postJson('/api/v1/vehicle-listing', body: payload);
    return VehicleListing.fromJson(Map<String, dynamic>.from(data));
  }

  Future<VehicleListing> update(String id, Map<String, dynamic> patch) async {
    final data = await api.putJson('/api/v1/vehicle-listing/$id', body: patch);
    return VehicleListing.fromJson(Map<String, dynamic>.from(data));
  }

  Future<void> delete(String id) async {
    await api.deleteJson('/api/v1/vehicle-listing/$id');
  }

  Future<VehicleListing> incrementViews(String id) async {
    final data = await api.patchJson('/api/v1/vehicle-listing/$id/views');
    return VehicleListing.fromJson(Map<String, dynamic>.from(data));
  }
}
