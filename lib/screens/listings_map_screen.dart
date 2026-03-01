import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:xdeal/models/property_listing.dart' as pmodel;
import 'package:xdeal/models/vehicle_listing.dart' as vmodel;
import 'package:xdeal/localization/app_localizations.dart';
import 'package:xdeal/screens/property_viewer_screen.dart';
import 'package:xdeal/screens/vehicle_viewer_screen.dart';
import 'package:xdeal/services/api_client.dart';
import 'package:xdeal/services/property_listing_service.dart';
import 'package:xdeal/services/vehicle_listing_service.dart';
import 'package:xdeal/utils/app_colors.dart';

class ListingsMapScreen extends StatefulWidget {
  final int selectedView; // 0 properties, 1 vehicles
  final String q;
  final String? categoryId;
  final Map<String, dynamic> extraFilters;

  const ListingsMapScreen({
    super.key,
    required this.selectedView,
    required this.q,
    required this.categoryId,
    this.extraFilters = const {},
  });

  @override
  State<ListingsMapScreen> createState() => _ListingsMapScreenState();
}

class _ListingsMapScreenState extends State<ListingsMapScreen> {
  late final ApiClient _api;
  late final PropertyListingService _propertyService;
  late final VehicleListingService _vehicleService;

  final List<pmodel.PropertyListing> _properties = [];
  final List<vmodel.VehicleListing> _vehicles = [];

  bool _loading = true;
  String? _error;
  Set<Marker> _markers = {};
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _api = ApiClient(baseUrl: 'https://xdeal.beproagency.com');
    _propertyService = PropertyListingService(_api);
    _vehicleService = VehicleListingService(_api);
    _fetchListings();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
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
    if (v == null) return null;
    if (v is bool) return v;
    final s = v.toString().toLowerCase().trim();
    if (s == 'true') return true;
    if (s == 'false') return false;
    return null;
  }

  String? _strFilter(String key) {
    final v = widget.extraFilters[key];
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  bool _validCoords(List<double> coords) {
    return coords.length == 2 &&
        coords[0] >= -90 &&
        coords[0] <= 90 &&
        coords[1] >= -180 &&
        coords[1] <= 180;
  }

  Future<void> _fetchListings() async {
    setState(() {
      _loading = true;
      _error = null;
      _markers = {};
      _properties.clear();
      _vehicles.clear();
    });

    try {
      if (widget.selectedView == 0) {
        final items = await _propertyService.getAll(
          page: 1,
          limit: 200,
          q: widget.q.trim().isEmpty ? null : widget.q.trim(),
          categoryId: widget.categoryId,
          isListed: true,
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
        _properties.addAll(items.where((e) => _validCoords(e.coords)));
        _markers = _properties
            .map(
              (e) => Marker(
                markerId: MarkerId('p_${e.id}'),
                position: LatLng(e.coords[0], e.coords[1]),
                infoWindow: InfoWindow(title: e.name),
                onTap: () => _showPropertyDetails(e),
              ),
            )
            .toSet();
      } else {
        final items = await _vehicleService.getAll(
          page: 1,
          limit: 200,
          q: widget.q.trim().isEmpty ? null : widget.q.trim(),
          categoryId: widget.categoryId,
          isListed: true,
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
        _vehicles.addAll(items.where((e) => _validCoords(e.coords)));
        _markers = _vehicles
            .map(
              (e) => Marker(
                markerId: MarkerId('v_${e.id}'),
                position: LatLng(e.coords[0], e.coords[1]),
                infoWindow: InfoWindow(title: e.name),
                onTap: () => _showVehicleDetails(e),
              ),
            )
            .toSet();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) {
        setState(() => _loading = false);
        _fitAllMarkers();
      }
    }
  }

  Future<void> _fitAllMarkers() async {
    if (_markers.isEmpty || _mapController == null) return;
    if (_markers.length == 1) {
      final p = _markers.first.position;
      await _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(p.latitude, p.longitude), 13),
      );
      return;
    }

    double minLat = _markers.first.position.latitude;
    double maxLat = minLat;
    double minLng = _markers.first.position.longitude;
    double maxLng = minLng;

    for (final m in _markers) {
      final lat = m.position.latitude;
      final lng = m.position.longitude;
      if (lat < minLat) minLat = lat;
      if (lat > maxLat) maxLat = lat;
      if (lng < minLng) minLng = lng;
      if (lng > maxLng) maxLng = lng;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
    await _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 56),
    );
  }

  void _showPropertyDetails(pmodel.PropertyListing listing) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              listing.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text('${context.tr('USD')} ${listing.price}'),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.of(this.context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          PropertyViewerScreen(propertyId: listing.id),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: Text(context.tr('Open Listing')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showVehicleDetails(vmodel.VehicleListing listing) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              listing.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text('${context.tr('USD')} ${listing.price}'),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.of(this.context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          VehicleViewerScreen(vehicleId: listing.id),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: Text(context.tr('Open Listing')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fallback = widget.selectedView == 0
        ? const LatLng(33.8938, 35.5018)
        : const LatLng(33.8938, 35.5018);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.selectedView == 0
              ? context.tr('Properties Map')
              : context.tr('Vehicles Map'),
        ),
        backgroundColor: AppColors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${context.tr('Failed to load listings map:')}\n$_error',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _fetchListings,
                        child: Text(context.tr('Retry')),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: fallback,
                    zoom: 11,
                  ),
                  markers: _markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  onMapCreated: (c) {
                    _mapController = c;
                    _fitAllMarkers();
                  },
                ),
                Positioned(
                  left: 12,
                  right: 12,
                  top: 12,
                  child: Material(
                    borderRadius: BorderRadius.circular(10),
                    elevation: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _markers.isEmpty
                            ? context.tr(
                                'No listings with valid location found.',
                              )
                            : '${_markers.length} ${context.tr('listings found on map')}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
