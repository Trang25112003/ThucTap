import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/recruiter_account_model.dart';

class AccountService {
  static final _client = Supabase.instance.client;

  // Lấy danh sách theo vai trò (user hoặc recruiter)
  static Future<List<RecruiterAccount>> fetchAccountsByRole(String role) async {
    final response = await _client
        .from('accounts')
        .select()
        .eq('role', role)
        .order('created_at', ascending: false);

    return (response as List).map((e) => RecruiterAccount.fromMap(e)).toList();
  }

  // Duyệt tài khoản (is_approved = true)
  static Future<bool> updateApproval(String accountId, bool isApproved) async {
    try {
      final response = await _client
          .from('accounts')
          .update({'is_approved': isApproved})
          .eq('id', accountId)
          .select();

      return (response as List).isNotEmpty;
    } catch (e) {
      print('Lỗi khi cập nhật trạng thái duyệt: $e');
      return false;
    }
  }

  // Khóa hoặc mở khóa tài khoản (is_active = true/false)
  static Future<bool> updateActiveStatus(String accountId, bool isActive) async {
    try {
      final response = await _client
          .from('accounts')
          .update({'is_active': isActive})
          .eq('id', accountId)
          .select();

      return (response as List).isNotEmpty;
    } catch (e) {
      print('Lỗi khi cập nhật trạng thái active: $e');
      return false;
    }
  }

  // Dùng riêng cho trường hợp chỉ muốn lấy recruiter
  static Future<List<RecruiterAccount>> fetchRecruiterAccounts() async {
    return fetchAccountsByRole('recruiter');
  }
}
