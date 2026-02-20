import 'package:flutter/material.dart';
import 'package:xdeal/dummy_data.dart';
import 'package:xdeal/services/api_client.dart';
import 'package:xdeal/services/property_category_service.dart';
import 'package:xdeal/services/vehicle_category_service.dart';
import 'package:xdeal/theme/app_theme.dart';
import 'package:xdeal/utils/app_colors.dart';
import 'package:xdeal/widgets/filters.dart';

// TODO: implement search bar and filter functionality
// TODO: fetch filters from backend

class SearchBarAndFilter extends StatefulWidget {
  final int selectedView;
  const SearchBarAndFilter({super.key, required this.selectedView});

  @override
  State<SearchBarAndFilter> createState() => _SearchBarAndFilterState();
}

class _SearchBarAndFilterState extends State<SearchBarAndFilter> {
  final TextEditingController _searchController = TextEditingController();

  late final ApiClient _api;
  late final VehicleCategoryService _vehicleService;
  late final PropertyCategoryService _propertyService;

  bool _loadingFilters = false;
  List<String> _propertyFilters = [];
  List<String> _vehicleFilters = [];

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
    _searchController.dispose();
  }

  Future<void> _loadFilters() async {
    setState(() => _loadingFilters = true);
    try {
      final property = await _propertyService.getAll(limit: 200);
      final vehicle = await _vehicleService.getAll(limit: 200);

      setState(() {
        _propertyFilters = property.map((e) => e.title).toList();
        _vehicleFilters = vehicle.map((e) => e.title).toList();
      });
    } catch (_) {
      // optional: show toast/snackbar
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
  Widget build(BuildContext context) {
    final filters = widget.selectedView == 0
        ? _propertyFilters
        : _vehicleFilters;

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
          Filters(filters: filters),
      ],
    );
  }
}
