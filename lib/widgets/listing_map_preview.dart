import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ListingMapPreview extends StatelessWidget {
  final Map<String, dynamic> listing;
  const ListingMapPreview({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    print(listing);
    return SizedBox(
      height: 250,
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(listing['coords'][0], listing['coords'][1]),
          zoom: 14,
        ),
        markers: {
          Marker(
            markerId: MarkerId('vehicle'),
            position: LatLng(listing['coords'][0], listing['coords'][1]),
            infoWindow: InfoWindow(
              title: listing!['name'],
              snippet: "Vehicle location",
            ),
          ),
        },
        zoomControlsEnabled: true,
        myLocationButtonEnabled: false,
      ),
    );
  }
}
