
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String?> uploadImage(File imageFile, String fileName) async {
    try {
      // Upload ảnh lên Supabase Storage
      await _supabase.storage
          .from('job-images') // Thay bằng tên bucket bạn đã tạo
          .upload(fileName, imageFile);

      // Lấy URL công khai của ảnh
      final imageUrl = _supabase.storage.from('job-images').getPublicUrl(fileName);
      return imageUrl;
    } catch (e) {
      print(' Lỗi khi upload ảnh: $e');
      return null;
    }
  }
}
