import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/job_model.dart';

class SupabaseService {
  final SupabaseClient supabase = Supabase.instance.client;
    static final _client = Supabase.instance.client;


  /// Đăng ký tài khoản
  Future<User?> register(
    String email,
    String password,
    String name,
    String phone,
    String role, {
    String? companyName,
    String? companyAddress,
  }) async {
    try {
      print("🟢 Bắt đầu đăng ký...");

      final AuthResponse response = await supabase.auth.signUp(
        email: email.trim(),
        password: password.trim(),
      );

      final User? user = response.user;
      if (user == null) {
        print("❌ Đăng ký thất bại!");
        throw Exception('Register failed');
      }

      print("✅ Đăng ký thành công, User ID: ${user.id}");

      // Nếu là nhà tuyển dụng, cần admin duyệt (is_approved = false)
      bool isApproved = role == "recruiter" ? false : true;

      // Thêm vào bảng accounts
      await supabase.from('accounts').insert({
        'id': user.id,
        'name': name,
        'numberPhone': phone,
        'email': email,
        'role': role,
        'is_approved': isApproved,
        'created_at': DateTime.now().toIso8601String(),
      });

      print("✅ Thêm vào bảng accounts thành công!");

      if (role == 'job_seeker') {
        await supabase.from('users').insert({
          'id': user.id,
          'name': name,
          'email': email,
          'avatar': '',
          'myCV': '',
          'favoriteJobs': [],
          'account_id': user.id,
        });
        print("✅ Thêm vào bảng users thành công!");
      } else if (role == 'recruiter') {
        await supabase.from('business').insert({
          'id': user.id,
          'email': email,
          'name': companyName ?? name,
          'phone': phone,
          'address': companyAddress ?? "",
          'website': '',
          'myJobs': [],
          'account_id': user.id,
        });
        print("✅ Thêm vào bảng business thành công!");
      }

      // Nếu là nhà tuyển dụng, báo họ chờ duyệt
      if (!isApproved) {
  print(" Tài khoản recruiter cần admin duyệt.");
      }

      return user;
    } catch (e) {
      print("🚨 Lỗi đăng ký: $e");
      throw Exception('SignUp error: ${e.toString()}');
    }
  }

  /// Đăng nhập bằng email và password
 Future<Map<String, dynamic>> loginWithEmail(String email, String password) async {
  try {
    final AuthResponse response = await supabase.auth.signInWithPassword(
      email: email.trim(),
      password: password.trim(),
    );

    final User? user = response.user;
    if (user == null) {
      throw Exception('Login failed: Invalid credentials');
    }

    final userId = user.id;

    final userAccount = await supabase
        .from('accounts')
        .select('*, business(*)') // Chọn tất cả từ 'accounts' và lồng thông tin từ bảng 'business'
        .eq('id', userId)
        .maybeSingle();

    if (userAccount == null) {
      throw Exception('Tài khoản không tồn tại.');
    }

    if (userAccount['role'] == 'recruiter' && userAccount['is_approved'] == false) {
      await supabase.auth.signOut();
      throw Exception('Tài khoản của bạn đang chờ duyệt. Vui lòng đợi admin.');
    }

    return userAccount; // Trả về toàn bộ thông tin tài khoản (bao gồm cả 'business' nếu có)
  } catch (e) {
    throw Exception('Login error: ${e.toString()}');
  }
}


  /// Đăng nhập với Google
  Future<void> loginWithGoogle() async {
    try {
      await supabase.auth.signInWithOAuth(OAuthProvider.google);
    } catch (e) {
      print("❌ Google Sign-In Error: $e");
    }
  }

  /// Đăng xuất
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  /// Lấy thông tin người dùng theo role
  Future<Map<String, dynamic>> getUserData(String userId, String role) async {
    try {
      final String table = role == 'job_seeker' ? 'users' : 'business';
      final response = await supabase
          .from(table)
          .select()
          .eq('account_id', userId)
          .maybeSingle();

      if (response == null || response.isEmpty) {
        throw Exception('Không tìm thấy dữ liệu cho người dùng role: $role');
      }

      return response;
    } catch (e) {
      throw Exception('Lỗi lấy dữ liệu người dùng: ${e.toString()}');
    }
  }

  /// Upload ảnh lên Supabase Storage
  Future<String?> uploadLogo(File imageFile, String businessId) async {
    try {
      final String storagePath = 'logos/$businessId.png';

     final response = await supabase.storage
    .from('logos')
    .upload('logos/$businessId.png', imageFile);

print('Upload thành công! File path: $response');


      // Trả về URL ảnh đã upload
      final String publicUrl = supabase.storage.from('logos').getPublicUrl(storagePath);
      return publicUrl;
    } catch (error) {
      print("❌ Lỗi upload ảnh: $error");
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> fetchRecruiterJobs(String recruiterId) async {
  try {
    final List<dynamic> response = await supabase
        .from('jobs')
        .select('id, position, salary')
        .eq('businessId', recruiterId)
        .order('created_at', ascending: false);

    return response.cast<Map<String, dynamic>>();
  } catch (e) {
    throw Exception('Lỗi lấy công việc: ${e.toString()}');
  }
}

Future<String?> getBusinessLogoUrl(String businessId) async {
  try {
    final response = await supabase
        .from('business')
        .select('logo_url')
        .eq('id', businessId)
        .maybeSingle();

    return response?['logo_url'];
  } catch (e) {
    throw Exception('Lỗi lấy URL logo công ty: ${e.toString()}');
  }
}



  /// Cập nhật URL logo vào database
  Future<void> updateBusinessLogo(String businessId, String logoUrl) async {
    await supabase.from('business').update({'logo_url': logoUrl}).eq('id', businessId);
  }

  /// Lấy danh sách công việc có logo
  Future<List<Map<String, dynamic>>> fetchJobs() async {
    try {
      final List<dynamic> response = await supabase
          .from('jobs')
          .select('id, position, salary, business(name, logo_url)')
          .order('created_at', ascending: false)
          .limit(10);

      return response.cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Lỗi lấy danh sách công việc: ${e.toString()}');
    }
  }

  // Fetch job by id
  static Future<Job?> fetchJobById(String jobId) async {
    final response = await _client
        .from('jobs')
        .select('id, business_id, position, salary, content, business(id, name, avatar)')
        .eq('id', jobId)
        .single();

    return Job.fromJson(response);
      return null;
  }

  // Create a new job post
  static Future<void> createJobPost(Job job) async {
    try {
      await _client.from('jobs').insert({
        'business_id': job.business_id,
        'position': job.position,
        'levels': job.levels,
        'salary': job.salary,
        'content': job.content,
        'skills': job.skills,
        'types': job.types,
        'requirement': job.requirement,
        'quantity': job.quantity,
        'benefit': job.benefit,
        'startDay': job.startDay,
        'endDay': job.endDay,
        'view_count': job.view_count,
        'isApprove': job.isApprove,
        'isHidden': job.isHidden,
        'created_at': job.createdAt?.toIso8601String(),
        'status': job.status,
        'city': job.city,
      });
    } catch (e) {
      throw Exception('Lỗi tạo job: ${e.toString()}');
    }
  }
  
}
