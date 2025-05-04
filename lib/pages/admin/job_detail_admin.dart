import 'package:flutter/material.dart';
import '../../models/job_model.dart';
import '../../services/job_service.dart';

class AdminJobDetail extends StatefulWidget {
  final String jobId;
  final String? businessId;

  const AdminJobDetail({Key? key, required this.jobId, required this.businessId, }) : super(key: key);

  @override
  State<AdminJobDetail> createState() => _AdminJobDetailState();
}

class _AdminJobDetailState extends State<AdminJobDetail> {
  final JobService _jobService = JobService();
  Future<Job?>? _jobDetailsFuture;
  Job? _jobDetails;

  @override
  void initState() {
    super.initState();
    _jobDetailsFuture = JobService.fetchJobDetails(widget.jobId);
  }

  Future<void> _approveJob(BuildContext context) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm approval'),
          content: const Text('Are you sure you want to browse this post?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Approved'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      final success = await _jobService.approveJob(widget.jobId);
      if (success) {
        setState(() {
          _jobDetails = _jobDetails?.copyWith(isApprove: true, status: 'Open');
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post has been approved successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post approval failed.')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error while browsing post: $error')),
      );
    }
  }

  Future<void> _hideJob(BuildContext context) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hidden confirmation'),
          content: const Text('Are you sure you want to hide this post?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Hidden Post '),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      final success = await _jobService.hideJob(widget.jobId);
      if (success) {
        setState(() {
          _jobDetails = _jobDetails?.copyWith(isHidden: true);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bài đăng đã được ẩn thành công.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ẩn bài đăng thất bại.')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi ẩn bài đăng: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
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
      body: FutureBuilder<Job?>(
        future: _jobDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Không tìm thấy chi tiết công việc.'));
          }

          _jobDetails = snapshot.data!;
          final job = _jobDetails!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: job.business?.avatar != null
                            ? NetworkImage(job.business!.avatar!)
                            : null,
                        child: job.business?.avatar == null
                            ? const Icon(Icons.business, size: 40)
                            : null,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        job.business?.name ?? 'Không xác định',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildInfoRow('Level:', job.levels),
                _buildInfoRow('Position:', job.position),
                _buildInfoRow('Status:', job.status),
                _buildInfoRow('Content:', job.content),
                _buildInfoRow('Requirement:', job.requirement),
                _buildInfoRow('Skill:', job.skills),
                _buildInfoRow('Salary:', job.salary != null ? '\$${job.salary}' : null),
                _buildInfoRow('Quantity:', job.quantity?.toString()),
                _buildInfoRow('Start Day:', job.startDay),
                _buildInfoRow('End Day:', job.endDay),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: job.isHidden == true ? Colors.grey : Colors.redAccent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: job.isHidden == true ? null : () => _hideJob(context),
                        child: Text(
                          job.isHidden == true ? 'Hidden Post' : 'Hidden Post',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: job.isApprove == true ? Colors.grey : Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: job.isApprove == true ? null : () => _approveJob(context),
                        child: Text(
                          job.isApprove == true ? 'Approved' : 'Approved',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String title, String? content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: RichText(
        text: TextSpan(
          text: '$title ',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          children: [
            TextSpan(
              text: content ?? 'Chưa cập nhật',
              style: const TextStyle(fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }
}