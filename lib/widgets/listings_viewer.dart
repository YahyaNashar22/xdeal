import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:xdeal/providers/user_provider.dart';

import 'package:xdeal/services/api_client.dart';
import 'package:xdeal/services/favorite_property_service.dart';
import 'package:xdeal/services/favorite_vehicle_service.dart';
import 'package:xdeal/services/property_listing_service.dart';
import 'package:xdeal/services/vehicle_listing_service.dart';
import 'package:xdeal/models/property_listing.dart' as pmodel;
import 'package:xdeal/models/vehicle_listing.dart' as vmodel;
import 'package:xdeal/widgets/property_listing.dart' as p;
import 'package:xdeal/widgets/vehicle_listing.dart' as v;

enum ListingFilter { none, newest, cheapest, expensive, notListed }

class ListingsViewer extends StatefulWidget {
  final int selectedView; // 0 properties, 1 vehicles
  final bool isDealerProfile;
  final bool isUploaderViewing;
  final bool onlyFavorites;
  final ListingFilter filter;
  final String? userId;

  final String q;
  final String? categoryId;
  final Map<String, dynamic> extraFilters;

  const ListingsViewer({
    super.key,
    required this.selectedView,
    required this.q,
    required this.categoryId,
    this.isDealerProfile = false,
    this.isUploaderViewing = false,
    this.onlyFavorites = false,
    this.filter = ListingFilter.newest,
    this.userId,
    this.extraFilters = const {},
  });

  @override
  State<ListingsViewer> createState() => _ListingsViewerState();
}

class _ListingsViewerState extends State<ListingsViewer> {
  final _scrollController = ScrollController();

  late final ApiClient _api;
  late final FavoritePropertyService _favoritePropertyService;
  late final FavoriteVehicleService _favoriteVehicleService;
  late final PropertyListingService _propertyService;
  late final VehicleListingService _vehicleService;

  final List<pmodel.PropertyListing> _properties = [];
  final List<vmodel.VehicleListing> _vehicles = [];

  bool _loadingFirstPage = false;
  bool _loadingMore = false;
  bool _hasMore = true;
  int _page = 1;
  final int _limit = 10;
  String? _error;

  @override
  void initState() {
    super.initState();

    _api = ApiClient(baseUrl: 'http://10.0.2.2:5000');
    _favoritePropertyService = FavoritePropertyService(_api);
    _favoriteVehicleService = FavoriteVehicleService(_api);
    _propertyService = PropertyListingService(_api);
    _vehicleService = VehicleListingService(_api);

    _scrollController.addListener(_onScroll);
    _fetchFirstPage();
  }

  @override
  void didUpdateWidget(covariant ListingsViewer oldWidget) {
    super.didUpdateWidget(oldWidget);

    final viewChanged = oldWidget.selectedView != widget.selectedView;
    final filterChanged = oldWidget.filter != widget.filter;
    final favChanged = oldWidget.onlyFavorites != widget.onlyFavorites;
    final userChanged = oldWidget.userId != widget.userId;
    final qChanged = oldWidget.q != widget.q;
    final catChanged = oldWidget.categoryId != widget.categoryId;
    final extraChanged = !mapEquals(oldWidget.extraFilters, widget.extraFilters);

    if (viewChanged ||
        filterChanged ||
        favChanged ||
        userChanged ||
        qChanged ||
        catChanged ||
        extraChanged) {
      _resetAndRefetch();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_hasMore || _loadingMore || _loadingFirstPage) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 250) {
      _fetchMore();
    }
  }

  Future<void> _resetAndRefetch() async {
    if (!mounted) return;

    setState(() {
      _properties.clear();
      _vehicles.clear();
      _page = 1;
      _hasMore = true;
      _error = null;
    });

    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }

    await _fetchFirstPage();
  }

  ({String sortBy, String sortDir, bool? isListed}) _filterToQuery() {
    switch (widget.filter) {
      case ListingFilter.newest:
        return (sortBy: "createdAt", sortDir: "desc", isListed: true);
      case ListingFilter.cheapest:
        return (sortBy: "price", sortDir: "asc", isListed: true);
      case ListingFilter.expensive:
        return (sortBy: "price", sortDir: "desc", isListed: true);
      case ListingFilter.notListed:
        return (sortBy: "createdAt", sortDir: "desc", isListed: false);
      case ListingFilter.none:
        return (sortBy: "createdAt", sortDir: "desc", isListed: true);
    }
  }

  Future<void> _fetchFirstPage() async {
    setState(() {
      _loadingFirstPage = true;
      _error = null;
    });

    try {
      final f = _filterToQuery();
      if (widget.onlyFavorites) {
        final currentUser = context.read<UserProvider>().user;
        if (currentUser == null || widget.userId == null) {
          if (!mounted) return;
          setState(() {
            _properties.clear();
            _vehicles.clear();
            _page = 1;
            _hasMore = false;
          });
          return;
        }

        if (widget.selectedView == 0) {
          final res = await _favoritePropertyService.myFavorites(
            userId: widget.userId!,
          );
          final raw = (res['items'] as List?) ?? const [];
          final items = raw
              .whereType<Map>()
              .map((e) => pmodel.PropertyListing.fromJson(Map<String, dynamic>.from(e)))
              .where((e) => _matchesPropertyFilters(e, f.isListed))
              .toList();

          if (!mounted) return;
          setState(() {
            _properties
              ..clear()
              ..addAll(items);
            _vehicles.clear();
            _page = 1;
            _hasMore = false;
          });
          return;
        }

        final res = await _favoriteVehicleService.myFavorites(
          currentUser,
          page: 1,
          limit: _limit,
        );
        final raw = (res['items'] as List?) ?? const [];
        final total = (res['total'] is num) ? (res['total'] as num).toInt() : 0;
        final items = raw
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .map(_extractVehicleMap)
            .whereType<Map<String, dynamic>>()
            .map(vmodel.VehicleListing.fromJson)
            .where((e) => _matchesVehicleFilters(e, f.isListed))
            .toList();

        if (!mounted) return;
        setState(() {
          _vehicles
            ..clear()
            ..addAll(items);
          _properties.clear();
          _page = 1;
          _hasMore = _limit < total;
        });
        return;
      }

      if (widget.selectedView == 0) {
        final items = await _propertyService.getAll(
          page: 1,
          limit: _limit,
          q: widget.q.trim().isEmpty ? null : widget.q.trim(),
          categoryId: widget.categoryId,
          userId: widget.userId,
          isListed: f.isListed,
          sortBy: f.sortBy,
          sortDir: f.sortDir,
          onSale: _boolFilter('on_sale'),
          isRent: _boolFilter('is_rent'),
          agentType: _strFilter('agent_type'),
          bedroomsMin: _intFilter('bedrooms_min'),
          bedroomsMax: _intFilter('bedrooms_max'),
          bathroomsMin: _intFilter('bathrooms_min'),
          bathroomsMax: _intFilter('bathrooms_max'),
          spaceMin: _intFilter('space_min'),
          spaceMax: _intFilter('space_max'),
          lat: _doubleFilter('lat'),
          lng: _doubleFilter('lng'),
          radiusKm: _doubleFilter('radius_km'),
        );

        final filtered = widget.onlyFavorites
            ? _applyPropertyFavorites(items)
            : items;

        if (!mounted) return;
        setState(() {
          _properties
            ..clear()
            ..addAll(filtered);
          _page = 1;
          _hasMore = items.length == _limit;
        });
      } else {
        final items = await _vehicleService.getAll(
          page: 1,
          limit: _limit,
          q: widget.q.trim().isEmpty ? null : widget.q.trim(),
          categoryId: widget.categoryId,
          userId: widget.userId,
          isListed: f.isListed,
          sortBy: f.sortBy,
          sortDir: f.sortDir,
          onSale: _boolFilter('on_sale'),
          condition: _strFilter('condition'),
          brand: _strFilter('brand'),
          model: _strFilter('model'),
          fuelType: _strFilter('fuel_type'),
          transmissionType: _strFilter('transmission_type'),
          bodyType: _strFilter('body_type'),
          paymentOption: _strFilter('payment_option'),
          yearMin: _intFilter('year_min'),
          yearMax: _intFilter('year_max'),
          kmMin: _intFilter('km_min'),
          kmMax: _intFilter('km_max'),
          lat: _doubleFilter('lat'),
          lng: _doubleFilter('lng'),
          radiusKm: _doubleFilter('radius_km'),
        );

        final filtered = widget.onlyFavorites ? _applyVehicleFavorites(items) : items;

        if (!mounted) return;
        setState(() {
          _vehicles
            ..clear()
            ..addAll(filtered);
          _page = 1;
          _hasMore = items.length == _limit;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loadingFirstPage = false);
    }
  }

  Future<void> _fetchMore() async {
    if (_loadingMore || _loadingFirstPage || !_hasMore) return;

    setState(() {
      _loadingMore = true;
      _error = null;
    });

    try {
      final nextPage = _page + 1;
      final f = _filterToQuery();

      if (widget.onlyFavorites) {
        if (widget.selectedView == 0) {
          if (!mounted) return;
          setState(() => _hasMore = false);
          return;
        }

        final currentUser = context.read<UserProvider>().user;
        if (currentUser == null) {
          if (!mounted) return;
          setState(() => _hasMore = false);
          return;
        }

        final res = await _favoriteVehicleService.myFavorites(
          currentUser,
          page: nextPage,
          limit: _limit,
        );
        final raw = (res['items'] as List?) ?? const [];
        final total = (res['total'] is num) ? (res['total'] as num).toInt() : 0;
        final items = raw
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .map(_extractVehicleMap)
            .whereType<Map<String, dynamic>>()
            .map(vmodel.VehicleListing.fromJson)
            .where((e) => _matchesVehicleFilters(e, f.isListed))
            .toList();

        if (!mounted) return;
        setState(() {
          _vehicles.addAll(items);
          _page = nextPage;
          _hasMore = (nextPage * _limit) < total;
        });
        return;
      }

      if (widget.selectedView == 0) {
        final items = await _propertyService.getAll(
          page: nextPage,
          limit: _limit,
          q: widget.q.trim().isEmpty ? null : widget.q.trim(),
          categoryId: widget.categoryId,
          userId: widget.userId,
          isListed: f.isListed,
          sortBy: f.sortBy,
          sortDir: f.sortDir,
          onSale: _boolFilter('on_sale'),
          isRent: _boolFilter('is_rent'),
          agentType: _strFilter('agent_type'),
          bedroomsMin: _intFilter('bedrooms_min'),
          bedroomsMax: _intFilter('bedrooms_max'),
          bathroomsMin: _intFilter('bathrooms_min'),
          bathroomsMax: _intFilter('bathrooms_max'),
          spaceMin: _intFilter('space_min'),
          spaceMax: _intFilter('space_max'),
          lat: _doubleFilter('lat'),
          lng: _doubleFilter('lng'),
          radiusKm: _doubleFilter('radius_km'),
        );

        final filtered = widget.onlyFavorites
            ? _applyPropertyFavorites(items)
            : items;

        if (!mounted) return;
        setState(() {
          _properties.addAll(filtered);
          _page = nextPage;
          _hasMore = items.length == _limit;
        });
      } else {
        final items = await _vehicleService.getAll(
          page: nextPage,
          limit: _limit,
          q: widget.q.trim().isEmpty ? null : widget.q.trim(),
          categoryId: widget.categoryId,
          userId: widget.userId,
          isListed: f.isListed,
          sortBy: f.sortBy,
          sortDir: f.sortDir,
          onSale: _boolFilter('on_sale'),
          condition: _strFilter('condition'),
          brand: _strFilter('brand'),
          model: _strFilter('model'),
          fuelType: _strFilter('fuel_type'),
          transmissionType: _strFilter('transmission_type'),
          bodyType: _strFilter('body_type'),
          paymentOption: _strFilter('payment_option'),
          yearMin: _intFilter('year_min'),
          yearMax: _intFilter('year_max'),
          kmMin: _intFilter('km_min'),
          kmMax: _intFilter('km_max'),
          lat: _doubleFilter('lat'),
          lng: _doubleFilter('lng'),
          radiusKm: _doubleFilter('radius_km'),
        );

        final filtered = widget.onlyFavorites ? _applyVehicleFavorites(items) : items;

        if (!mounted) return;
        setState(() {
          _vehicles.addAll(filtered);
          _page = nextPage;
          _hasMore = items.length == _limit;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  List<vmodel.VehicleListing> _applyVehicleFavorites(
    List<vmodel.VehicleListing> items,
  ) {
    return items;
  }

  List<pmodel.PropertyListing> _applyPropertyFavorites(
    List<pmodel.PropertyListing> items,
  ) {
    return items;
  }

  Map<String, dynamic>? _extractVehicleMap(Map<String, dynamic> raw) {
    final direct = raw['vehicle_id'];
    if (direct is Map<String, dynamic>) return direct;
    if (direct is Map) return Map<String, dynamic>.from(direct);
    if (raw.containsKey('name') && raw.containsKey('images')) return raw;
    return null;
  }

  String? _strFilter(String key) {
    final v = widget.extraFilters[key];
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  int? _intFilter(String key) {
    final v = widget.extraFilters[key];
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString().trim());
  }

  double? _doubleFilter(String key) {
    final v = widget.extraFilters[key];
    if (v == null) return null;
    if (v is double) return v;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString().trim());
  }

  bool? _boolFilter(String key) {
    final v = widget.extraFilters[key];
    if (v is bool) return v;
    if (v == null) return null;
    final s = v.toString().toLowerCase().trim();
    if (s == 'true') return true;
    if (s == 'false') return false;
    return null;
  }

  bool _matchesVehicleFilters(vmodel.VehicleListing item, bool? isListed) {
    final q = widget.q.trim().toLowerCase();
    final qOk = q.isEmpty ||
        item.name.toLowerCase().contains(q) ||
        item.description.toLowerCase().contains(q) ||
        item.brand.toLowerCase().contains(q) ||
        item.model.toLowerCase().contains(q);
    final categoryOk =
        widget.categoryId == null || widget.categoryId == item.categoryId;
    final listedOk = isListed == null || item.isListed == isListed;
    return qOk && categoryOk && listedOk;
  }

  bool _matchesPropertyFilters(pmodel.PropertyListing item, bool? isListed) {
    final q = widget.q.trim().toLowerCase();
    final qOk = q.isEmpty ||
        item.name.toLowerCase().contains(q) ||
        item.description.toLowerCase().contains(q);
    final categoryOk =
        widget.categoryId == null || widget.categoryId == item.categoryId;
    final listedOk = isListed == null || item.isListed == isListed;
    return qOk && categoryOk && listedOk;
  }

  Map<String, dynamic> _toPropertyCardMap(pmodel.PropertyListing listing) {
    return {
      '_id': listing.id,
      'name': listing.name,
      'images': listing.images,
      'price': listing.price,
      'description': listing.description,
      'category': listing.categoryTitle ?? '',
      'coords': listing.coords,
      'bedrooms': listing.bedrooms,
      'bathrooms': listing.bathrooms,
      'space': listing.space,
      'extra_features': listing.extraFeatures,
      'is_featured': listing.isFeatured,
      'is_sponsored': listing.isSponsored,
      'on_sale': listing.onSale,
      'is_listed': listing.isListed,
      'owner_id': {
        '_id': listing.userId,
        'full_name': listing.userName ?? 'Unknown',
        'email': listing.userEmail ?? '',
        'phone': listing.userPhone ?? '',
        'profile_picture': listing.userProfilePicture ?? '',
      },
      'createdAt': listing.createdAt?.toIso8601String(),
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingFirstPage) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Failed to load listings:\n$_error",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _fetchFirstPage, child: const Text("Retry")),
            ],
          ),
        ),
      );
    }

    final isPropertyView = widget.selectedView == 0;
    final itemCount = isPropertyView ? _properties.length : _vehicles.length;

    if (itemCount == 0) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'No current listings',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.separated(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: itemCount + 1,
      separatorBuilder: (_, __) => const SizedBox(height: 24),
      itemBuilder: (context, index) {
        if (index == itemCount) {
          if (!_hasMore) return const SizedBox(height: 8);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Center(
              child: _loadingMore
                  ? const CircularProgressIndicator()
                  : TextButton(onPressed: _fetchMore, child: const Text("Load more")),
            ),
          );
        }

        if (isPropertyView) {
          final listing = _properties[index];
          return p.PropertyListing(
            property: _toPropertyCardMap(listing),
            isDealerProfile: widget.isDealerProfile,
            isUploaderViewing: widget.isUploaderViewing,
          );
        }

        final listing = _vehicles[index];
        return v.VehicleListing(
          vehicle: listing,
          isDealerProfile: widget.isDealerProfile,
          isUploaderViewing: widget.isUploaderViewing,
        );
      },
    );
  }
}
