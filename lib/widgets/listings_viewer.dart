import 'package:flutter/material.dart';
import 'package:xdeal/dummy_data.dart';
import 'package:xdeal/widgets/property_listing.dart';
import 'package:xdeal/widgets/vehicle_listing.dart';

// TODO: fetch real data
// TODO: implement infinite scrolling

class ListingsViewer extends StatefulWidget {
  final int selectedView;
  const ListingsViewer({super.key, required this.selectedView});

  @override
  State<ListingsViewer> createState() => _ListingsViewerState();
}

class _ListingsViewerState extends State<ListingsViewer> {
  @override
  Widget build(BuildContext context) {
    final listings = widget.selectedView == 0
        ? DummyData.propertiesListings
        : DummyData.vehiclesListings;

    return Column(
      children:
          listings
              .map((listing) {
                return widget.selectedView == 0
                    ? PropertyListing(property: listing)
                    : VehicleListing(vehicle: listing);
              })
              .expand((widget) => [widget, const SizedBox(height: 24)])
              .toList()
            ..removeLast(), // remove the last gap
    );
  }
}
