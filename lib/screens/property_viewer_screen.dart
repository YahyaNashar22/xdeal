import 'package:flutter/material.dart';
import 'package:xdeal/dummy_data.dart';

class PropertyViewerScreen extends StatefulWidget {
  final String propertyId;
  const PropertyViewerScreen({super.key, required this.propertyId});

  @override
  State<PropertyViewerScreen> createState() => _PropertyViewerScreenState();
}

class _PropertyViewerScreenState extends State<PropertyViewerScreen> {
  Map<String, dynamic>? _property;
  @override
  initState() {
    super.initState();
    setState(() {
      _property = DummyData.propertiesListings
          .where((p) => p['_id'] == widget.propertyId)
          .first;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(_property!['name']);
  }
}
