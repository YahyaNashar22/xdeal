import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:xdeal/models/vehicle_category.dart';
import 'package:xdeal/screens/map_picker_screen.dart';
import 'package:xdeal/services/upload_service.dart';
import 'package:xdeal/services/vehicle_category_service.dart';

import 'package:xdeal/utils/app_colors.dart';
import 'package:xdeal/widgets/custom_appbar.dart';

import 'package:xdeal/providers/user_provider.dart';

import 'package:xdeal/services/api_client.dart';
import 'package:xdeal/services/vehicle_listing_service.dart';
import 'package:xdeal/models/vehicle_listing.dart';

class CreateCarListingScreen extends StatefulWidget {
  const CreateCarListingScreen({super.key});

  @override
  State<CreateCarListingScreen> createState() => _CreateCarListingScreenState();
}

class _CreateCarListingScreenState extends State<CreateCarListingScreen> {
  final _formKey = GlobalKey<FormState>();

  // Images
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _images = [];

  // Controllers
  final _titleCtrl = TextEditingController();
  final _versionCtrl = TextEditingController();
  final _kilometersCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _seatsCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();

  // Dropdown values
  String? _brand;
  String? _model;
  String _condition = "new"; // new/used
  String? _fuelType;
  String? _airConditioning;
  String? _color;
  String _doors = "2/3";
  String? _interior;
  final List<String> _selectedExtraFeatures = [];
  String? _source;
  String? _paymentOption;

  // Currency
  String _priceCurrency = "USD";

  // Category
  bool _loadingCategories = false;
  List<VehicleCategory> _categories = [];
  String? _selectedCategoryId;

  // Location (simple placeholder)
  String? _locationLabel;
  List<double>? _coords; // [lat,lng]

  // Services
  late final ApiClient _api;
  late final VehicleCategoryService _vehicleCategoryService;
  late final UploadService _uploadService;

  // Data (replace with API fetched lists)
  final List<String> _brands = ["BMW", "Mercedes", "Toyota", "Kia", "Hyundai"];
  final Map<String, List<String>> _modelsByBrand = {
    "BMW": ["3 Series", "5 Series", "X5"],
    "Mercedes": ["C-Class", "E-Class", "GLE"],
    "Toyota": ["Corolla", "Camry", "RAV4"],
    "Kia": ["Sportage", "Sorento", "Rio"],
    "Hyundai": ["Elantra", "Tucson", "Sonata"],
  };

  final List<String> _fuelTypes = [
    "petrol",
    "diesel",
    "electric",
    "hybrid",
    "gas",
  ];
  final List<String> _airConds = ["manual", "automatic", "none"];
  final List<String> _colors = ["Black", "White", "Silver", "Blue", "Red"];
  final List<String> _interiors = [
    "cloth",
    "leather",
    "full leather",
    "partial leather",
    "alcantara",
  ];
  final List<String> _extras = ["Sunroof", "Camera", "Sensors", "Heated seats"];
  final List<String> _sources = ["Dealer", "Owner"];
  final List<String> _paymentOptions = ["cash", "installment"];

  bool _submitting = false;

  @override
  void initState() {
    super.initState();

    _api = ApiClient(baseUrl: 'http://10.0.2.2:5000');
    _vehicleCategoryService = VehicleCategoryService(_api);
    _uploadService = UploadService(baseUrl: 'http://10.0.2.2:5000');

    _loadVehicleCategories();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _versionCtrl.dispose();
    _kilometersCtrl.dispose();
    _yearCtrl.dispose();
    _seatsCtrl.dispose();
    _descriptionCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadVehicleCategories() async {
    setState(() => _loadingCategories = true);
    try {
      final cats = await _vehicleCategoryService.getAll(limit: 200);
      if (!mounted) return;
      setState(() {
        _categories = cats;
        // optionally preselect first
        if (_selectedCategoryId == null && _categories.isNotEmpty) {
          _selectedCategoryId = _categories.first.id;
        }
      });
    } catch (error) {
      print(error);
    } finally {
      if (mounted) setState(() => _loadingCategories = false);
    }
  }

  Future<void> _selectImages() async {
    final picked = await _picker.pickMultiImage(imageQuality: 80);
    if (picked.isEmpty) return;
    setState(() {
      _images.addAll(picked);
    });
  }

  void _removeImage(int index) {
    setState(() => _images.removeAt(index));
  }

  Future<void> _selectLocation() async {
    final initial = (_coords != null && _coords!.length == 2)
        ? LatLng(_coords![0], _coords![1])
        : const LatLng(33.8938, 35.5018);

    final result = await Navigator.push<MapPickResult>(
      context,
      MaterialPageRoute(builder: (_) => MapPickerScreen(initial: initial)),
    );

    if (result == null) return;

    setState(() {
      _locationLabel = result.address;
      _coords = [result.latLng.latitude, result.latLng.longitude];
    });
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF3F1FA),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: AppColors.primary.withValues(alpha: 0.25),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            text,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          if (required)
            const Text(
              "*",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
            ),
        ],
      ),
    );
  }

  Widget _dropdown({
    required String hint,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: _inputDecoration(hint),
      items: items,
      onChanged: onChanged,
      validator: validator,
      icon: const Icon(Icons.keyboard_arrow_down_rounded),
    );
  }

  Widget _segmentedChips({
    required List<MapEntry<String, String>> items, // label -> value
    required String value,
    required void Function(String v) onChanged,
  }) {
    return Wrap(
      spacing: 10,
      children: items.map((e) {
        final selected = e.value == value;
        return ChoiceChip(
          label: Text(e.key),
          selected: selected,
          onSelected: (_) => onChanged(e.value),
          selectedColor: AppColors.primary,
          labelStyle: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _submit() async {
    final user = context.read<UserProvider>().user;
    final userId = user?.id ?? user?.id;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You must be logged in to post a listing."),
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please add at least one image.")),
      );
      return;
    }

    if (_coords == null || _coords!.length != 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a location.")),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      // 1) upload images
      final imageUrls = await _uploadService.uploadVehicleImages(_images);

      // 2) build payload
      final payload = {
        "name": _titleCtrl.text.trim(),
        "images": imageUrls,
        "price": "${_priceCurrency} ${_priceCtrl.text.trim()}",
        "description": _descriptionCtrl.text.trim(),
        "category": _selectedCategoryId,
        "coords": _coords,
        "brand": _brand,
        "model": _model,
        "version": _versionCtrl.text.trim().isEmpty
            ? null
            : _versionCtrl.text.trim(),
        "condition": _condition,
        "kilometers":
            int.tryParse(_kilometersCtrl.text.replaceAll(",", "").trim()) ?? 0,
        "year": _yearCtrl.text.trim(),
        "fuel_type": _fuelType,
        "transmission_type": "automatic", // add field to UI if needed
        "body_type": "suv", // add field to UI if needed
        "air_conditioning": _airConditioning,
        "color": _color,
        "number_of_seats": int.tryParse(_seatsCtrl.text.trim()) ?? 0,
        "number_of_doors": _doors == "2/3" ? 2 : 4,
        "interior": _interior,
        "payment_option": _paymentOption,
        "extra_features": _selectedExtraFeatures,
        "is_featured": false,
        "is_sponsored": false,
        "is_listed": true,
        "on_sale": false,
        "number_of_views": 0,
        "user_id": userId,
      };

      // Call your service (wire it to your API)
      final api = ApiClient(baseUrl: 'http://10.0.2.2:5000');
      final service = VehicleListingService(api);
      await service.create(VehicleListing.fromJson(payload));

      // For now just simulate success:
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Listing posted.")));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed: $e")));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final models = _brand == null
        ? <String>[]
        : (_modelsByBrand[_brand!] ?? <String>[]);

    final categoryItems = _categories
        .map((c) => DropdownMenuItem<String>(value: c.id, child: Text(c.title)))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CustomAppbar(title: "Create a Car Listing"),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Add Images
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F1FA),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              "Add Images",
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: _selectImages,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                "Select Images",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "For the cover picture we recommend using the landscape mode",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.black54,
                              ),
                            ),
                            if (_images.isNotEmpty) ...[
                              const SizedBox(height: 14),
                              SizedBox(
                                height: 72,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _images.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(width: 10),
                                  itemBuilder: (_, i) {
                                    return Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          child: Image.file(
                                            File(_images[i].path),
                                            width: 72,
                                            height: 72,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Positioned(
                                          right: 4,
                                          top: 4,
                                          child: InkWell(
                                            onTap: () => _removeImage(i),
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                color: Colors.black54,
                                                shape: BoxShape.circle,
                                              ),
                                              padding: const EdgeInsets.all(4),
                                              child: const Icon(
                                                Icons.close,
                                                size: 14,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // ✅ Category dropdown (from backend)
                      _sectionLabel("Category", required: true),
                      if (_loadingCategories)
                        const SizedBox(
                          height: 52,
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else
                        _dropdown(
                          hint: "Choose Category",
                          value: _selectedCategoryId,
                          items: categoryItems,
                          onChanged: (v) =>
                              setState(() => _selectedCategoryId = v),
                          validator: (v) => (v == null || v.isEmpty)
                              ? "Category is required"
                              : null,
                        ),

                      const SizedBox(height: 14),

                      _sectionLabel("Title", required: true),
                      TextFormField(
                        controller: _titleCtrl,
                        decoration: _inputDecoration("Enter Car title"),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? "Title is required"
                            : null,
                      ),

                      const SizedBox(height: 14),

                      _sectionLabel("Car Brand", required: true),
                      _dropdown(
                        hint: "Choose Brand",
                        value: _brand,
                        items: _itemsFromStrings(_brands),
                        onChanged: (v) {
                          setState(() {
                            _brand = v;
                            _model = null;
                          });
                        },
                        validator: (v) =>
                            v == null ? "Brand is required" : null,
                      ),

                      const SizedBox(height: 14),

                      _sectionLabel("Car Model", required: true),
                      _dropdown(
                        hint: "Choose Model",
                        value: _model,
                        items: _itemsFromStrings(models),
                        onChanged: (v) => setState(() => _model = v),
                        validator: (v) =>
                            v == null ? "Model is required" : null,
                      ),

                      const SizedBox(height: 14),

                      _sectionLabel("Version"),
                      TextFormField(
                        controller: _versionCtrl,
                        decoration: _inputDecoration("Choose Version"),
                      ),

                      const SizedBox(height: 14),

                      _sectionLabel("Condition", required: true),
                      _segmentedChips(
                        items: const [
                          MapEntry("New", "new"),
                          MapEntry("Used", "used"),
                        ],
                        value: _condition,
                        onChanged: (v) => setState(() => _condition = v),
                      ),

                      const SizedBox(height: 14),

                      _sectionLabel("Kilometers", required: true),
                      TextFormField(
                        controller: _kilometersCtrl,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration(
                          "Enter Kilometers, eg: 42,500",
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? "Kilometers is required"
                            : null,
                      ),

                      const SizedBox(height: 14),

                      _sectionLabel("Year", required: true),
                      TextFormField(
                        controller: _yearCtrl,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration("Enter Year"),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? "Year is required"
                            : null,
                      ),

                      const SizedBox(height: 14),

                      _sectionLabel("Fuel Type", required: true),
                      _dropdown(
                        hint: "Choose FuelType",
                        value: _fuelType,
                        items: _itemsFromStrings(_fuelTypes),
                        onChanged: (v) => setState(() => _fuelType = v),
                        validator: (v) =>
                            v == null ? "Fuel Type is required" : null,
                      ),

                      const SizedBox(height: 34),

                      _sectionLabel("Air Conditioning"),
                      _dropdown(
                        hint: "Choose Air Conditioning",
                        value: _airConditioning,
                        items: _itemsFromStrings(_airConds),
                        onChanged: (v) => setState(() => _airConditioning = v),
                      ),

                      const SizedBox(height: 14),

                      _sectionLabel("Color", required: true),
                      _dropdown(
                        hint: "Choose Color",
                        value: _color,
                        items: _itemsFromStrings(_colors),
                        onChanged: (v) => setState(() => _color = v),
                        validator: (v) =>
                            v == null ? "Color is required" : null,
                      ),

                      const SizedBox(height: 14),

                      _sectionLabel("Number of Seats"),
                      TextFormField(
                        controller: _seatsCtrl,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration("Enter Number of Seats"),
                      ),

                      const SizedBox(height: 14),

                      _sectionLabel("Number of Doors", required: true),
                      _segmentedChips(
                        items: const [
                          MapEntry("2/3", "2/3"),
                          MapEntry("4/5", "4/5"),
                        ],
                        value: _doors,
                        onChanged: (v) => setState(() => _doors = v),
                      ),

                      const SizedBox(height: 14),

                      _sectionLabel("Interior"),
                      _dropdown(
                        hint: "Choose Interior",
                        value: _interior,
                        items: _itemsFromStrings(_interiors),
                        onChanged: (v) => setState(() => _interior = v),
                      ),

                      const SizedBox(height: 14),

                      _sectionLabel("Extra Features"),
                      _multiSelectChips(
                        options: _extras,
                        selected: _selectedExtraFeatures,
                        onChanged: (next) => setState(() {
                          _selectedExtraFeatures
                            ..clear()
                            ..addAll(next);
                        }),
                      ),
                      const SizedBox(height: 14),

                      _sectionLabel("Source"),
                      _dropdown(
                        hint: "Choose Source",
                        value: _source,
                        items: _itemsFromStrings(_sources),
                        onChanged: (v) => setState(() => _source = v),
                      ),

                      const SizedBox(height: 14),

                      _sectionLabel("Description"),
                      TextFormField(
                        controller: _descriptionCtrl,
                        decoration: _inputDecoration(
                          "Describe the item your selling",
                        ),
                        maxLines: 5,
                        maxLength: 4096,
                      ),

                      const SizedBox(height: 14),

                      _sectionLabel("Select Location", required: true),
                      InkWell(
                        onTap: _selectLocation,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F1FA),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.search, color: Colors.black45),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _locationLabel ?? "Select Location",
                                  style: TextStyle(
                                    color: _locationLabel == null
                                        ? Colors.black45
                                        : Colors.black87,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      _sectionLabel("Payment Option"),
                      _dropdown(
                        hint: "Choose Payment Options",
                        value: _paymentOption,
                        items: _itemsFromStrings(_paymentOptions),
                        onChanged: (v) => setState(() => _paymentOption = v),
                      ),

                      const SizedBox(height: 14),

                      _sectionLabel("Price", required: true),
                      Row(
                        children: [
                          SizedBox(
                            width: 90,
                            child: _dropdown(
                              hint: "USD",
                              value: _priceCurrency,
                              items: _itemsFromStrings(["USD", "LBP"]),
                              onChanged: (v) =>
                                  setState(() => _priceCurrency = v ?? "USD"),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: _priceCtrl,
                              keyboardType: TextInputType.number,
                              decoration: _inputDecoration("Enter Price"),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? "Price is required"
                                  : null,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      Align(
                        alignment: Alignment.centerRight,
                        child: SizedBox(
                          height: 44,
                          child: ElevatedButton(
                            onPressed: _submitting ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              disabledBackgroundColor: Colors.red.withValues(
                                alpha: 0.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                              ),
                            ),
                            child: _submitting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    "Post Now",
                                    style: TextStyle(color: Colors.white),
                                  ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _multiSelectChips({
    required List<String> options,
    required List<String> selected,
    required void Function(List<String> next) onChanged,
  }) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((opt) {
        final isSelected = selected.contains(opt);

        return FilterChip(
          label: Text(opt),
          selected: isSelected,
          onSelected: (v) {
            final next = [...selected];
            if (v) {
              next.add(opt);
            } else {
              next.remove(opt);
            }
            onChanged(next);
          },
          selectedColor: AppColors.primary,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          showCheckmark: false,
        );
      }).toList(),
    );
  }
}

List<DropdownMenuItem<String>> _itemsFromStrings(List<String> list) {
  return list
      .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
      .toList();
}
