import 'package:flutter/material.dart';
import 'package:job_supabase/models/business_model.dart';
import 'package:job_supabase/services/job_service.dart';
import 'package:job_supabase/services/business_service.dart';

import '../../models/job_model.dart';
import 'business_detail_page.dart';

class AdminBusinessesPage extends StatefulWidget {
  const AdminBusinessesPage({super.key});

  @override
  State<AdminBusinessesPage> createState() => _AdminBusinessesPageState();
}

class _AdminBusinessesPageState extends State<AdminBusinessesPage> {
  List<Business> businesses = [];
  Map<String, List<Job>> businessJobsMap = {};
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchBusinessesAndJobs();
  }

  Future<void> fetchBusinessesAndJobs() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final fetchedBusinesses = await BusinessService.fetchAllBusinesses();
      if (fetchedBusinesses.isEmpty) {
        setState(() {
          isLoading = false;
          businesses = [];
          errorMessage = 'Không có doanh nghiệp nào.';
        });
        return;
      }

      final Map<String, List<Job>> jobsMap = {};
      for (var business in fetchedBusinesses) {
        if (business.id == null) continue;
        final jobs = await JobService.fetchJobsByBusinessId(business.id!);
        jobsMap[business.id!] = jobs;
      }

      setState(() {
        businesses = fetchedBusinesses;
        businessJobsMap = jobsMap;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Lỗi khi tải dữ liệu: $e';
      });
    }
  }

  Future<void> _toggleBusinessStatus(String businessId, bool isActive) async {
    try {
      await BusinessService.updateBusinessStatus(businessId, !isActive);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isActive ? 'Đã khóa tài khoản' : 'Đã mở khóa tài khoản'),
        ),
      );
      await fetchBusinessesAndJobs(); // Refresh lại dữ liệu
    } catch (e) {
      print('Lỗi khi cập nhật trạng thái: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xảy ra lỗi khi cập nhật trạng thái.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final uniqueBusinesses = businesses
        .fold<Map<String, Business>>({}, (map, business) {
          if (!map.containsKey(business.name) && business.id != null) {
            map[business.name!] = business;
          }
          return map;
        })
        .values
        .toList();

    final Map<String, List<Job>> uniqueBusinessJobsMap = {};
    for (var uniqueBusiness in uniqueBusinesses) {
      final businessesWithSameName = businesses
          .where((business) => business.name == uniqueBusiness.name)
          .toList();
      final List<Job> allJobs = [];
      for (var business in businessesWithSameName) {
        if (business.id == null) continue;
        final jobs = businessJobsMap[business.id!] ?? [];
        allJobs.addAll(jobs);
      }
      uniqueBusinessJobsMap[uniqueBusiness.name!] = allJobs;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Business Management",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : uniqueBusinesses.isEmpty
                  ? const Center(child: Text('Không có doanh nghiệp nào.'))
                  : RefreshIndicator(
                      onRefresh: fetchBusinessesAndJobs,
                      child: ListView.builder(
                        itemCount: uniqueBusinesses.length,
                        itemBuilder: (context, index) {
                          final business = uniqueBusinesses[index];
                          final jobs = uniqueBusinessJobsMap[business.name!] ?? [];

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: business.avatar != null
                                  ? NetworkImage(business.avatar!)
                                  : null,
                              child: business.avatar == null
                                  ? const Icon(Icons.business)
                                  : null,
                            ),
                            title: Text(business.name ?? 'Tên công ty'),
                            subtitle: Text('Quantity: ${jobs.length}'),
                            trailing: IconButton(
                              icon: Icon(
                                business.isActive ? Icons.lock_open : Icons.lock,
                                color: business.isActive ? Colors.green : Colors.red,
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text(business.isActive
                                        ? 'Khóa tài khoản?'
                                        : 'Mở khóa tài khoản?'),
                                    content: Text(business.isActive
                                        ? 'Bạn có chắc chắn muốn khóa tài khoản doanh nghiệp này không?'
                                        : 'Bạn có muốn mở lại tài khoản doanh nghiệp này không?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Hủy'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          Navigator.pop(context);
                                          await _toggleBusinessStatus(
                                              business.id!, business.isActive);
                                        },
                                        child: const Text('Xác nhận'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            onTap: () {
                              if (business.id != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BusinessDetailPage(
                                      businessId: business.id.toString(),
                                      businessName: business.name!,
                                      jobs: jobs,
                                    ),
                                  ),
                                );
                              }
                            },
                          );
                        },
                      ),
                    ),
    );
  }
}
