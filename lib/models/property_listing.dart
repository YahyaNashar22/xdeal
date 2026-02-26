class PropertyListing {
  final String id;
  final String name;
  final List<String> images;
  final String? threeSixty;
  final String price;
  final String description;

  /// category can come as:
  /// - String (ObjectId)
  /// - populated object { _id, title }
  final String categoryId;
  final String? categoryTitle;

  /// coords: [lat, lng]
  final List<double> coords;

  final double bedrooms;
  final double bathrooms;
  final List<String> extraFeatures;

  final bool isFeatured;
  final bool isSponsored;
  final bool isListed;
  final bool onSale;
  final bool isRent;
  final double numberOfViews;

  /// owner | middleman
  final String agentType;

  /// daily | monthly | yearly
  final String? rentalPayment;

  /// user_id can come as:
  /// - String (ObjectId)
  /// - populated object { _id, full_name|name, email ... }
  final String userId;
  final String? userName;
  final String? userEmail;
  final String? userPhone;
  final String? userProfilePicture;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  PropertyListing({
    required this.id,
    required this.name,
    required this.images,
    this.threeSixty,
    required this.price,
    required this.description,
    required this.categoryId,
    this.categoryTitle,
    required this.coords,
    required this.bedrooms,
    required this.bathrooms,
    required this.extraFeatures,
    required this.isFeatured,
    required this.isSponsored,
    required this.isListed,
    required this.onSale,
    required this.isRent,
    required this.numberOfViews,
    required this.agentType,
    this.rentalPayment,
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

  factory PropertyListing.fromJson(Map<String, dynamic> json) {
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
      userName = (rawUser['full_name'] ?? rawUser['name'])?.toString();
      userEmail = rawUser['email']?.toString();
      userPhone = (rawUser['phone_number'] ?? rawUser['phone'])?.toString();
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

    return PropertyListing(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      images: images,
      threeSixty: json['three_sixty']?.toString(),
      price: (json['price'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      categoryId: categoryId,
      categoryTitle: categoryTitle,
      coords: normalizedCoords,
      bedrooms: _toDouble(json['bedrooms'], fallback: 0),
      bathrooms: _toDouble(json['bathrooms'], fallback: 0),
      extraFeatures: extraFeatures,
      isFeatured: _toBool(json['is_featured']),
      isSponsored: _toBool(json['is_sponsored']),
      isListed: _toBool(json['is_listed']),
      onSale: _toBool(json['on_sale']),
      isRent: _toBool(json['is_rent']),
      numberOfViews: _toDouble(json['number_of_views'], fallback: 0),
      agentType: (json['agent_type'] ?? 'owner').toString(),
      rentalPayment: json['rental_payment']?.toString(),
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

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'images': images,
      if (threeSixty != null && threeSixty!.trim().isNotEmpty)
        'three_sixty': threeSixty,
      'price': price,
      'description': description,
      'category': categoryId,
      'categoryTitle': categoryTitle ?? "not populated",
      'coords': coords,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'extra_features': extraFeatures,
      'is_featured': isFeatured,
      'is_sponsored': isSponsored,
      'is_listed': isListed,
      'on_sale': onSale,
      'is_rent': isRent,
      'number_of_views': numberOfViews,
      'agent_type': agentType,
      if (rentalPayment != null && rentalPayment!.trim().isNotEmpty)
        'rental_payment': rentalPayment,
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
