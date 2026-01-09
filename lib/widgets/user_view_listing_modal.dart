import 'package:flutter/material.dart';
import 'package:xdeal/dummy_data.dart';
import 'package:xdeal/utils/app_colors.dart';
import 'package:xdeal/widgets/custom_appbar.dart';

class UserViewListingModal extends StatefulWidget {
  final int listingType;
  final String listingId;
  const UserViewListingModal({
    super.key,
    required this.listingType,
    required this.listingId,
  });

  @override
  State<UserViewListingModal> createState() => _UserViewListingModalState();
}

class _UserViewListingModalState extends State<UserViewListingModal> {
  Map<String, dynamic>? _listing;
  @override
  void initState() {
    super.initState();
    if (widget.listingType == 0) {
      setState(() {
        _listing = DummyData.propertiesListings
            .where((item) => item['_id'] == widget.listingId)
            .first;
      });
    } else {
      setState(() {
        _listing = DummyData.vehiclesListings
            .where((item) => item['_id'] == widget.listingId)
            .first;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: 500,
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          // listing name
          Center(
            child: Text(
              _listing!['name'],
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Spacer(),
          InkWell(
            onTap: () => debugPrint("Tapped"),
            child: SizedBox(
              width: double.infinity,
              height: 100,
              child: Card(
                elevation: 6,
                shadowColor: AppColors.black,
                color: AppColors.greyBg,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 40),
                      const SizedBox(width: 8),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Sponsor this listing",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text("Get top placement and premium exposure"),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Feature listing
          InkWell(
            onTap: () => debugPrint("Tapped"),
            child: SizedBox(
              width: double.infinity,
              height: 100,
              child: Card(
                elevation: 6,
                shadowColor: AppColors.black,
                color: AppColors.greyBg,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.query_stats_sharp,
                        color: Colors.blue,
                        size: 40,
                      ),
                      const SizedBox(width: 8),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Feature this listing",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text("increase visibility and attract more views"),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Spacer(),
          // view
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 40),
              backgroundColor: AppColors.inputBg,
            ),
            onPressed: () {},
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.remove_red_eye_outlined,
                  size: 25,
                  color: AppColors.black,
                ),
                const SizedBox(width: 4),
                Text("View Listing", style: TextStyle(color: AppColors.black)),
              ],
            ),
          ),
          const SizedBox(height: 3),
          // edit
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 40),
              backgroundColor: AppColors.inputBg,
            ),
            onPressed: () {},
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.edit_outlined, size: 25, color: AppColors.primary),
                const SizedBox(width: 4),
                Text("Edit Listing", style: TextStyle(color: AppColors.black)),
              ],
            ),
          ),
          const SizedBox(height: 3),
          // delete
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 40),
              backgroundColor: AppColors.inputBg,
            ),
            onPressed: () {},
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.delete_outlined, size: 25, color: AppColors.red),
                const SizedBox(width: 4),
                Text(
                  "Delete Listing",
                  style: TextStyle(color: AppColors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
