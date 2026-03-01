import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:xdeal/models/property_category.dart';
import 'package:xdeal/models/vehicle_category.dart';
import 'package:xdeal/screens/map_picker_screen.dart';
import 'package:xdeal/screens/property_viewer_screen.dart';
import 'package:xdeal/screens/vehicle_viewer_screen.dart';
import 'package:xdeal/services/api_client.dart';
import 'package:xdeal/services/property_category_service.dart';
import 'package:xdeal/services/property_listing_service.dart';
import 'package:xdeal/services/vehicle_category_service.dart';
import 'package:xdeal/services/vehicle_listing_service.dart';
import 'package:xdeal/utils/app_colors.dart';

class UserViewListingModal extends StatefulWidget {
  final int listingType; // 0 property, 1 vehicle
  final String listingId;
  const UserViewListingModal({
    super.key,
    required this.listingType,
    required this.listingId,
  });

  @override
  State<UserViewListingModal> createState() => _UserViewListingModalState();
}

class _UserViewListingModalState extends State<UserViewListingModal> {
  late final ApiClient _api;
  late final PropertyListingService _propertyService;
  late final VehicleListingService _vehicleService;
  late final PropertyCategoryService _propertyCategoryService;
  late final VehicleCategoryService _vehicleCategoryService;

  Map<String, dynamic>? _listing;
  bool _loading = true;
  bool _busy = false;
  bool _loadingCategories = false;
  String? _error;
  List<PropertyCategory> _propertyCategories = [];
  List<VehicleCategory> _vehicleCategories = [];

  bool get _isProperty => widget.listingType == 0;
  bool get _isListed => (_listing?['is_listed'] as bool?) ?? false;

  @override
  void initState() {
    super.initState();
    _api = ApiClient(baseUrl: 'https://xdeal.beproagency.com');
    _propertyService = PropertyListingService(_api);
    _vehicleService = VehicleListingService(_api);
    _propertyCategoryService = PropertyCategoryService(_api);
    _vehicleCategoryService = VehicleCategoryService(_api);
    _loadListing();
  }

  List<String> _asStringList(dynamic raw) {
    if (raw is List) {
      return raw.map((e) => e.toString()).toList();
    }
    return <String>[];
  }

  double _toDouble(dynamic v, {double fallback = 0}) {
    if (v == null) return fallback;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? fallback;
  }

  Future<void> _loadListing() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (_isProperty) {
        final item = await _propertyService.getById(widget.listingId);
        _listing = {
          '_id': item.id,
          'name': item.name,
          'price': item.price,
          'description': item.description,
          'category': item.categoryId,
          'coords': item.coords,
          'bedrooms': item.bedrooms,
          'bathrooms': item.bathrooms,
          'space': item.space,
          'extra_features': item.extraFeatures,
          'three_sixty': item.threeSixty,
          'agent_type': item.agentType,
          'is_rent': item.isRent,
          'rental_payment': item.rentalPayment,
          'on_sale': item.onSale,
          'is_listed': item.isListed,
        };
      } else {
        final item = await _vehicleService.getById(widget.listingId);
        _listing = {
          '_id': item.id,
          'name': item.name,
          'price': item.price,
          'description': item.description,
          'category': item.categoryId,
          'coords': item.coords,
          'listing_type': item.listingType,
          'brand': item.brand,
          'model': item.model,
          'version': item.version,
          'condition': item.condition,
          'kilometers': item.kilometers,
          'year': item.year,
          'fuel_type': item.fuelType,
          'transmission_type': item.transmissionType,
          'body_type': item.bodyType,
          'air_conditioning': item.airConditioning,
          'color': item.color,
          'number_of_seats': item.numberOfSeats,
          'number_of_doors': item.numberOfDoors,
          'interior': item.interior,
          'accessory_type': item.accessoryType,
          'compatibility': item.compatibility,
          'warranty_months': item.warrantyMonths,
          'payment_option': item.paymentOption,
          'extra_features': item.extraFeatures,
          'on_sale': item.onSale,
          'is_listed': item.isListed,
        };
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadCategoriesForEdit() async {
    if (_loadingCategories) return;
    if (_isProperty && _propertyCategories.isNotEmpty) return;
    if (!_isProperty && _vehicleCategories.isNotEmpty) return;

    setState(() => _loadingCategories = true);
    try {
      if (_isProperty) {
        _propertyCategories = await _propertyCategoryService.getAll(limit: 200);
      } else {
        _vehicleCategories = await _vehicleCategoryService.getAll(limit: 200);
      }
    } catch (_) {
      // keep edit form usable even without categories
    } finally {
      if (mounted) setState(() => _loadingCategories = false);
    }
  }

  Future<void> _toggleListed() async {
    if (_listing == null || _busy) return;
    setState(() => _busy = true);
    try {
      final next = !_isListed;
      if (_isProperty) {
        await _propertyService.update(widget.listingId, {'is_listed': next});
      } else {
        await _vehicleService.update(widget.listingId, {'is_listed': next});
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed: $e')));
      setState(() => _busy = false);
    }
  }

  Future<void> _deleteListing() async {
    if (_busy) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete listing?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _busy = true);
    try {
      if (_isProperty) {
        await _propertyService.delete(widget.listingId);
      } else {
        await _vehicleService.delete(widget.listingId);
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed: $e')));
      setState(() => _busy = false);
    }
  }

  Future<void> _editListing() async {
    if (_listing == null || _busy) return;
    await _loadCategoriesForEdit();
    if (!mounted) return;

    final formKey = GlobalKey<FormState>();
    final coords = (_listing!['coords'] is List)
        ? (_listing!['coords'] as List)
        : const [];

    final nameCtrl = TextEditingController(
      text: (_listing!['name'] ?? '').toString(),
    );
    final priceCtrl = TextEditingController(
      text: (_listing!['price'] ?? '').toString(),
    );
    final descCtrl = TextEditingController(
      text: (_listing!['description'] ?? '').toString(),
    );
    List<double> selectedCoords = coords.length > 1
        ? [_toDouble(coords[0]), _toDouble(coords[1])]
        : <double>[33.8938, 35.5018];
    String selectedLocationLabel =
        '${selectedCoords[0].toStringAsFixed(6)}, ${selectedCoords[1].toStringAsFixed(6)}';
    String? categoryId = (_listing!['category'] ?? '').toString();

    final bedroomsCtrl = TextEditingController(
      text: _toDouble(_listing!['bedrooms']).toString(),
    );
    final bathroomsCtrl = TextEditingController(
      text: _toDouble(_listing!['bathrooms']).toString(),
    );
    final spaceCtrl = TextEditingController(
      text: _toDouble(_listing!['space']).toString(),
    );
    final threeSixtyCtrl = TextEditingController(
      text: (_listing!['three_sixty'] ?? '').toString(),
    );
    final propertyFeaturesCtrl = TextEditingController(
      text: _asStringList(_listing!['extra_features']).join(', '),
    );
    String agentType = (_listing!['agent_type'] ?? 'owner').toString();
    bool isRent = (_listing!['is_rent'] as bool?) ?? false;
    String? rentalPayment = (_listing!['rental_payment'] as String?);

    String listingType = (_listing!['listing_type'] ?? 'vehicle').toString();
    final brandCtrl = TextEditingController(
      text: (_listing!['brand'] ?? '').toString(),
    );
    final modelCtrl = TextEditingController(
      text: (_listing!['model'] ?? '').toString(),
    );
    final versionCtrl = TextEditingController(
      text: (_listing!['version'] ?? '').toString(),
    );
    final kilometersCtrl = TextEditingController(
      text: _toDouble(_listing!['kilometers']).toString(),
    );
    final yearCtrl = TextEditingController(
      text: (_listing!['year'] ?? '').toString(),
    );
    final seatsCtrl = TextEditingController(
      text: _toDouble(_listing!['number_of_seats']).toString(),
    );
    final doorsCtrl = TextEditingController(
      text: _toDouble(_listing!['number_of_doors']).toString(),
    );
    final warrantyCtrl = TextEditingController(
      text: (_listing!['warranty_months'] ?? '').toString(),
    );
    final accessoryTypeCtrl = TextEditingController(
      text: (_listing!['accessory_type'] ?? '').toString(),
    );
    final compatibilityCtrl = TextEditingController(
      text: _asStringList(_listing!['compatibility']).join(', '),
    );
    final vehicleFeaturesCtrl = TextEditingController(
      text: _asStringList(_listing!['extra_features']).join(', '),
    );
    String condition = (_listing!['condition'] ?? 'new').toString();
    String fuelType = (_listing!['fuel_type'] ?? 'petrol').toString();
    String transmission = (_listing!['transmission_type'] ?? 'manual')
        .toString();
    String bodyType = (_listing!['body_type'] ?? 'SUV').toString();
    String airConditioning = (_listing!['air_conditioning'] ?? 'manual')
        .toString();
    String color = (_listing!['color'] ?? 'Black').toString();
    String interior = (_listing!['interior'] ?? 'cloth').toString();
    String paymentOption = (_listing!['payment_option'] ?? 'cash').toString();

    bool accessoryMode() {
      if (listingType == 'accessory') return true;
      final match = _vehicleCategories.where((c) => c.id == categoryId);
      if (match.isNotEmpty) {
        return match.first.title.toLowerCase().contains('accessor');
      }
      return false;
    }

    final apply = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          child: SafeArea(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 560,
                maxHeight: MediaQuery.of(context).size.height * 0.88,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Edit Listing',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: Form(
                        key: formKey,
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 12.0,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextFormField(
                                  controller: nameCtrl,
                                  decoration: const InputDecoration(
                                    labelText: 'Title',
                                  ),
                                  validator: (v) =>
                                      (v == null || v.trim().isEmpty)
                                      ? 'Title is required'
                                      : null,
                                ),
                                TextFormField(
                                  controller: priceCtrl,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Price',
                                  ),
                                  validator: (v) =>
                                      (v == null || v.trim().isEmpty)
                                      ? 'Price is required'
                                      : null,
                                ),
                                TextFormField(
                                  controller: descCtrl,
                                  minLines: 3,
                                  maxLines: 5,
                                  decoration: const InputDecoration(
                                    labelText: 'Description',
                                  ),
                                  validator: (v) =>
                                      (v == null || v.trim().isEmpty)
                                      ? 'Description is required'
                                      : null,
                                ),
                                if (_isProperty) ...[
                                  DropdownButtonFormField<String>(
                                    initialValue: categoryId,
                                    decoration: const InputDecoration(
                                      labelText: 'Category',
                                    ),
                                    items: _propertyCategories
                                        .map(
                                          (c) => DropdownMenuItem<String>(
                                            value: c.id,
                                            child: Text(c.title),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (v) =>
                                        setDialogState(() => categoryId = v),
                                  ),
                                  TextFormField(
                                    controller: bedroomsCtrl,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'Bedrooms',
                                    ),
                                    validator: (v) =>
                                        (v == null || v.trim().isEmpty)
                                        ? 'Bedrooms is required'
                                        : null,
                                  ),
                                  TextFormField(
                                    controller: bathroomsCtrl,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'Bathrooms',
                                    ),
                                    validator: (v) =>
                                        (v == null || v.trim().isEmpty)
                                        ? 'Bathrooms is required'
                                        : null,
                                  ),
                                  TextFormField(
                                    controller: spaceCtrl,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'Space (m²)',
                                    ),
                                    validator: (v) =>
                                        (v == null || v.trim().isEmpty)
                                        ? 'Space is required'
                                        : null,
                                  ),
                                  DropdownButtonFormField<String>(
                                    initialValue: agentType,
                                    decoration: const InputDecoration(
                                      labelText: 'Agent Type',
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'owner',
                                        child: Text('Owner'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'middleman',
                                        child: Text('Middleman'),
                                      ),
                                    ],
                                    onChanged: (v) {
                                      if (v != null)
                                        setDialogState(() => agentType = v);
                                    },
                                  ),
                                  SwitchListTile(
                                    value: isRent,
                                    contentPadding: EdgeInsets.zero,
                                    title: const Text('For Rent'),
                                    onChanged: (v) => setDialogState(() {
                                      isRent = v;
                                      if (!isRent) rentalPayment = null;
                                    }),
                                  ),
                                  if (isRent)
                                    DropdownButtonFormField<String>(
                                      initialValue: rentalPayment,
                                      decoration: const InputDecoration(
                                        labelText: 'Rental Payment',
                                      ),
                                      items: const [
                                        DropdownMenuItem(
                                          value: 'daily',
                                          child: Text('Daily'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'monthly',
                                          child: Text('Monthly'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'yearly',
                                          child: Text('Yearly'),
                                        ),
                                      ],
                                      onChanged: (v) => setDialogState(
                                        () => rentalPayment = v,
                                      ),
                                      validator: (v) =>
                                          (isRent && (v == null || v.isEmpty))
                                          ? 'Rental payment is required'
                                          : null,
                                    ),
                                  TextFormField(
                                    controller: threeSixtyCtrl,
                                    decoration: const InputDecoration(
                                      labelText: '360 URL (optional)',
                                    ),
                                  ),
                                  TextFormField(
                                    controller: propertyFeaturesCtrl,
                                    decoration: const InputDecoration(
                                      labelText:
                                          'Extra Features (comma separated)',
                                    ),
                                  ),
                                ] else ...[
                                  DropdownButtonFormField<String>(
                                    initialValue: categoryId,
                                    decoration: const InputDecoration(
                                      labelText: 'Category',
                                    ),
                                    items: _vehicleCategories
                                        .map(
                                          (c) => DropdownMenuItem<String>(
                                            value: c.id,
                                            child: Text(c.title),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (v) => setDialogState(() {
                                      categoryId = v;
                                      if (accessoryMode())
                                        listingType = 'accessory';
                                    }),
                                  ),
                                  SwitchListTile(
                                    value: accessoryMode(),
                                    contentPadding: EdgeInsets.zero,
                                    title: const Text('Accessory Listing'),
                                    onChanged: (v) => setDialogState(
                                      () => listingType = v
                                          ? 'accessory'
                                          : 'vehicle',
                                    ),
                                  ),
                                  DropdownButtonFormField<String>(
                                    initialValue: condition,
                                    decoration: const InputDecoration(
                                      labelText: 'Condition',
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'new',
                                        child: Text('New'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'used',
                                        child: Text('Used'),
                                      ),
                                    ],
                                    onChanged: (v) {
                                      if (v != null)
                                        setDialogState(() => condition = v);
                                    },
                                  ),
                                  if (accessoryMode()) ...[
                                    TextFormField(
                                      controller: accessoryTypeCtrl,
                                      decoration: const InputDecoration(
                                        labelText: 'Accessory Type',
                                      ),
                                      validator: (v) =>
                                          (v == null || v.trim().isEmpty)
                                          ? 'Accessory type is required'
                                          : null,
                                    ),
                                    TextFormField(
                                      controller: compatibilityCtrl,
                                      decoration: const InputDecoration(
                                        labelText:
                                            'Compatibility (comma separated)',
                                      ),
                                    ),
                                    TextFormField(
                                      controller: warrantyCtrl,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        labelText: 'Warranty (months)',
                                      ),
                                    ),
                                  ] else ...[
                                    TextFormField(
                                      controller: brandCtrl,
                                      decoration: const InputDecoration(
                                        labelText: 'Brand',
                                      ),
                                      validator: (v) =>
                                          (v == null || v.trim().isEmpty)
                                          ? 'Brand is required'
                                          : null,
                                    ),
                                    TextFormField(
                                      controller: modelCtrl,
                                      decoration: const InputDecoration(
                                        labelText: 'Model',
                                      ),
                                      validator: (v) =>
                                          (v == null || v.trim().isEmpty)
                                          ? 'Model is required'
                                          : null,
                                    ),
                                    TextFormField(
                                      controller: versionCtrl,
                                      decoration: const InputDecoration(
                                        labelText: 'Version (optional)',
                                      ),
                                    ),
                                    TextFormField(
                                      controller: kilometersCtrl,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        labelText: 'Kilometers',
                                      ),
                                      validator: (v) =>
                                          (v == null || v.trim().isEmpty)
                                          ? 'Kilometers is required'
                                          : null,
                                    ),
                                    TextFormField(
                                      controller: yearCtrl,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        labelText: 'Year',
                                      ),
                                      validator: (v) =>
                                          (v == null || v.trim().isEmpty)
                                          ? 'Year is required'
                                          : null,
                                    ),
                                    DropdownButtonFormField<String>(
                                      initialValue: fuelType,
                                      decoration: const InputDecoration(
                                        labelText: 'Fuel Type',
                                      ),
                                      items: const [
                                        DropdownMenuItem(
                                          value: 'petrol',
                                          child: Text('Petrol'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'diesel',
                                          child: Text('Diesel'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'electric',
                                          child: Text('Electric'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'hybrid',
                                          child: Text('Hybrid'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'gas',
                                          child: Text('Gas'),
                                        ),
                                      ],
                                      onChanged: (v) {
                                        if (v != null)
                                          setDialogState(() => fuelType = v);
                                      },
                                    ),
                                    DropdownButtonFormField<String>(
                                      initialValue: transmission,
                                      decoration: const InputDecoration(
                                        labelText: 'Transmission',
                                      ),
                                      items: const [
                                        DropdownMenuItem(
                                          value: 'manual',
                                          child: Text('Manual'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'automatic',
                                          child: Text('Automatic'),
                                        ),
                                      ],
                                      onChanged: (v) {
                                        if (v != null)
                                          setDialogState(
                                            () => transmission = v,
                                          );
                                      },
                                    ),
                                    DropdownButtonFormField<String>(
                                      initialValue: bodyType,
                                      decoration: const InputDecoration(
                                        labelText: 'Body Type',
                                      ),
                                      items: const [
                                        DropdownMenuItem(
                                          value: 'SUV',
                                          child: Text('SUV'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'Sedan',
                                          child: Text('Sedan'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'Pickup',
                                          child: Text('Pickup'),
                                        ),
                                      ],
                                      onChanged: (v) {
                                        if (v != null)
                                          setDialogState(() => bodyType = v);
                                      },
                                    ),
                                    DropdownButtonFormField<String>(
                                      initialValue: airConditioning,
                                      decoration: const InputDecoration(
                                        labelText: 'Air Conditioning',
                                      ),
                                      items: const [
                                        DropdownMenuItem(
                                          value: 'manual',
                                          child: Text('Manual'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'automatic',
                                          child: Text('Automatic'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'none',
                                          child: Text('None'),
                                        ),
                                      ],
                                      onChanged: (v) {
                                        if (v != null)
                                          setDialogState(
                                            () => airConditioning = v,
                                          );
                                      },
                                    ),
                                    TextFormField(
                                      initialValue: color,
                                      decoration: const InputDecoration(
                                        labelText: 'Color',
                                      ),
                                      onChanged: (v) => color = v,
                                    ),
                                    TextFormField(
                                      initialValue: interior,
                                      decoration: const InputDecoration(
                                        labelText: 'Interior',
                                      ),
                                      onChanged: (v) => interior = v,
                                    ),
                                    TextFormField(
                                      controller: seatsCtrl,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        labelText: 'Number of Seats',
                                      ),
                                    ),
                                    TextFormField(
                                      controller: doorsCtrl,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        labelText: 'Number of Doors',
                                      ),
                                    ),
                                  ],
                                  DropdownButtonFormField<String>(
                                    initialValue: paymentOption,
                                    decoration: const InputDecoration(
                                      labelText: 'Payment Option',
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'cash',
                                        child: Text('Cash'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'installment',
                                        child: Text('Installment'),
                                      ),
                                    ],
                                    onChanged: (v) {
                                      if (v != null)
                                        setDialogState(() => paymentOption = v);
                                    },
                                  ),
                                  TextFormField(
                                    controller: vehicleFeaturesCtrl,
                                    decoration: const InputDecoration(
                                      labelText:
                                          'Extra Features (comma separated)',
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 8),
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: const Icon(
                                    Icons.location_on_outlined,
                                  ),
                                  title: const Text('Location'),
                                  subtitle: Text(
                                    selectedLocationLabel,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: TextButton(
                                    onPressed: () async {
                                      final picked = await Navigator.of(context)
                                          .push<MapPickResult>(
                                            MaterialPageRoute(
                                              builder: (_) => MapPickerScreen(
                                                initial: LatLng(
                                                  selectedCoords[0],
                                                  selectedCoords[1],
                                                ),
                                              ),
                                            ),
                                          );
                                      if (picked == null) return;
                                      setDialogState(() {
                                        selectedCoords = [
                                          picked.latLng.latitude,
                                          picked.latLng.longitude,
                                        ];
                                        selectedLocationLabel = picked.address;
                                      });
                                    },
                                    child: const Text('Pick'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState?.validate() != true)
                              return;
                            Navigator.pop(context, true);
                          },
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final nextName = nameCtrl.text.trim();
    final nextPrice = priceCtrl.text.trim();
    final nextDesc = descCtrl.text.trim();

    Future<void> disposeControllersSafely() async {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      nameCtrl.dispose();
      priceCtrl.dispose();
      descCtrl.dispose();
      bedroomsCtrl.dispose();
      bathroomsCtrl.dispose();
      spaceCtrl.dispose();
      threeSixtyCtrl.dispose();
      propertyFeaturesCtrl.dispose();
      brandCtrl.dispose();
      modelCtrl.dispose();
      versionCtrl.dispose();
      kilometersCtrl.dispose();
      yearCtrl.dispose();
      seatsCtrl.dispose();
      doorsCtrl.dispose();
      warrantyCtrl.dispose();
      accessoryTypeCtrl.dispose();
      compatibilityCtrl.dispose();
      vehicleFeaturesCtrl.dispose();
    }

    if (apply != true) {
      await disposeControllersSafely();
      return;
    }

    setState(() => _busy = true);
    try {
      final patch = <String, dynamic>{
        'name': nextName,
        'price': nextPrice,
        'description': nextDesc,
        if (categoryId != null && categoryId!.isNotEmpty)
          'category': categoryId,
        'coords': selectedCoords,
      };

      if (_isProperty) {
        patch.addAll({
          'bedrooms': double.tryParse(bedroomsCtrl.text.trim()) ?? 0,
          'bathrooms': double.tryParse(bathroomsCtrl.text.trim()) ?? 0,
          'space': double.tryParse(spaceCtrl.text.trim()) ?? 0,
          'agent_type': agentType,
          'is_rent': isRent,
          'rental_payment': isRent ? rentalPayment : null,
          'three_sixty': threeSixtyCtrl.text.trim().isEmpty
              ? null
              : threeSixtyCtrl.text.trim(),
          'extra_features': propertyFeaturesCtrl.text
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList(),
        });
        await _propertyService.update(widget.listingId, patch);
      } else {
        final isAccessory = accessoryMode();
        patch.addAll({
          'listing_type': isAccessory ? 'accessory' : 'vehicle',
          'condition': condition,
          'payment_option': paymentOption,
          'extra_features': vehicleFeaturesCtrl.text
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList(),
        });

        if (isAccessory) {
          patch.addAll({
            'accessory_type': accessoryTypeCtrl.text.trim(),
            'compatibility': compatibilityCtrl.text
                .split(',')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList(),
            'warranty_months': int.tryParse(warrantyCtrl.text.trim()),
          });
        } else {
          patch.addAll({
            'brand': brandCtrl.text.trim(),
            'model': modelCtrl.text.trim(),
            'version': versionCtrl.text.trim().isEmpty
                ? null
                : versionCtrl.text.trim(),
            'kilometers': double.tryParse(kilometersCtrl.text.trim()) ?? 0,
            'year': yearCtrl.text.trim(),
            'fuel_type': fuelType,
            'transmission_type': transmission,
            'body_type': bodyType,
            'air_conditioning': airConditioning,
            'color': color.trim(),
            'number_of_seats': double.tryParse(seatsCtrl.text.trim()) ?? 0,
            'number_of_doors': double.tryParse(doorsCtrl.text.trim()) ?? 0,
            'interior': interior.trim(),
          });
        }

        await _vehicleService.update(widget.listingId, patch);
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed: $e')));
      setState(() => _busy = false);
    } finally {
      await disposeControllersSafely();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(
        height: 320,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _listing == null) {
      return SizedBox(
        height: 320,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(_error ?? 'Failed to load listing'),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            (_listing!['name'] ?? '').toString(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 44),
              backgroundColor: AppColors.inputBg,
            ),
            onPressed: _busy
                ? null
                : () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => _isProperty
                            ? PropertyViewerScreen(propertyId: widget.listingId)
                            : VehicleViewerScreen(vehicleId: widget.listingId),
                      ),
                    );
                  },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.remove_red_eye_outlined, color: Colors.black),
                SizedBox(width: 6),
                Text("View Listing", style: TextStyle(color: Colors.black)),
              ],
            ),
          ),
          const SizedBox(height: 6),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 44),
              backgroundColor: AppColors.inputBg,
            ),
            onPressed: _busy ? null : _editListing,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.edit_outlined, color: Colors.black),
                SizedBox(width: 6),
                Text("Edit Listing", style: TextStyle(color: Colors.black)),
              ],
            ),
          ),
          const SizedBox(height: 6),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 44),
              backgroundColor: AppColors.inputBg,
            ),
            onPressed: _busy ? null : _toggleListed,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isListed
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.black,
                ),
                const SizedBox(width: 6),
                Text(
                  _isListed ? "Mark as Not Listed" : "Mark as Listed",
                  style: const TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 44),
              backgroundColor: AppColors.inputBg,
            ),
            onPressed: _busy ? null : _deleteListing,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.delete_outlined, color: Colors.red),
                SizedBox(width: 6),
                Text("Delete Listing", style: TextStyle(color: Colors.black)),
              ],
            ),
          ),
          if (_busy) ...[
            const SizedBox(height: 12),
            const CircularProgressIndicator(),
          ],
        ],
      ),
    );
  }
}
