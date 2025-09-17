import 'package:flutter/material.dart';
import 'package:xdeal/dummy_data.dart';
import 'package:xdeal/widgets/property_listing.dart';

// TODO: fetch real data
// TODO: implement infinite scrolling

class PropertiesListings extends StatefulWidget {
  const PropertiesListings({super.key});

  @override
  State<PropertiesListings> createState() => _PropertiesListingsState();
}

class _PropertiesListingsState extends State<PropertiesListings> {
  @override
  Widget build(BuildContext context) {
    final listings = DummyData.propertiesListings;

    return Column(
      children:
          listings
              .map((property) => PropertyListing(property: property))
              .expand((widget) => [widget, const SizedBox(height: 24)])
              .toList()
            ..removeLast(), // remove the last gap
    );
  }
}
