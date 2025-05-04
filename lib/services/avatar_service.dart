import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class AvatarService {
  final SupabaseClient supabase = Supabase.instance.client;

  // Bước 1: Tải ảnh lên Supabase Storage và trả về URL công khai
  Future<String> uploadAvatar(String userId, File imageFile) async {
    final filePath = 'avatars/$userId.png'; // Tên file dựa trên userId để tránh trùng lặp

    try {
      // Tải ảnh lên bucket 'avatars'
      await supabase.storage.from('avatars').upload(filePath, imageFile);

      // Lấy URL công khai của ảnh sau khi tải lên
      final avatarUrl = supabase.storage.from('avatars').getPublicUrl(filePath);

      return avatarUrl; // Trả về trực tiếp URL (là một String)
    } catch (e) {
      print("Lỗi upload ảnh: $e");
      return ''; // Trả về chuỗi rỗng nếu có lỗi
    }
  }

  // Bước 2: Cập nhật URL ảnh vào bảng accounts trong cơ sở dữ liệu Supabase
  Future<void> updateUserAvatar(String userId, String avatarUrl) async {
    try {
      // Cập nhật URL ảnh vào bảng 'accounts'
      await supabase
          .from('accounts')
          .update({'avatar': avatarUrl})
          .eq('account_id', userId); // Giả sử userId là 'account_id' trong bảng accounts

      print('Avatar updated successfully!');
    } catch (e) {
      print("Lỗi cập nhật avatar: $e");
    }
  }

  // Bước 3: Lấy URL ảnh từ cơ sở dữ liệu
  Future<String> _getAvatarUrl(String userId) async {
    try {
      // Lấy thông tin avatar từ bảng 'accounts'
      final response = await supabase
          .from('accounts')
          .select('avatar')
          .eq('account_id', userId)
          .single();

      // Trả về URL của avatar
      return response['avatar'] ?? ''; // Nếu không có avatar thì trả về chuỗi rỗng
    } catch (e) {
      print("Lỗi lấy avatar: $e");
      return ''; // Trả về chuỗi rỗng nếu có lỗi
    }
  }
}