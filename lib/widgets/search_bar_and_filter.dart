import 'package:flutter/material.dart';
import 'package:xdeal/dummy_data.dart';
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
  bool _showFilters = false;

  void _toggleFiltersVisibility() {
    setState(() {
      _showFilters = !_showFilters;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    hintText: "Beirut",
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
              onPressed: () => _toggleFiltersVisibility(),
              icon: Icon(
                Icons.format_list_bulleted_rounded,
                color: AppColors.primary,
                size: 36,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_showFilters)
          Filters(
            filters: widget.selectedView == 0
                ? DummyData.propertyCategories
                : DummyData.vehicleCategories,
          ),
      ],
    );
  }
}
