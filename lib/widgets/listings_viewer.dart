import 'package:flutter/material.dart';
import 'package:xdeal/dummy_data.dart';
import 'package:xdeal/widgets/property_listing.dart';
import 'package:xdeal/widgets/vehicle_listing.dart';

// TODO: fetch real data
// TODO: implement infinite scrolling

enum ListingFilter { none, newest, cheapest, expensive }

class ListingsViewer extends StatefulWidget {
  final int selectedView;
  final bool isDealerProfile;
  final ListingFilter filter;
  const ListingsViewer({
    super.key,
    required this.selectedView,
    required this.isDealerProfile,
    this.filter = ListingFilter.newest,
  });

  @override
  State<ListingsViewer> createState() => _ListingsViewerState();
}

class _ListingsViewerState extends State<ListingsViewer> {
  @override
  Widget build(BuildContext context) {
    // initial list
    final listings = widget.selectedView == 0
        ? DummyData.propertiesListings
        : DummyData.vehiclesListings;

    // apply filter
    switch (widget.filter!) {
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
      case ListingFilter.none:
        // no filter, do nothing
        break;
    }

    return Column(
      children:
          listings
              .map((listing) {
                return widget.selectedView == 0
                    ? PropertyListing(
                        property: listing,
                        isDealerProfile: widget.isDealerProfile,
                      )
                    : VehicleListing(
                        vehicle: listing,
                        isDealerProfile: widget.isDealerProfile,
                      );
              })
              .expand((widget) => [widget, const SizedBox(height: 24)])
              .toList()
            ..removeLast(), // remove the last gap
    );
  }
}
