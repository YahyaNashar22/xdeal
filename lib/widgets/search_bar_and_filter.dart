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

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
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
        Filters(
          filters: widget.selectedView == 0
              ? DummyData.propertyCategories
              : DummyData.vehicleCategories,
        ),
      ],
    );
  }
}
