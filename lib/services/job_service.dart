import 'dart:async';
import 'dart:core';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/job_model.dart';
import '../models/business_model.dart';

class JobService {
  static final _supabase = Supabase.instance.client;

  /// Lấy danh sách công việc và thông tin doanh nghiệp tương ứng
  static Future<List<Job>> _fetchBusinessesForJobs(List<Job> jobs) async {
    if (jobs.isEmpty) return [];

    final businessIds = jobs
        .where((job) => job.business_id != null)
        .map((job) => job.business_id!)
        .toList()
        .toSet()
        .toList();

    if (businessIds.isEmpty) return jobs;

    final response = await _supabase
        .from('business')
        .select('id, name, avatar')
        .inFilter('id', businessIds);
    final businessesMap =
        (response as List).fold<Map<String, Business>>({}, (map, businessJson) {
      final business = Business.fromJson(businessJson);
      map[business.id!] = business;
      return map;
    });

    return jobs.map((job) {
      if (job.business_id != null &&
          businessesMap.containsKey(job.business_id)) {
        return job.copyWith(business: businessesMap[job.business_id]);
      }
      return job;
    }).toList();
  }

  // Lấy danh sách công việc theo doanh nghiệp
  static Future<List<Job>> fetchJobsByBusinessId(String businessId) async {
    try {
      final response = await _supabase
          .from('jobs')
          .select(
              'id, levels, skills, types, requirement, position, salary, content, city, business_id, endDay, status')
          .eq('business_id', businessId);

      return (response as List).map((job) => Job.fromJson(job)).toList();
    } catch (e) {
      print('Lỗi khi lấy công việc theo Business ID: $e');
      return [];
    }
  }

 static Future<Job?> fetchJobDetails(String jobId) async {
  try {
    final response = await _supabase
        .from('jobs')
        .select('*, business:business_id (id, name, avatar)')
        .eq('id', jobId)
        .single();
    
    // Kiểm tra phản hồi
    print('Response from Supabase: $response'); // Xem dữ liệu trả về từ Supabase
    return Job.fromJson(response);
    } catch (e) {
    print('Lỗi khi lấy chi tiết công việc từ Supabase: $e');
    return null;
  }
}


  Future<bool> approveJob(String jobId) async {
    try {
      final response = await _supabase.from('jobs').update({
        'isApprove': true,
        'status': 'approved'
      }) // Cập nhật isApprove và status
          .eq('id', jobId);

      return response.count > 0;
    } catch (e) {
      print('Lỗi khi duyệt công việc trên Supabase: $e');
      return false;
    }
  }

  Future<bool> hideJob(String jobId) async {
    try {
      final response = await _supabase
          .from('jobs')
          .update({'isHidden': true}).eq('id', jobId);
      return response.count > 0;
    } catch (e) {
      print('Lỗi khi ẩn công việc trên Supabase: $e');
      return false;
    }
  }

 
// 🔹 Lấy tất cả công việc (kèm business và người đăng)
static Future<List<Job>> fetchAllJobs({int page = 1, int limit = 50}) async {
  try {
    final response = await _supabase
        .from('jobs')
        .select('*, business:business_id(*, account:account_id(name, avatar))')
        .range((page - 1) * limit, page * limit - 1);

    print("fetchAllJobs Response (raw): $response");

    final List<Job> jobs = (response as List<dynamic>)
        .map((job) => Job.fromJson(job))
        .toList();

    return jobs;
  } catch (e) {
    print('Lỗi khi lấy danh sách công việc: $e');
    return [];
  }
}


  // 🔹 Tìm kiếm công việc theo từ khóa
  static Future<List<Job>> fetchJobsByKeyword(String keyword) async {
    try {
      final List<dynamic> response = await _supabase.from('jobs').select('*').or(
          'position.ilike.%$keyword%,skills.ilike.%$keyword%,types.ilike.%$keyword%');

      final List<Job> jobs = response.map((job) => Job.fromJson(job)).toList();
      return await _fetchBusinessesForJobs(jobs);
    } catch (e) {
      print("❌ Lỗi khi tìm kiếm công việc: $e");
      return [];
    }
  }

  // 🔹 Lấy danh sách công việc yêu thích
  static Future<List<Job>> fetchFavoriteJobs(String userId) async {
    try {
      final Map<String, dynamic>? response = await _supabase
          .from('users')
          .select('favoriteJobs')
          .eq('id', userId)
          .maybeSingle();

      if (response == null || response['favoriteJobs'] == null) {
        print("Người dùng không có công việc yêu thích.");
        return [];
      }

      List<dynamic> jobIds = response['favoriteJobs'];
      if (jobIds.isEmpty) return [];

      final List<dynamic> jobsResponse =
          await _supabase.from('jobs').select('*').inFilter('id', jobIds);

      final List<Job> jobs =
          jobsResponse.map((job) => Job.fromJson(job)).toList();
      return await _fetchBusinessesForJobs(jobs);
    } catch (e) {
      print("❌ Lỗi khi lấy công việc yêu thích: $e");
      return [];
    }
  }

  // Lấy công việc phổ biến (sắp xếp theo lượt xem giảm dần)
  static Future<List<Job>> fetchPopularJobs() async {
    print("🔥➡️ Bắt đầu fetchPopularJobs");

    try {
      final response = await _supabase
          .from('jobs')
          .select('*, endDay, status') // Loại bỏ dấu phẩy thừa ở cuối
          .order('view_count', ascending: false)
          .limit(5);
      print("Popular Jobs Response (raw): $response");

      if (response.isEmpty) {
        print(" Không có công việc phổ biến.");
        return [];
      }

      final List<Job> jobs = response.map((job) => Job.fromJson(job)).toList();
      print("Popular Jobs Parsed: ${jobs.length} jobs");

      // Gọi _fetchBusinessesForJobs để lấy thông tin doanh nghiệp
      return await _fetchBusinessesForJobs(jobs);
    } catch (e) {
      print("❌ Lỗi khi lấy công việc phổ biến: $e");
      return [];
    }
  }

  static Future<List<Job>> fetchRecentJobs() async {
    print("🔵➡️ Bắt đầu fetchRecentJobs");

    try {
      final response = await _supabase
          .from('jobs')
          .select('*, endDay, status')
          .order('created_at', ascending: false)
          .limit(3);
      print("🔵 Recent Jobs Response (raw): $response");

      final List<Job> jobs = response.map((job) => Job.fromJson(job)).toList();
      print("🔵 Recent Jobs Parsed ${jobs.length} jobs");

      // Thêm log để kiểm tra businessIds
      print(
          "🔵 Business IDs in Recent Jobs: ${jobs.map((job) => job.business_id).toList()}");

      return await _fetchBusinessesForJobs(jobs);
    } catch (e) {
      print("❌ Lỗi khi lấy công việc gần đây: $e");
      return [];
    }
  }

  // Hàm để cập nhật trạng thái công việc (ví dụ khi hết hạn)
 // Hàm để cập nhật trạng thái công việc (ví dụ khi hết hạn)
 static Future<bool> updateJobStatus(String jobId, String status,
 {bool? isApproved, bool? isHidden}) async {
final Map<String, dynamic> updates = {};
if (isApproved != null) updates['isApprove'] = isApproved;
if (isHidden != null) updates['isHidden'] = isHidden; // Đổi tên và key thành 'isHidden'
if (status != null) updates['status'] = status; // Thêm cập nhật status

final response = await Supabase.instance.client
 .from('jobs')
 .update(updates)
.eq('id', jobId);

 return response.status == 200;
 }

  static Future<bool> toggleFavoriteJob(String userId, String jobId) async {
    try {
      final userResponse = await _supabase
          .from('users')
          .select('favoriteJobs')
          .eq('id', userId)
          .maybeSingle();

      if (userResponse == null) {
        print("Không tìm thấy người dùng với ID: $userId");
        return false;
      }

      List<dynamic> favoriteJobs =
          (userResponse['favoriteJobs'] as List?) ?? [];

      if (favoriteJobs.contains(jobId)) {
        favoriteJobs.remove(jobId);
        print("Đã xóa công việc $jobId khỏi yêu thích.");
      } else {
        favoriteJobs = {...favoriteJobs, jobId}.toList();
        print("Đã thêm công việc $jobId vào yêu thích.");
      }

      final updateResponse = await _supabase
          .from('users')
          .update({'favoriteJobs': favoriteJobs}).eq('id', userId);

      if (updateResponse.error == null) {
        return true;
      } else {
        print(
            "Lỗi khi cập nhật công việc yêu thích: ${updateResponse.error!.message}");
        return false;
      }
    } catch (e) {
      print("Lỗi không xác định khi thao tác với công việc yêu thích: $e");
      return false;
    }
  }

  static Future<bool> deleteJob(String jobId) async {
    try {
      // Thực hiện xóa công việc theo jobId
      await _supabase.from('jobs').delete().eq('id', jobId);

      // Kiểm tra lại xem công việc đã bị xóa chưa
      final checkResponse =
          await _supabase.from('jobs').select().eq('id', jobId);

      if (checkResponse.isEmpty) {
        print("✅ Công việc $jobId đã được xóa thành công.");
        return true;
      } else {
        print("❌ Công việc $jobId vẫn còn tồn tại.");
        return false;
      }
    } catch (e) {
      print("❌ Lỗi khi xóa công việc: $e");
      return false;
    }
  }

  static Future<bool> toggleJobVisibility(String jobId, bool isHidden) async {
    try {
      await _supabase
          .from('jobs')
          .update({'isHidden': isHidden}).eq('id', jobId);
      print("👁️ Đã cập nhật isHidden: $isHidden");
      return true;
    } catch (e) {
      print("❌ Lỗi khi ẩn/hiện công việc: $e");
      return false;
    }
  }

  static Future<List<Job>> fetchPendingJobsForRecruiter(String recruiterId) async {
    final response = await _supabase
        .from('jobs')
        .select()
        .eq('business_id', recruiterId)
        .eq('status', 'pending');

    final data = response as List<dynamic>;
    return data.map((json) => Job.fromJson(json)).toList();
  }
}


// Thêm hàm copyWith vào job_model.dart
extension JobCopyWith on Job {
  Job copyWith({
    String? id,
    String? business_id,
    String? position,
    String? levels,
    int? salary,
    String? content,
    String? skills,
    String? types,
    String? requirement,
    int? quantity,
    String? benefit,
    String? startDay,
    String? endDay,
    int? view_count,
    bool? isApprove,
    bool? isHidden,
    String? createAt,
    DateTime? createdAt,
    Business? business,
    String? status,
    String? city,
  }) {
    return Job(
      id: id ?? this.id,
      business_id: business_id ?? this.business_id,
      position: position ?? this.position,
      levels: levels ?? this.levels,
      salary: salary ?? this.salary,
      content: content ?? this.content,
      skills: skills ?? this.skills,
      types: types ?? this.types,
      requirement: requirement ?? this.requirement,
      quantity: quantity ?? this.quantity,
      benefit: benefit ?? this.benefit,
      startDay: startDay ?? this.startDay,
      endDay: endDay ?? this.endDay,
      view_count: view_count ?? this.view_count,
      isApprove: isApprove ?? this.isApprove,
      isHidden: isHidden ?? this.isHidden,
      createAt: createAt ?? this.createAt,
      createdAt: createdAt ?? this.createdAt,
      business: business ?? this.business,
      status: status ?? this.status,
      city: city ?? this.city,
    );
  }
}
