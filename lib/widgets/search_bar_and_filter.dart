import 'dart:async';

import 'package:flutter/material.dart';
import 'package:xdeal/services/api_client.dart';
import 'package:xdeal/services/property_category_service.dart';
import 'package:xdeal/services/vehicle_category_service.dart';
import 'package:xdeal/theme/app_theme.dart';
import 'package:xdeal/utils/app_colors.dart';
import 'package:xdeal/widgets/filters.dart';

class CategoryItem {
  final String id;
  final String title;
  CategoryItem({required this.id, required this.title});
}

// TODO: implement search bar and filter functionality
// TODO: fetch filters from backend

class SearchBarAndFilter extends StatefulWidget {
  final int selectedView;

  /// called whenever search/category changes
  final void Function(String q, String? categoryId) onChanged;

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

  late final ApiClient _api;
  late final VehicleCategoryService _vehicleService;
  late final PropertyCategoryService _propertyService;

  bool _loadingFilters = false;
  List<CategoryItem> _propertyCategories = [];
  List<CategoryItem> _vehicleCategories = [];

  String? _selectedCategoryId;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    // set your baseUrl (example)
    _api = ApiClient(baseUrl: 'http://10.0.2.2:5000');
    _vehicleService = VehicleCategoryService(_api);
    _propertyService = PropertyCategoryService(_api);

    _loadFilters();
  }

  @override
  void dispose() {
    super.dispose();
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      widget.onChanged(value.trim(), _selectedCategoryId);
    });
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

        // reset selected category when switching view later
        _selectedCategoryId = null;
      });
    } finally {
      if (mounted) setState(() => _loadingFilters = false);
    }
  }

  void _showCustomFilterModal(BuildContext context) {
    showBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text('This is a modal bottom sheet'),
                ElevatedButton(
                  child: const Text('Close Modal'),
                  onPressed: () =>
                      Navigator.pop(context), // Dismisses the modal
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void didUpdateWidget(covariant SearchBarAndFilter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedView != widget.selectedView) {
      setState(() => _selectedCategoryId = null);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        widget.onChanged(_searchController.text.trim(), null);
      });
    }
  }

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
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 0,
                ),
                height: 48,
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  style: TextStyle(color: AppTheme.primaryColor),
                  decoration: InputDecoration(
                    hintText: "Lebanon",
                    hintStyle: TextStyle(color: AppTheme.primaryColor),
                    prefixIcon: Icon(
                      Icons.search,
                      color: AppTheme.primaryColor,
                    ),
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

  Widget _buildCategoryChips(List<CategoryItem> cats) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: cats.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          // "All" chip
          if (index == 0) {
            final selected = _selectedCategoryId == null;
            return ChoiceChip(
              label: const Text('All'),
              selected: selected,
              onSelected: (_) {
                setState(() => _selectedCategoryId = null);
                widget.onChanged(_searchController.text.trim(), null);
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
              );
            },
          );
        },
      ),
    );
  }
}
