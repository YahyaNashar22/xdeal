import 'package:flutter/material.dart';
import 'package:xdeal/theme/app_theme.dart';
import 'package:xdeal/utils/app_colors.dart';

class SearchBarAndFilter extends StatefulWidget {
  const SearchBarAndFilter({super.key});

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

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.inputBackground,
              borderRadius: BorderRadius.circular(5),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 0),
            height: 48,
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: AppTheme.primaryColor),
              decoration: InputDecoration(
                hintText: "Beirut",
                hintStyle: TextStyle(color: AppTheme.primaryColor),
                prefixIcon: Icon(Icons.search, color: AppTheme.primaryColor),
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: Icon(
            Icons.format_list_bulleted_rounded,
            color: AppColors.primary,
            size: 36,
          ),
        ),
      ],
    );
  }
}
