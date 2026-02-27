import 'package:flutter/material.dart';
import 'package:xdeal/services/api_client.dart';
import 'package:xdeal/utils/app_colors.dart';
import 'package:xdeal/utils/utility_functions.dart';
import 'package:xdeal/widgets/listings_viewer.dart';

class DealerProfileScreen extends StatefulWidget {
  final String dealerId;
  const DealerProfileScreen({super.key, required this.dealerId});

  @override
  State<DealerProfileScreen> createState() => _DealerProfileScreenState();
}

class _DealerProfileScreenState extends State<DealerProfileScreen> {
  final ApiClient _api = ApiClient(baseUrl: 'http://10.0.2.2:5000');

  int _selectedView = 0; // 0 properties, 1 vehicles
  final String _q = '';
  String? _categoryId;
  ListingFilter _selectedFilter = ListingFilter.newest;

  bool _loading = true;
  String? _error;

  String _dealerName = 'Unknown';
  String _dealerEmail = '';
  String _dealerPhone = '';
  String _dealerPicture = '';
  int _numberOfListings = 0;

  @override
  void initState() {
    super.initState();
    _loadDealerProfile();
  }

  Future<void> _loadDealerProfile() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _api.getJson('/api/v1/users/${widget.dealerId}'),
        _api.getJson(
          '/api/v1/vehicle-listing',
          query: {'user_id': widget.dealerId, 'page': '1', 'limit': '1'},
        ),
        _api.getJson(
          '/api/v1/property-listing',
          query: {'user_id': widget.dealerId, 'page': '1', 'limit': '1'},
        ),
      ]);

      final userRes = results[0];
      final vehicleRes = results[1];
      final propertyRes = results[2];

      final vehicleTotal = (vehicleRes is Map && vehicleRes['total'] is num)
          ? (vehicleRes['total'] as num).toInt()
          : 0;
      final propertyTotal = (propertyRes is Map && propertyRes['total'] is num)
          ? (propertyRes['total'] as num).toInt()
          : 0;

      final user = (userRes is Map) ? Map<String, dynamic>.from(userRes) : null;

      if (!mounted) return;
      setState(() {
        _numberOfListings = vehicleTotal + propertyTotal;
        _dealerName = (user?['full_name'] ?? user?['name'] ?? 'Unknown')
            .toString();
        _dealerEmail = (user?['email'] ?? '').toString();
        _dealerPhone = (user?['phone_number'] ?? user?['phone'] ?? '')
            .toString();
        _dealerPicture = (user?['profile_picture'] ?? '').toString();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showPhonePopup(BuildContext context) {
    final phoneNumber = _dealerPhone.isEmpty ? 'Unknown' : _dealerPhone;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Contact Owner"),
        content: Text("Would you like to call $phoneNumber?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              UtilityFunctions.launchCall(phoneNumber);
            },
            child: const Text("Call Now"),
          ),
        ],
      ),
    );
  }

  void _selectView(int view) {
    setState(() => _selectedView = view);
  }

  void _selectFilter(ListingFilter filter) {
    setState(() {
      if (_selectedFilter == filter) {
        _selectedFilter = ListingFilter.newest;
      } else {
        _selectedFilter = filter;
      }
    });
  }

  TextStyle _selectedBtnStyle(int view) {
    return TextStyle(
      color: _selectedView == view ? AppColors.primary : AppColors.black,
    );
  }

  Widget _filterBtn(String label, ListingFilter filter) {
    final selected = _selectedFilter == filter;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: selected ? AppColors.primary : AppColors.inputBg,
      ),
      onPressed: () => _selectFilter(filter),
      child: Text(
        label,
        style: TextStyle(color: selected ? AppColors.white : AppColors.black),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    void handleBottomNavTap(int index) {
      switch (index) {
        case 0:
          if (_dealerEmail.isNotEmpty) {
            UtilityFunctions.launchEmail(_dealerEmail);
          }
          break;
        case 1:
          _showPhonePopup(context);
          break;
        case 2:
          if (_dealerPhone.isNotEmpty) {
            UtilityFunctions.launchWhatsApp(_dealerPhone);
          }
          break;
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back, color: AppColors.black),
        ),
        title: Text('Dealer Profile', style: TextStyle(color: AppColors.black)),
        actions: [Image.asset('assets/icons/logo_purple_large.png', width: 50)],
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: handleBottomNavTap,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.email_outlined),
            label: 'Email',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.phone_forwarded_outlined),
            label: 'Phone',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/icons/whatsapp.png'),
            label: 'Whatsapp',
          ),
        ],
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Failed to load dealer profile:\n$_error'),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _loadDealerProfile,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: _dealerPicture.trim().isEmpty
                            ? Container(
                                width: 120,
                                height: 120,
                                color: AppColors.greyBg,
                                alignment: Alignment.center,
                                child: const Icon(Icons.person, size: 44),
                              )
                            : Image.network(
                                UtilityFunctions.resolveImageUrl(_dealerPicture),
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 120,
                                  height: 120,
                                  color: AppColors.greyBg,
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.person, size: 44),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        _dealerName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (_dealerEmail.isNotEmpty)
                      Center(
                        child: Text(
                          _dealerEmail,
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.greyBg),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: Column(
                          children: [
                            Text(
                              _numberOfListings.toString(),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Number of Listings",
                              style: TextStyle(color: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => _selectView(0),
                          child: Text("Properties", style: _selectedBtnStyle(0)),
                        ),
                        TextButton(
                          onPressed: () => _selectView(1),
                          child: Text("Vehicles", style: _selectedBtnStyle(1)),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 8),
                    const Text(
                      "Filter",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                    ),
                    const SizedBox(height: 6),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _filterBtn("Cheapest", ListingFilter.cheapest),
                          const SizedBox(width: 8),
                          _filterBtn("Expensive", ListingFilter.expensive),
                          const SizedBox(width: 8),
                          _filterBtn("Newest", ListingFilter.newest),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListingsViewer(
                        selectedView: _selectedView,
                        isDealerProfile: true,
                        filter: _selectedFilter,
                        q: _q,
                        categoryId: _categoryId,
                        userId: widget.dealerId,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
