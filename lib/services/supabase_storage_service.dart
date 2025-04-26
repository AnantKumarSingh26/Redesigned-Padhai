import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseStorageService {
  final SupabaseClient _client;

  SupabaseStorageService()
      : _client = SupabaseClient(
          'https://zosqvsxkchwuiuyyoyvg.supabase.co',
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inpvc3F2c3hrY2h3dWl1eXlveXZnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDU0NjU5NDEsImV4cCI6MjA2MTA0MTk0MX0.BWB4DWzGj6mqJQ7GAIbNiXoXo-aV6KWMQC3jvq1umTY',
        );

  Future<String?> uploadMaterial(File file, String fileName) async {
    try {
      final response = await _client.storage.from('materials').uploadBinary(fileName, await file.readAsBytes());
      if (response.isEmpty) {
        return _client.storage.from('materials').getPublicUrl(fileName);
      } else {
        throw Exception('Failed to upload file: $response');
      }
    } catch (e) {
      print('Error uploading material: $e');
      return null;
    }
  }

  Future<List<String>> listMaterials() async {
    try {
      final response = await _client.storage.from('materials').list();
      return response.map((item) => _client.storage.from('materials').getPublicUrl(item.name)).toList();
    } catch (e) {
      print('Error listing materials: $e');
      return [];
    }
  }

  Future<void> deleteMaterial(String fileName) async {
    try {
      final response = await _client.storage.from('materials').remove([fileName]);
      if (response.isNotEmpty) {
        throw Exception('Failed to delete file: $response');
      }
    } catch (e) {
      print('Error deleting material: $e');
    }
  }
}