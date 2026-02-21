import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class MapPickResult {
  final LatLng latLng;
  final String address;
  const MapPickResult({required this.latLng, required this.address});
}

class MapPickerScreen extends StatefulWidget {
  final LatLng initial;
  const MapPickerScreen({super.key, required this.initial});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  GoogleMapController? _controller;
  LatLng _selected = const LatLng(33.8938, 35.5018); // Beirut default
  String _address = "Move the map to pick a location";
  bool _loadingAddress = false;

  @override
  void initState() {
    super.initState();
    _selected = widget.initial;
    _reverseGeocode(_selected);
  }

  Future<void> _reverseGeocode(LatLng latLng) async {
    setState(() {
      _loadingAddress = true;
    });
    try {
      final placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final parts =
            [
                  p.name,
                  p.street,
                  p.subLocality,
                  p.locality,
                  p.administrativeArea,
                  p.country,
                ]
                .where((e) => e != null && e.trim().isNotEmpty)
                .map((e) => e!.trim())
                .toList();

        setState(() => _address = parts.take(4).join(", "));
      } else {
        setState(() => _address = "${latLng.latitude}, ${latLng.longitude}");
      }
    } catch (_) {
      setState(() => _address = "${latLng.latitude}, ${latLng.longitude}");
    } finally {
      if (mounted) setState(() => _loadingAddress = false);
    }
  }

  Future<void> _goToMyLocation() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enable location services.")),
      );
      return;
    }

    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied)
      perm = await Geolocator.requestPermission();
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location permission denied.")),
      );
      return;
    }

    final pos = await Geolocator.getCurrentPosition();
    final target = LatLng(pos.latitude, pos.longitude);

    await _controller?.animateCamera(CameraUpdate.newLatLngZoom(target, 16));
    setState(() => _selected = target);
    await _reverseGeocode(target);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pick Location"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(
                context,
                MapPickResult(latLng: _selected, address: _address),
              );
            },
            child: const Text("Done", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _selected, zoom: 14),
            onMapCreated: (c) => _controller = c,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            onCameraMove: (pos) => _selected = pos.target,
            onCameraIdle: () => _reverseGeocode(_selected),
          ),

          // Center pin
          Center(
            child: IgnorePointer(
              child: Icon(
                Icons.location_pin,
                size: 46,
                color: Colors.red.shade600,
              ),
            ),
          ),

          // Address card
          Positioned(
            left: 12,
            right: 12,
            top: 12,
            child: Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.place, color: Colors.black54),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _address,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    if (_loadingAddress) const SizedBox(width: 10),
                    if (_loadingAddress)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // My location button
          Positioned(
            right: 14,
            bottom: 14,
            child: FloatingActionButton(
              heroTag: "myLoc",
              onPressed: _goToMyLocation,
              child: const Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }
}
