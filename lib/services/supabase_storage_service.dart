import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseStorageService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<String?> uploadFile(
    File file,
    String bucketName,
    String fileName,
  ) async {
    try {
      final response = await _client.storage
          .from(bucketName)
          .upload(fileName, file);
      if (response.isEmpty) {
        throw Exception('File upload failed.');
      }
      // Get the public URL of the uploaded file
      final publicUrl = _client.storage.from(bucketName).getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }

  Future<List<String>> listFiles(String bucketName) async {
    try {
      final response = await _client.storage.from(bucketName).list();
      if (response.isEmpty) {
        throw Exception('No files found in the bucket.');
      }
      return response.map((file) => file.name).toList();
    } catch (e) {
      print('Error listing files: $e');
      return [];
    }
  }

  Future<bool> deleteFile(String bucketName, String fileUrl) async {
    try {
      final fileName = fileUrl.split('/').last;
      final response = await _client.storage.from(bucketName).remove([
        fileName,
      ]);
      if (response.isEmpty) {
        throw Exception('File deletion failed.');
      }
      return true;
    } catch (e) {
      print('Error deleting file: $e');
      return false;
    }
  }
}
