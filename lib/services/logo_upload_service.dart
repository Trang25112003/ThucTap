import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class LogoUploadService {
  // Hàm tải logo lên Supabase Storage
  Future<String> uploadCompanyLogo(String companyName, File imageFile) async {
    final supabase = Supabase.instance.client;

    final filePath = 'avatars/$companyName.png';

    try {
      // Tải logo lên bucket 'avatars'
      final response =
          await supabase.storage.from('avatars').upload(filePath, imageFile);

      // // Kiểm tra lỗi nếu có
      // if (response.error != null) {
      //   throw response.error!;
      // }

      // Lấy URL công khai của ảnh
      final logoUrl = supabase.storage.from('avatars').getPublicUrl(filePath);

      return logoUrl;
    } catch (e) {
      print("Lỗi upload ảnh: $e");
      return '';
    }
  }
}
