import 'package:flutter/material.dart';
import 'package:xdeal/dummy_data.dart';
import 'package:xdeal/widgets/property_listing.dart';
import 'package:xdeal/widgets/vehicle_listing.dart';

// TODO: fetch real data
// TODO: implement infinite scrolling

enum ListingFilter { none, newest, cheapest, expensive, notListed }

class ListingsViewer extends StatefulWidget {
  final int selectedView;
  final bool isDealerProfile;
  final bool isUploaderViewing;
  final bool onlyFavorites;
  final ListingFilter filter;
  const ListingsViewer({
    super.key,
    required this.selectedView,
    this.isDealerProfile = false,
    this.isUploaderViewing = false,
    this.onlyFavorites = false,
    this.filter = ListingFilter.newest,
  });

  @override
  State<ListingsViewer> createState() => _ListingsViewerState();
}

class _ListingsViewerState extends State<ListingsViewer> {
  @override
  Widget build(BuildContext context) {
    // initial list

    List<Map<String, dynamic>> originalListings;
    if (widget.onlyFavorites) {
      originalListings = widget.selectedView == 0
          ? DummyData.favoritesProperties
          : DummyData.favoritesVehicles;
    } else {
      originalListings = widget.selectedView == 0
          ? DummyData.propertiesListings
          : DummyData.vehiclesListings;
    }
    // filtered listings

    // 🚩 always show only listed items by default
    var listings = originalListings
        .where((item) => item['is_listed'] == true)
        .toList();

    // apply filter
    switch (widget.filter) {
      case ListingFilter.newest:
        listings.sort(
          (a, b) => DateTime.parse(
            b['createdAt'],
          ).compareTo(DateTime.parse(a['createdAt'])),
        );
        break;
      case ListingFilter.cheapest:
        listings.sort(
          (a, b) => int.parse(a['price']).compareTo(int.parse(b['price'])),
        );
        break;
      case ListingFilter.expensive:
        listings.sort(
          (a, b) => int.parse(b['price']).compareTo(int.parse(a['price'])),
        );
        break;
      case ListingFilter.notListed:
        listings = originalListings
            .where((item) => item['is_listed'] == false)
            .toList();
        break;
      case ListingFilter.none:
        // no filter, do nothing
        break;
    }

    // if no listings, show a placeholder
    if (listings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'No current listings',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ),
      );
    }

    // build listing widgets
    var children = listings
        .map((listing) {
          return widget.selectedView == 0
              ? PropertyListing(
                  property: listing,
                  isDealerProfile: widget.isDealerProfile,
                  isUploaderViewing: widget.isUploaderViewing,
                )
              : VehicleListing(
                  vehicle: listing,
                  isDealerProfile: widget.isDealerProfile,
                  isUploaderViewing: widget.isUploaderViewing,
                );
        })
        .expand((w) => [w, const SizedBox(height: 24)])
        .toList();

    if (children.isNotEmpty) children.removeLast();

    return Column(children: children);
  }
}
