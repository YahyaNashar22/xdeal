import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:xdeal/localization/app_localizations.dart';
import 'package:xdeal/models/saved_search.dart';
import 'package:xdeal/providers/user_provider.dart';
import 'package:xdeal/screens/map_picker_screen.dart';
import 'package:xdeal/services/api_client.dart';
import 'package:xdeal/services/property_category_service.dart';
import 'package:xdeal/services/saved_search_service.dart';
import 'package:xdeal/services/vehicle_category_service.dart';
import 'package:xdeal/theme/app_theme.dart';
import 'package:xdeal/utils/app_colors.dart';

class CategoryItem {
  final String id;
  final String title;
  CategoryItem({required this.id, required this.title});
}

class SearchBarAndFilter extends StatefulWidget {
  final int selectedView;

  /// called whenever search/category changes
  final void Function(String q, String? categoryId, Map<String, dynamic> extraFilters) onChanged;

  const SearchBarAndFilter({
    super.key,
    required this.selectedView,
    required this.onChanged,
  });

  @override
  State<SearchBarAndFilter> createState() => _SearchBarAndFilterState();
}

class _SearchBarAndFilterState extends State<SearchBarAndFilter> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  late final ApiClient _api;
  late final VehicleCategoryService _vehicleService;
  late final PropertyCategoryService _propertyService;
  late final SavedSearchService _savedSearchService;

  bool _loadingFilters = false;
  bool _loadingSavedSearches = false;
  List<CategoryItem> _propertyCategories = [];
  List<CategoryItem> _vehicleCategories = [];
  List<SavedSearch> _savedSearches = [];

  String? _selectedCategoryId;
  Map<String, dynamic> _extraFilters = {};
  Timer? _debounce;

  // Overlay (high z-index dropdown)
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();

    _api = ApiClient(baseUrl: 'http://10.0.2.2:5000');
    _vehicleService = VehicleCategoryService(_api);
    _propertyService = PropertyCategoryService(_api);
    _savedSearchService = SavedSearchService(_api);

    _loadFilters();
    _loadSavedSearches();

    _searchFocusNode.addListener(() {
      if (!mounted) return;

      if (_searchFocusNode.hasFocus) {
        _showOverlay();
      } else {
        _hideOverlay();
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _hideOverlay();
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      widget.onChanged(
        value.trim(),
        _selectedCategoryId,
        Map<String, dynamic>.from(_extraFilters),
      );
    });

    // update overlay content live
    if (_searchFocusNode.hasFocus) {
      _refreshOverlay();
    }
  }

  Future<void> _loadSavedSearches() async {
    final currentUser = context.read<UserProvider>().user;
    if (currentUser == null) {
      if (!mounted) return;
      setState(() => _savedSearches = []);
      _refreshOverlay();
      return;
    }

    setState(() => _loadingSavedSearches = true);
    _refreshOverlay();

    try {
      final items = await _savedSearchService.getAll(currentUser.id);
      if (!mounted) return;
      setState(() => _savedSearches = items);
    } finally {
      if (mounted) setState(() => _loadingSavedSearches = false);
      _refreshOverlay();
    }
  }

  Future<void> _saveSearch(String rawTerm) async {
    final term = rawTerm.trim();
    if (term.isEmpty) return;

    final currentUser = context.read<UserProvider>().user;
    if (currentUser == null) return;

    final exists = _savedSearches.any(
      (s) => s.searchTerm.trim().toLowerCase() == term.toLowerCase(),
    );
    if (exists) return;

    await _savedSearchService.create(userId: currentUser.id, searchTerm: term);
    await _loadSavedSearches();
  }

  Future<void> _deleteSavedSearch(String id) async {
    await _savedSearchService.deleteById(id);
    await _loadSavedSearches();
  }

  void _applySearchTerm(String term) {
    _searchController.text = term;
    _searchController.selection = TextSelection.collapsed(offset: term.length);
    widget.onChanged(
      term.trim(),
      _selectedCategoryId,
      Map<String, dynamic>.from(_extraFilters),
    );
    _searchFocusNode.unfocus();
  }

  Future<void> _handleSearchSubmit(String value) async {
    final term = value.trim();
    widget.onChanged(
      term,
      _selectedCategoryId,
      Map<String, dynamic>.from(_extraFilters),
    );
    await _saveSearch(term);
    _refreshOverlay();
  }

  Future<void> _loadFilters() async {
    setState(() => _loadingFilters = true);
    try {
      final property = await _propertyService.getAll(limit: 200);
      final vehicle = await _vehicleService.getAll(limit: 200);

      if (!mounted) return;

      setState(() {
        _propertyCategories = property
            .map((e) => CategoryItem(id: e.id, title: e.title))
            .toList();

        _vehicleCategories = vehicle
            .map((e) => CategoryItem(id: e.id, title: e.title))
            .toList();

        _selectedCategoryId = null;
      });
    } finally {
      if (mounted) setState(() => _loadingFilters = false);
    }
  }

  void _showCustomFilterModal(BuildContext context) {
    final cats = widget.selectedView == 0
        ? _propertyCategories
        : _vehicleCategories;

    String? tempCategoryId = _selectedCategoryId;
    final tempFilters = Map<String, dynamic>.from(_extraFilters);

    final TextEditingController brandCtrl = TextEditingController(
      text: (tempFilters['brand'] ?? '').toString(),
    );
    final TextEditingController modelCtrl = TextEditingController(
      text: (tempFilters['model'] ?? '').toString(),
    );
    final TextEditingController yearMinCtrl = TextEditingController(
      text: (tempFilters['year_min'] ?? '').toString(),
    );
    final TextEditingController yearMaxCtrl = TextEditingController(
      text: (tempFilters['year_max'] ?? '').toString(),
    );
    final TextEditingController kmMinCtrl = TextEditingController(
      text: (tempFilters['km_min'] ?? '').toString(),
    );
    final TextEditingController kmMaxCtrl = TextEditingController(
      text: (tempFilters['km_max'] ?? '').toString(),
    );
    final TextEditingController bedroomsMinCtrl = TextEditingController(
      text: (tempFilters['bedrooms_min'] ?? '').toString(),
    );
    final TextEditingController bathroomsMinCtrl = TextEditingController(
      text: (tempFilters['bathrooms_min'] ?? '').toString(),
    );
    final TextEditingController spaceMinCtrl = TextEditingController(
      text: (tempFilters['space_min'] ?? '').toString(),
    );
    final TextEditingController radiusCtrl = TextEditingController(
      text: (tempFilters['radius_km'] ?? '5').toString(),
    );

    String? locationLabel = (tempFilters['location_label'] ?? '').toString();

    Future<void> pickLocation(StateSetter setModalState) async {
      final lat = _toDouble(tempFilters['lat']) ?? 33.8938;
      final lng = _toDouble(tempFilters['lng']) ?? 35.5018;
      final result = await Navigator.push<MapPickResult>(
        context,
        MaterialPageRoute(
          builder: (_) => MapPickerScreen(initial: LatLng(lat, lng)),
        ),
      );

      if (result == null) return;
      setModalState(() {
        tempFilters['lat'] = result.latLng.latitude;
        tempFilters['lng'] = result.latLng.longitude;
        tempFilters['location_label'] = result.address;
        locationLabel = result.address;
      });
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        context.tr('Custom Filters'),
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String?>(
                        initialValue: tempCategoryId,
                        decoration: InputDecoration(
                          labelText: context.tr('Category'),
                        ),
                        items: [
                          DropdownMenuItem<String?>(
                            value: null,
                            child: Text(context.tr('All')),
                          ),
                          ...cats.map(
                            (c) => DropdownMenuItem<String?>(
                              value: c.id,
                              child: Text(c.title),
                            ),
                          ),
                        ],
                        onChanged: (v) => setModalState(() => tempCategoryId = v),
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.location_on_outlined),
                        title: Text(
                          (locationLabel != null && locationLabel!.isNotEmpty)
                              ? locationLabel!
                              : context.tr('Pick Location'),
                        ),
                        subtitle: Text(context.tr('Used with radius to search nearby')),
                        trailing: TextButton(
                          onPressed: () => pickLocation(setModalState),
                          child: Text(context.tr('Choose')),
                        ),
                      ),
                      TextFormField(
                        controller: radiusCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: context.tr('Radius (km)'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (widget.selectedView == 1) ...[
                        TextFormField(
                          controller: brandCtrl,
                          decoration: InputDecoration(
                            labelText: context.tr('Brand'),
                          ),
                        ),
                        TextFormField(
                          controller: modelCtrl,
                          decoration: InputDecoration(
                            labelText: context.tr('Model'),
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: yearMinCtrl,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: context.tr('Year min'),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: yearMaxCtrl,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: context.tr('Year max'),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: kmMinCtrl,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: context.tr('KM min'),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: kmMaxCtrl,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: context.tr('KM max'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: bedroomsMinCtrl,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: context.tr('Bedrooms min'),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: bathroomsMinCtrl,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: context.tr('Bathrooms min'),
                                ),
                              ),
                            ),
                          ],
                        ),
                        TextFormField(
                          controller: spaceMinCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: context.tr('Space min (m²)'),
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(context.tr('On Sale Only')),
                        value: (tempFilters['on_sale'] as bool?) ?? false,
                        onChanged: (v) => setModalState(() => tempFilters['on_sale'] = v),
                      ),
                      if (widget.selectedView == 0)
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(context.tr('Rent Only')),
                          value: (tempFilters['is_rent'] as bool?) ?? false,
                          onChanged: (v) =>
                              setModalState(() => tempFilters['is_rent'] = v),
                        ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _selectedCategoryId = null;
                                  _extraFilters = {};
                                });
                                widget.onChanged(
                                  _searchController.text.trim(),
                                  null,
                                  const {},
                                );
                                Navigator.pop(context);
                              },
                              child: Text(context.tr('Reset')),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                final nextFilters = <String, dynamic>{
                                  ...tempFilters,
                                };

                                void putInt(String key, TextEditingController c) {
                                  final v = int.tryParse(c.text.trim());
                                  if (v == null) {
                                    nextFilters.remove(key);
                                  } else {
                                    nextFilters[key] = v;
                                  }
                                }

                                void putString(
                                  String key,
                                  TextEditingController c,
                                ) {
                                  final v = c.text.trim();
                                  if (v.isEmpty) {
                                    nextFilters.remove(key);
                                  } else {
                                    nextFilters[key] = v;
                                  }
                                }

                                putInt('radius_km', radiusCtrl);
                                if (!nextFilters.containsKey('lat') ||
                                    !nextFilters.containsKey('lng')) {
                                  nextFilters.remove('radius_km');
                                  nextFilters.remove('location_label');
                                }

                                if (widget.selectedView == 1) {
                                  putString('brand', brandCtrl);
                                  putString('model', modelCtrl);
                                  putInt('year_min', yearMinCtrl);
                                  putInt('year_max', yearMaxCtrl);
                                  putInt('km_min', kmMinCtrl);
                                  putInt('km_max', kmMaxCtrl);
                                } else {
                                  putInt('bedrooms_min', bedroomsMinCtrl);
                                  putInt('bathrooms_min', bathroomsMinCtrl);
                                  putInt('space_min', spaceMinCtrl);
                                }

                                setState(() {
                                  _selectedCategoryId = tempCategoryId;
                                  _extraFilters = nextFilters;
                                });
                                widget.onChanged(
                                  _searchController.text.trim(),
                                  _selectedCategoryId,
                                  Map<String, dynamic>.from(_extraFilters),
                                );
                                Navigator.pop(context);
                              },
                              child: Text(context.tr('Apply')),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString().trim());
  }

  @override
  void didUpdateWidget(covariant SearchBarAndFilter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedView != widget.selectedView) {
      setState(() {
        _selectedCategoryId = null;
        _extraFilters = {};
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        widget.onChanged(_searchController.text.trim(), null, const {});
      });
      _refreshOverlay();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadSavedSearches();
  }

  // -------- Overlay helpers --------

  List<SavedSearch> _currentSuggestedSearches() {
    final input = _searchController.text.trim().toLowerCase();
    return _savedSearches
        .where(
          (s) =>
              input.isEmpty ||
              s.searchTerm.trim().toLowerCase().contains(input),
        )
        .toList();
  }

  bool _shouldShowDropdown() {
    if (!_searchFocusNode.hasFocus) return false;
    if (_loadingSavedSearches) return true;
    return _currentSuggestedSearches().isNotEmpty;
  }

  OverlayEntry _createOverlayEntry() {
    // Find the position of this widget on screen
    final box = context.findRenderObject() as RenderBox;
    final size = box.size;
    final offset = box.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) {
        final items = _currentSuggestedSearches();

        if (!_shouldShowDropdown()) {
          return const SizedBox.shrink();
        }

        return Positioned(
          left: offset.dx,
          top: offset.dy + 52,
          width: size.width - 48, // same as your old Stack right: 48
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(8),
            child: _buildSavedSearchesDropdown(items),
          ),
        );
      },
    );
  }

  void _showOverlay() {
    if (_overlayEntry != null) return;
    if (!mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_overlayEntry != null) return;

      _overlayEntry = _createOverlayEntry();
      Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);

      // render the initial content
      _refreshOverlay();
    });
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  bool _refreshScheduled = false;

  void _refreshOverlay() {
    if (_overlayEntry == null) return;
    if (_refreshScheduled) return;

    _refreshScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshScheduled = false;
      if (!mounted) return;
      if (_overlayEntry == null) return;
      _overlayEntry!.markNeedsBuild();
    });
  }

  // -------- UI --------

  @override
  Widget build(BuildContext context) {
    final cats = widget.selectedView == 0
        ? _propertyCategories
        : _vehicleCategories;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.inputBackground,
                  borderRadius: BorderRadius.circular(5),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                height: 48,
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  onChanged: _onSearchChanged,
                  onSubmitted: _handleSearchSubmit,
                  style: TextStyle(color: AppTheme.primaryColor),
                  decoration: InputDecoration(
                    hintText: context.tr("Lebanon"),
                    hintStyle: TextStyle(color: AppTheme.primaryColor),
                    prefixIcon: Icon(
                      Icons.search,
                      color: AppTheme.primaryColor,
                    ),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: () => _showCustomFilterModal(context),
              icon: Icon(
                Icons.format_list_bulleted_rounded,
                color: AppColors.primary,
                size: 36,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_loadingFilters)
          const SizedBox(
            height: 40,
            child: Center(child: CircularProgressIndicator()),
          )
        else
          _buildCategoryChips(cats),
      ],
    );
  }

  Widget _buildSavedSearchesDropdown(List<SavedSearch> items) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 220),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.inputBg),
      ),
      child: _loadingSavedSearches
          ? const SizedBox(
              height: 52,
              child: Center(child: CircularProgressIndicator()),
            )
          : ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: items.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 1, color: AppColors.inputBg),
              itemBuilder: (_, index) {
                final item = items[index];
                return ListTile(
                  dense: true,
                  title: Text(item.searchTerm),
                  onTap: () => _applySearchTerm(item.searchTerm),
                  trailing: IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => _deleteSavedSearch(item.id),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildCategoryChips(List<CategoryItem> cats) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: cats.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            final selected = _selectedCategoryId == null;
            return ChoiceChip(
              label: Text(context.tr('All')),
              selected: selected,
              onSelected: (_) {
                setState(() => _selectedCategoryId = null);
                widget.onChanged(
                  _searchController.text.trim(),
                  null,
                  Map<String, dynamic>.from(_extraFilters),
                );
                _refreshOverlay();
              },
            );
          }

          final c = cats[index - 1];
          final selected = _selectedCategoryId == c.id;

          return ChoiceChip(
            label: Text(c.title),
            selected: selected,
            onSelected: (_) {
              setState(() => _selectedCategoryId = selected ? null : c.id);
              widget.onChanged(
                _searchController.text.trim(),
                _selectedCategoryId,
                Map<String, dynamic>.from(_extraFilters),
              );
              _refreshOverlay();
            },
          );
        },
      ),
    );
  }
}
