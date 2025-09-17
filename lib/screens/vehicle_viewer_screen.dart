import 'package:flutter/material.dart';
import 'package:xdeal/dummy_data.dart';

class VehicleViewerScreen extends StatefulWidget {
  final String vehicleId;
  const VehicleViewerScreen({super.key, required this.vehicleId});

  @override
  State<VehicleViewerScreen> createState() => _VehicleViewerScreenState();
}

class _VehicleViewerScreenState extends State<VehicleViewerScreen> {
  Map<String, dynamic>? _vehicle;
  @override
  initState() {
    super.initState();
    setState(() {
      _vehicle = DummyData.vehiclesListings
          .where((v) => v['_id'] == widget.vehicleId)
          .first;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(_vehicle!['name']);
  }
}
