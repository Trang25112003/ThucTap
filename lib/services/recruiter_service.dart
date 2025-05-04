import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/recruiter_account_model.dart';

class RecruiterService {
  static final _client = Supabase.instance.client;

  Future<List<RecruiterAccount>> getAllRecruiters() async {
    try {
      final response = await _client
          .from('accounts')
          .select()
          .eq('role', 'recruiter');

      final List<RecruiterAccount> recruiters = (response as List<dynamic>)
          .map((item) => RecruiterAccount.fromMap(item as Map<String, dynamic>))
          .toList();

      return recruiters;
    } catch (e) {
      print('❌ Lỗi khi lấy danh sách nhà tuyển dụng: $e');
      return [];
    }
  }

  // Thêm hàm để lấy recruiterAccount theo user id
  Future<RecruiterAccount?> getRecruiterByUserId(String userId) async {
    try {
      final response = await _client
          .from('accounts')
          .select()
          .eq('id', userId)
          .eq('role', 'recruiter')
          .maybeSingle();

      if (response == null) {
        print('❌ Không tìm thấy nhà tuyển dụng với user id: $userId');
        return null;
      }

      return RecruiterAccount.fromMap(response as Map<String, dynamic>);
    } catch (e) {
      print('❌ Lỗi khi lấy thông tin nhà tuyển dụng: $e');
      return null;
    }
  }
}