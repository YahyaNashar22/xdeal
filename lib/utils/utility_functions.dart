import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

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

  static Future<void> launchEmail(String email) async {
    final Uri uri = Uri(scheme: 'mailto', path: email);
    if (!await launchUrl(uri)) {
      throw 'Could not launch $uri';
    }
  }

  static Future<void> launchCall(String phone) async {
    final Uri uri = Uri(scheme: 'tel', path: phone);
    if (!await launchUrl(uri)) {
      throw 'Could not launch $uri';
    }
  }

  static Future<void> launchWhatsApp(String phone) async {
    // phone should be in international format without '+' sign for wa.me
    final cleaned = phone.replaceAll('+', '');
    final Uri uri = Uri.parse('https://wa.me/$cleaned');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $uri';
    }
  }

  static Future<void> openMapsAtCoords(List<double> coords) async {
    if (coords.length != 2) {
      throw ArgumentError('coords must be [latitude, longitude]');
    }

    final double lat = coords[0];
    final double lng = coords[1];

    // First try Apple Maps on iOS
    final Uri appleUri = Uri.parse('http://maps.apple.com/?q=$lat,$lng');

    // Google Maps link
    final Uri googleUri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );

    // Android geo scheme (works with many map apps)
    final Uri geoUri = Uri.parse('geo:$lat,$lng?q=$lat,$lng');

    // Android: try geo: scheme (native Maps)
    if (await canLaunchUrl(geoUri)) {
      await launchUrl(geoUri);
      return;
    }

    // iOS: try Apple Maps
    if (await canLaunchUrl(appleUri)) {
      await launchUrl(appleUri);
      return;
    }

    // Fallback: open Google Maps link (app or browser)
    await launchUrl(googleUri, mode: LaunchMode.externalApplication);
  }
}
