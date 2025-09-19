import 'package:flutter/material.dart';
import 'package:xdeal/dummy_data.dart';
import 'package:xdeal/utils/app_colors.dart';
import 'package:xdeal/widgets/custom_appbar.dart';
import 'package:xdeal/widgets/listings_viewer.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  // TODO: implement real fetching from user favorites array
  final List<Map<String, dynamic>> _favoritesProperties =
      DummyData.favoritesProperties;

  final List<Map<String, dynamic>> _favoritesVehicles =
      DummyData.favoritesVehicles;

  // 0 -> Properties
  // 1 -> vehicles
  int _selectedView = 0;

  void _selectView(int view) {
    setState(() {
      setState(() {
        _selectedView = view;
      });
    });
  }

  TextStyle _selectedBtnStyle(int view) {
    if (_selectedView == view) {
      return TextStyle(color: AppColors.primary);
    }
    return TextStyle(color: AppColors.black);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              CustomAppbar(title: "Favorites"),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // properties / vehicles switch
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => _selectView(0),
                          child: Text(
                            "Properties",
                            style: _selectedBtnStyle(0),
                          ),
                        ),
                        TextButton(
                          onPressed: () => _selectView(1),
                          child: Text("Vehicles", style: _selectedBtnStyle(1)),
                        ),
                      ],
                    ),
                    Divider(),
                    const SizedBox(height: 24),
                    ListingsViewer(
                      selectedView: _selectedView,
                      onlyFavorites: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
