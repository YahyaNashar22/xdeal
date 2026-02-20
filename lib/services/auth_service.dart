import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:xdeal/models/user.dart';

class AuthService {
  static const String baseUrl = "http://10.0.2.2:5000/api/v1/auth";

  static Future<Map<String, dynamic>> signin({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse("$baseUrl/signin");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) return data;

    throw Exception(data['message'] ?? data['error'] ?? "Sign in failed");
  }

  static Future<bool> signup({
    required String fullName,
    required String email,
    required String password,
    required String address,
    required String phone,
  }) async {
    final url = Uri.parse("$baseUrl/signup");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "full_name": fullName,
        "email": email,
        "password": password,
        "address": address,
        "phone_number": phone,
      }),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      throw Exception(jsonDecode(response.body)["message"] ?? "Signup failed");
    }
  }

  static Future<void> sendOtp(String email) async {
    final url = Uri.parse("$baseUrl/send-otp");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to send OTP");
    }
  }

  static Future<void> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final url = Uri.parse("$baseUrl/verify-otp");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "otp": otp}),
    );

    if (response.statusCode != 200) {
      throw Exception("Invalid or expired OTP");
    }
  }

  static Future<User> getCurrentUser(String token) async {
    final url = Uri.parse("$baseUrl/me");

    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch user");
    }

    final data = jsonDecode(response.body);

    data['token'] = token; // inject token

    return User.fromJson(data);
  }
}
