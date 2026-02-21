// lib/services/upload_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class UploadService {
  final String baseUrl;
  UploadService({required this.baseUrl});

  Future<List<String>> uploadFiles({
    required String type, // "vehicles" | "properties" | "users"
    required List<XFile> files,
  }) async {
    if (files.isEmpty) return [];

    final uri = Uri.parse('$baseUrl/api/v1/uploads/$type');
    final req = http.MultipartRequest('POST', uri);

    for (final f in files) {
      req.files.add(await http.MultipartFile.fromPath('files', f.path));
    }

    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Upload failed (HTTP ${res.statusCode}): ${res.body}');
    }

    final data = jsonDecode(res.body);
    return (data['urls'] as List?)?.map((e) => e.toString()).toList() ??
        <String>[];
  }

  Future<List<String>> uploadVehicleImages(List<XFile> images) {
    return uploadFiles(type: "vehicles", files: images);
  }

  Future<List<String>> uploadPropertyImages(List<XFile> images) {
    return uploadFiles(type: "properties", files: images);
  }

  Future<String> uploadUserAvatar(XFile file) async {
    final urls = await uploadFiles(type: "users", files: [file]);
    if (urls.isEmpty) throw Exception("No url returned");
    return urls.first;
  }
}
