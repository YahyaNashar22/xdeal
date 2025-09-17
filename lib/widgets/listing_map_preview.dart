import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:xdeal/utils/utility_functions.dart';

class ListingMapPreview extends StatelessWidget {
  final Map<String, dynamic> listing;
  const ListingMapPreview({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadiusGeometry.circular(12),
            child: SizedBox(
              height: 250,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(listing['coords'][0], listing['coords'][1]),
                  zoom: 14,
                  tilt: 45.0,
                ),
                markers: {
                  Marker(
                    markerId: MarkerId('vehicle'),
                    position: LatLng(
                      listing['coords'][0],
                      listing['coords'][1],
                    ),
                    infoWindow: InfoWindow(
                      title: listing['name'],
                      snippet: "Vehicle location",
                    ),
                  ),
                },
                zoomControlsEnabled: true,
                myLocationButtonEnabled: false,
                mapType: MapType.hybrid,
                buildingsEnabled: true,
                tiltGesturesEnabled: true,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              minimumSize: Size(double.infinity, 30),
            ),
            onPressed: () => UtilityFunctions.openMapsAtCoords([
              listing['coords'][0],
              listing['coords'][1],
            ]),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.directions),
                const SizedBox(width: 12),
                const Text('Get directions'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
