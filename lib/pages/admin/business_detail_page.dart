import 'package:flutter/material.dart';
import '../../models/job_model.dart';
import 'job_detail_admin.dart'; // Import AdminJobDetail

class BusinessDetailPage extends StatelessWidget {
  final String businessName;
  final List<Job> jobs;

  const BusinessDetailPage({
    super.key,
    required this.businessName,
    required this.jobs,
    required String businessId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Job Detail - ${businessName}",
              style: TextStyle(color: Colors.white,fontSize: 20, fontWeight: FontWeight.bold)),
               centerTitle: true,
        backgroundColor: Colors.green.shade600,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      body: jobs.isEmpty
          ? const Center(child: Text("Không có công việc nào"))
          : ListView.builder(
              itemCount: jobs.length,
              itemBuilder: (context, index) {
                final job = jobs[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: Colors.blueGrey,
                      child: Text(
                        job.position?.substring(0, 1) ??
                            '?', // Hiển thị chữ cái đầu tiên của vị trí công việc
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      job.position ?? 'Tên công việc',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "poster: ${job.name ?? 'unknown origin'}",
                          style: TextStyle(color: Colors.grey),
                        ),
                        SizedBox(height: 4),
                        Text(
                         " City: ${job.city ?? 'Không có thành phố'}",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 20,
                      color: Colors.grey[600],
                    ),
                    onTap: () {
                      // Điều hướng đến trang AdminJobDetail và truyền công việc đã chọn
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminJobDetail(
                            jobId:
                                job.id ?? '', // Truyền jobId từ đối tượng job
                            businessId: job.business_id ??
                                '', // Truyền businessId từ đối tượng job
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
