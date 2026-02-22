// lib/models/vehicle_listing.dart
class VehicleListing {
  final String id;

  final String name;
  final List<String> images;
  final String price;
  final String description;

  /// category can come as:
  /// - String (ObjectId)
  /// - populated object { _id, title }
  final String categoryId;
  final String? categoryTitle;

  /// coords: [lat, lng]
  final List<double> coords;

  final String brand;
  final String model;
  final String? version;

  /// "new" | "used"
  final String condition;

  final double kilometers;
  final String year;

  /// petrol|diesel|electric|hybrid|gas
  final String fuelType;

  /// automatic|manual|semi-automatic
  final String transmissionType;

  /// sedan|hatchback|suv|...
  final String bodyType;

  final double? power;
  final double? consumption;

  /// manual|automatic|none
  final String airConditioning;

  final String color;
  final double numberOfSeats;
  final double numberOfDoors;

  /// cloth|leather|...
  final String interior;

  /// cash|installment
  final String paymentOption;

  final List<String> extraFeatures;

  final bool isFeatured;
  final bool isSponsored;
  final bool isListed;
  final bool onSale;

  final double numberOfViews;

  /// user_id can come as:
  /// - String (ObjectId)
  /// - populated object { _id, name, email ... }
  final String userId;
  final String? userName;
  final String? userEmail;
  final String? userPhone;
  final String? userProfilePicture;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  VehicleListing({
    required this.id,
    required this.name,
    required this.images,
    required this.price,
    required this.description,
    required this.categoryId,
    this.categoryTitle,
    required this.coords,
    required this.brand,
    required this.model,
    this.version,
    required this.condition,
    required this.kilometers,
    required this.year,
    required this.fuelType,
    required this.transmissionType,
    required this.bodyType,
    this.power,
    this.consumption,
    required this.airConditioning,
    required this.color,
    required this.numberOfSeats,
    required this.numberOfDoors,
    required this.interior,
    required this.paymentOption,
    required this.extraFeatures,
    required this.isFeatured,
    required this.isSponsored,
    required this.isListed,
    required this.onSale,
    required this.numberOfViews,
    required this.userId,
    this.userName,
    this.userEmail,
    this.userPhone,
    this.userProfilePicture,
    this.createdAt,
    this.updatedAt,
  });

  static double _toDouble(dynamic v, {double fallback = 0}) {
    if (v == null) return fallback;
    final n = (v is num) ? v.toDouble() : double.tryParse(v.toString());
    return n ?? fallback;
  }

  static bool _toBool(dynamic v, {bool fallback = false}) {
    if (v is bool) return v;
    if (v == null) return fallback;
    final s = v.toString().toLowerCase().trim();
    if (["true", "1", "yes"].contains(s)) return true;
    if (["false", "0", "no"].contains(s)) return false;
    return fallback;
  }

  factory VehicleListing.fromJson(Map<String, dynamic> json) {
    final rawCategory = json['category'];
    String categoryId = '';
    String? categoryTitle;

    if (rawCategory is Map) {
      categoryId = (rawCategory['_id'] ?? rawCategory['id'] ?? '').toString();
      categoryTitle = rawCategory['title']?.toString();
    } else {
      categoryId = (rawCategory ?? '').toString();
    }

    final rawUser = json['user_id'];
    String userId = '';
    String? userName;
    String? userEmail;
    String? userPhone;
    String? userProfilePicture;

    if (rawUser is Map) {
      userId = (rawUser['_id'] ?? rawUser['id'] ?? '').toString();
      userName = rawUser['full_name']?.toString();
      userEmail = rawUser['email']?.toString();
      userPhone = rawUser['phone_number']?.toString();
      userProfilePicture = rawUser['profile_picture']?.toString();
    } else {
      userId = (rawUser ?? '').toString();
    }

    final images =
        (json['images'] as List?)?.map((e) => e.toString()).toList() ??
        <String>[];
    final extraFeatures =
        (json['extra_features'] as List?)?.map((e) => e.toString()).toList() ??
        <String>[];

    final coordsRaw = (json['coords'] as List?) ?? const [];
    final coords = coordsRaw.map((e) => _toDouble(e, fallback: 0)).toList();
    final normalizedCoords = coords.length == 2 ? coords : <double>[0, 0];

    return VehicleListing(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      images: images,
      price: (json['price'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      categoryId: categoryId,
      categoryTitle: categoryTitle,
      coords: normalizedCoords,
      brand: (json['brand'] ?? '').toString(),
      model: (json['model'] ?? '').toString(),
      version: json['version']?.toString(),
      condition: (json['condition'] ?? 'new').toString(),
      kilometers: _toDouble(json['kilometers'], fallback: 0),
      year: (json['year'] ?? '').toString(),
      fuelType: (json['fuel_type'] ?? '').toString(),
      transmissionType: (json['transmission_type'] ?? '').toString(),
      bodyType: (json['body_type'] ?? '').toString(),
      power: json['power'] == null ? null : _toDouble(json['power']),
      consumption: json['consumption'] == null
          ? null
          : _toDouble(json['consumption']),
      airConditioning: (json['air_conditioning'] ?? '').toString(),
      color: (json['color'] ?? '').toString(),
      numberOfSeats: _toDouble(json['number_of_seats'], fallback: 0),
      numberOfDoors: _toDouble(json['number_of_doors'], fallback: 0),
      interior: (json['interior'] ?? '').toString(),
      paymentOption: (json['payment_option'] ?? '').toString(),
      extraFeatures: extraFeatures,
      isFeatured: _toBool(json['is_featured']),
      isSponsored: _toBool(json['is_sponsored']),
      isListed: _toBool(json['is_listed']),
      onSale: _toBool(json['on_sale']),
      numberOfViews: _toDouble(json['number_of_views'], fallback: 0),
      userId: userId,
      userName: userName,
      userEmail: userEmail,
      userPhone: userPhone,
      userProfilePicture: userProfilePicture,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  /// For create/update requests (send ids, not populated objects)
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'images': images,
      'price': price,
      'description': description,
      'category': categoryId,
      'categoryTitle': categoryTitle ?? "not populated",
      'coords': coords,
      'brand': brand,
      'model': model,
      if (version != null) 'version': version,
      'condition': condition,
      'kilometers': kilometers,
      'year': year,
      'fuel_type': fuelType,
      'transmission_type': transmissionType,
      'body_type': bodyType,
      if (power != null) 'power': power,
      if (consumption != null) 'consumption': consumption,
      'air_conditioning': airConditioning,
      'color': color,
      'number_of_seats': numberOfSeats,
      'number_of_doors': numberOfDoors,
      'interior': interior,
      'payment_option': paymentOption,
      'extra_features': extraFeatures,
      'is_featured': isFeatured,
      'is_sponsored': isSponsored,
      'is_listed': isListed,
      'on_sale': onSale,
      'number_of_views': numberOfViews,
      'user_id': {
        '_id': userId,
        'email': userEmail,
        'full_name': userName,
        'phone_number': userPhone,
        'profile_picture': userProfilePicture,
      },
    };
  }
}
