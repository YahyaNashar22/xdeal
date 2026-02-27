import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:xdeal/localization/app_localizations.dart';
import 'package:xdeal/models/property_category.dart';
import 'package:xdeal/models/property_listing.dart';
import 'package:xdeal/providers/user_provider.dart';
import 'package:xdeal/screens/map_picker_screen.dart';
import 'package:xdeal/screens/screen_selector.dart';
import 'package:xdeal/services/api_client.dart';
import 'package:xdeal/services/property_category_service.dart';
import 'package:xdeal/services/property_listing_service.dart';
import 'package:xdeal/services/upload_service.dart';
import 'package:xdeal/utils/app_colors.dart';
import 'package:xdeal/widgets/custom_appbar.dart';

class CreatePropertyListingScreen extends StatefulWidget {
  const CreatePropertyListingScreen({super.key});

  @override
  State<CreatePropertyListingScreen> createState() =>
      _CreatePropertyListingScreenState();
}

class _CreatePropertyListingScreenState
    extends State<CreatePropertyListingScreen> {
  final _formKey = GlobalKey<FormState>();

  final ImagePicker _picker = ImagePicker();
  final List<XFile> _images = [];

  final _titleCtrl = TextEditingController();
  final _threeSixtyCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _bedroomsCtrl = TextEditingController();
  final _bathroomsCtrl = TextEditingController();
  final _spaceCtrl = TextEditingController();

  bool _loadingCategories = false;
  List<PropertyCategory> _categories = [];
  String? _selectedCategoryId;

  final List<String> _selectedExtraFeatures = [];
  String _agentType = "owner";
  bool _isRent = false;
  String? _rentalPayment;

  String? _locationLabel;
  List<double>? _coords;

  late final ApiClient _api;
  late final PropertyCategoryService _propertyCategoryService;
  late final UploadService _uploadService;

  final List<String> _extras = [
    "Ocean View",
    "Swimming Pool",
    "Gourmet Kitchen",
    "Private Beach",
    "Garden",
    "Parking",
  ];
  final List<String> _rentalPayments = ["daily", "monthly", "yearly"];

  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _api = ApiClient(baseUrl: 'http://10.0.2.2:5000');
    _propertyCategoryService = PropertyCategoryService(_api);
    _uploadService = UploadService(baseUrl: 'http://10.0.2.2:5000');
    _loadPropertyCategories();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _threeSixtyCtrl.dispose();
    _descriptionCtrl.dispose();
    _priceCtrl.dispose();
    _bedroomsCtrl.dispose();
    _bathroomsCtrl.dispose();
    _spaceCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadPropertyCategories() async {
    setState(() => _loadingCategories = true);
    try {
      final cats = await _propertyCategoryService.getAll(limit: 200);
      if (!mounted) return;
      setState(() {
        _categories = cats;
        if (_selectedCategoryId == null && _categories.isNotEmpty) {
          _selectedCategoryId = _categories.first.id;
        }
      });
    } catch (_) {
      // ignore for now, form can still render
    } finally {
      if (mounted) setState(() => _loadingCategories = false);
    }
  }

  Future<void> _selectImages() async {
    final picked = await _picker.pickMultiImage(imageQuality: 80);
    if (picked.isEmpty) return;
    setState(() => _images.addAll(picked));
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

  Future<void> _submit() async {
    final user = context.read<UserProvider>().user;
    final userId = user?.id;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr("You must be logged in to post a listing.")),
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr("Please add at least one image."))),
      );
      return;
    }

    if (_coords == null || _coords!.length != 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr("Please select a location."))),
      );
      return;
    }

    if (_isRent && (_rentalPayment == null || _rentalPayment!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr("Please select rental payment period.")),
        ),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final imageUrls = await _uploadService.uploadPropertyImages(_images);

      final payload = {
        "name": _titleCtrl.text.trim(),
        "images": imageUrls,
        "three_sixty": _threeSixtyCtrl.text.trim().isEmpty
            ? null
            : _threeSixtyCtrl.text.trim(),
        "price": _priceCtrl.text.trim(),
        "description": _descriptionCtrl.text.trim(),
        "category": _selectedCategoryId,
        "coords": _coords,
        "bedrooms": int.tryParse(_bedroomsCtrl.text.trim()) ?? 0,
        "bathrooms": int.tryParse(_bathroomsCtrl.text.trim()) ?? 0,
        "space": int.tryParse(_spaceCtrl.text.trim()) ?? 0,
        "extra_features": _selectedExtraFeatures,
        "is_featured": false,
        "is_sponsored": false,
        "is_listed": true,
        "on_sale": false,
        "is_rent": _isRent,
        "number_of_views": 0,
        "agent_type": _agentType,
        "rental_payment": _isRent ? _rentalPayment : null,
        "user_id": userId,
      };

      final service = PropertyListingService(_api);
      await service.create(PropertyListing.fromJson(payload));

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.tr("Property listed."))));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(content: Text("${context.tr("Failed")}: $e")),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: context.tr(hint),
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
            context.tr(text),
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
    required String? initialValue,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: initialValue,
      decoration: _inputDecoration(hint),
      items: items,
      onChanged: onChanged,
      validator: validator,
      icon: const Icon(Icons.keyboard_arrow_down_rounded),
    );
  }

  Widget _segmentedChips({
    required List<MapEntry<String, String>> items,
    required String value,
    required void Function(String v) onChanged,
  }) {
    return Wrap(
      spacing: 10,
      children: items.map((e) {
        final selected = e.value == value;
        return ChoiceChip(
          label: Text(context.tr(e.key)),
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

  @override
  Widget build(BuildContext context) {
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
              const CustomAppbar(title: "Create a Property Listing"),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F1FA),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              context.tr("Add Images"),
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
                              child: Text(
                                context.tr("Select Images"),
                                style: TextStyle(color: Colors.white),
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
                      _sectionLabel("Category", required: true),
                      if (_loadingCategories)
                        const SizedBox(
                          height: 52,
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else
                        _dropdown(
                          hint: "Choose Category",
                          initialValue: _selectedCategoryId,
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
                        decoration: _inputDecoration("Enter Property title"),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? "Title is required"
                            : null,
                      ),
                      const SizedBox(height: 14),
                      _sectionLabel("Description", required: true),
                      TextFormField(
                        controller: _descriptionCtrl,
                        decoration: _inputDecoration("Describe your property"),
                        maxLines: 5,
                        maxLength: 4096,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? "Description is required"
                            : null,
                      ),
                      const SizedBox(height: 14),
                      _sectionLabel("Bedrooms", required: true),
                      TextFormField(
                        controller: _bedroomsCtrl,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration("Enter number of bedrooms"),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? "Bedrooms is required"
                            : null,
                      ),
                      const SizedBox(height: 14),
                      _sectionLabel("Bathrooms", required: true),
                      TextFormField(
                        controller: _bathroomsCtrl,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration(
                          "Enter number of bathrooms",
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? "Bathrooms is required"
                            : null,
                      ),
                      const SizedBox(height: 14),
                      _sectionLabel("Space (m²)", required: true),
                      TextFormField(
                        controller: _spaceCtrl,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration("Enter property space"),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? "Space is required"
                            : null,
                      ),
                      const SizedBox(height: 14),
                      _sectionLabel("Agent Type", required: true),
                      _segmentedChips(
                        items: const [
                          MapEntry("Owner", "owner"),
                          MapEntry("Middleman", "middleman"),
                        ],
                        value: _agentType,
                        onChanged: (v) => setState(() => _agentType = v),
                      ),
                      const SizedBox(height: 14),
                      _sectionLabel("Listing Type", required: true),
                      _segmentedChips(
                        items: const [
                          MapEntry("Sale", "sale"),
                          MapEntry("Rent", "rent"),
                        ],
                        value: _isRent ? "rent" : "sale",
                        onChanged: (v) {
                          setState(() {
                            _isRent = v == "rent";
                            if (!_isRent) _rentalPayment = null;
                          });
                        },
                      ),
                      if (_isRent) ...[
                        const SizedBox(height: 14),
                        _sectionLabel("Rental Payment", required: true),
                        _dropdown(
                          hint: "Choose rental period",
                          initialValue: _rentalPayment,
                          items: _rentalPayments
                              .map(
                                (e) => DropdownMenuItem<String>(
                                  value: e,
                                  child: Text(e),
                                ),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => _rentalPayment = v),
                          validator: (v) => (_isRent && (v == null || v.isEmpty))
                              ? "Rental payment is required"
                              : null,
                        ),
                      ],
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
                      _sectionLabel("360 Image URL"),
                      TextFormField(
                        controller: _threeSixtyCtrl,
                        decoration: _inputDecoration(
                          "Paste panorama image URL (optional)",
                        ),
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
                      _sectionLabel("Price", required: true),
                      TextFormField(
                        controller: _priceCtrl,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration("Enter Price"),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? "Price is required"
                            : null,
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            height: 44,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_submitting) return;
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) => ScreenSelector(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondary,
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
                              child: Text(context.tr("Cancel")),
                            ),
                          ),
                          SizedBox(
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
                                  : Text(
                                      context.tr("Post Now"),
                                      style: TextStyle(color: Colors.white),
                                    ),
                            ),
                          ),
                        ],
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
          label: Text(context.tr(opt)),
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
