import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/business_model.dart';

class BusinessService {
  static final _client = Supabase.instance.client;

  static Future<List<Business>> fetchAllBusinesses() async {
    final response = await _client
        .from('business')
        .select('id, name, avatar,is_active');
        

    return (response as List)
        .map((e) => Business.fromJson(e))
        .toList();
  }

  static Future<List<Business>> fetchBusinessesByName(String businessName) async {
    final response = await _client
        .from('business')
        .select('id, name, avatar')
        .eq('name', businessName);

    return (response as List)
        .map((e) => Business.fromJson(e))
        .toList();
  }

  static Future<Business> createBusiness(String name, String avatar) async {
    final response = await _client
        .from('business')
        .insert({
          'name': name,
          'avatar': avatar,
        });
    if (response.error != null) {
      throw Exception('Error creating business: ${response.error!.message}');
    }

    return Business.fromJson(response.data[0]);
  }

  // Thêm phương thức cập nhật doanh nghiệp
  static Future<Business> updateBusiness(int businessId, String name, String avatar) async {
    final response = await _client
        .from('business')
        .update({
          'name': name,
          'avatar': avatar,
        })
        .eq('id', businessId);

    if (response.error != null) {
      throw Exception('Error updating business: ${response.error!.message}');
    }

    // Trả về đối tượng Business đã cập nhật
    return Business.fromJson(response.data[0]);
  }
static Future<void> updateBusinessStatus(String businessId, bool isActive) async {
  try {
    await Supabase.instance.client
        .from('business')
        .update({'is_active': isActive})
        .eq('id', businessId);
  } catch (e) {
    print('Lỗi khi cập nhật trạng thái: $e');
    rethrow;
  }
}



}
