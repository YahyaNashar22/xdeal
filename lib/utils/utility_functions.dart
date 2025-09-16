import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class UtilityFunctions {
  static final String _googleApiKey = dotenv.env['GOOGLE_API_KEY'] ?? '';
  // Formats a price like 135000 -> 135,000
  static String formatPrice(dynamic price) {
    // make sure it's int
    final intValue = int.tryParse(price.toString()) ?? 0;
    final formatter = NumberFormat('#,###');
    return formatter.format(intValue);
  }

  // Given coords [latitude, longitude], returns a human readable address string
  static Future<String> getLocationFromCoordinatesGoogle(
    double latitude,
    double longitude,
  ) async {
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json'
        '?latlng=$latitude,$longitude&key=$_googleApiKey&language=en',
      );

      final response = await http.get(url);

      if (response.statusCode != 200) {
        debugPrint('Google geocode failed: ${response.body}');
        return 'Unknown location';
      }

      final data = jsonDecode(response.body);

      if (data['status'] != 'OK' || (data['results'] as List).isEmpty) {
        return 'Unknown location';
      }

      final results = data['results'] as List;
      final firstResult = results[0];
      final components = firstResult['address_components'] as List;

      String? locality;

      for (var component in components) {
        final types = (component['types'] as List).cast<String>();
        if (types.contains('locality')) {
          locality = component['long_name'] as String;
          break;
        }
      }

      return locality ?? 'Unknown location';
    } catch (e, st) {
      debugPrint('Error in Google reverse geocoding: $e\n$st');
      return 'Unknown location';
    }
  }

  // Converts a DateTime to dd/MM/yyyy
  static String formatDate(dynamic date) {
    final parsedDate = DateTime.parse(date);
    final day = parsedDate.day.toString().padLeft(2, '0');
    final month = parsedDate.month.toString().padLeft(2, '0');
    final year = parsedDate.year.toString();
    return '$day/$month/$year';
  }
}
