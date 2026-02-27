import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xdeal/localization/app_localizations.dart';
import 'package:xdeal/providers/user_provider.dart';
import 'package:xdeal/utils/app_colors.dart';
import 'package:xdeal/widgets/custom_appbar.dart';
import 'package:xdeal/widgets/listings_viewer.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  // 0 -> Properties
  // 1 -> vehicles
  int _selectedView = 0;

  // filters state
  String _q = '';
  String? _categoryId;

  void _selectView(int view) {
    setState(() {
      _selectedView = view;
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
    final currentUser = context.watch<UserProvider>().user;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppbar(title: "Favorites"),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // properties / vehicles switch
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => _selectView(0),
                          child: Text(
                            context.tr("Properties"),
                            style: _selectedBtnStyle(0),
                          ),
                        ),
                        TextButton(
                          onPressed: () => _selectView(1),
                          child: Text(
                            context.tr("Vehicles"),
                            style: _selectedBtnStyle(1),
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 24),
                    Expanded(
                      child: ListingsViewer(
                        selectedView: _selectedView,
                        onlyFavorites: true,
                        q: _q,
                        categoryId: _categoryId,
                        userId: currentUser?.id,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
