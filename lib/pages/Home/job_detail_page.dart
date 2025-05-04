import 'package:flutter/material.dart';
import '../../models/job_model.dart'; // Đảm bảo đường dẫn này đúng
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/job_service.dart';

class JobDetailsPage extends StatefulWidget {
  final Job job;

  const JobDetailsPage({Key? key, required this.job}) : super(key: key);

  @override
  _JobDetailsPageState createState() => _JobDetailsPageState();
}

class _JobDetailsPageState extends State<JobDetailsPage> {
  late bool _isFavorite;
  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.job.isFavorite;
  }

  Future<void> _toggleFavorite() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      print("Người dùng chưa đăng nhập để thực hiện thao tác yêu thích.");
      return;
    }

    final success = await JobService.toggleFavoriteJob(userId, widget.job.id!);
    if (success) {
      setState(() {
        _isFavorite = !_isFavorite;
        // Cập nhật lại thuộc tính isFavorite của job để đồng bộ
        widget.job.isFavorite = _isFavorite;
      });
      // Hiển thị thông báo phản hồi cho người dùng
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isFavorite
              ? 'Đã thêm vào công việc yêu thích'
              : 'Đã xóa khỏi công việc yêu thích'),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      // Xử lý lỗi khi thao tác yêu thích không thành công
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Có lỗi xảy ra. Vui lòng thử lại.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Job Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor:Colors.green.shade600,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(10),
          ),
        ),
        foregroundColor: Colors.black,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Material(
            color: const Color.fromARGB(255, 207, 238, 216),
            borderRadius: BorderRadius.circular(8.0),
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      backgroundColor: const Color(0xFFF3FDFB),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(widget.job.avatar ??
                      'https://cdn-icons-png.flaticon.com/512/3135/3135715.png'),
                  radius: 30,
                  backgroundColor: const Color.fromARGB(255, 238, 238, 238),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.job.name ?? 'Tên công ty',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.job.position ?? 'Vị trí tuyển dụng',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        children: [
                          const Icon(Icons.location_on,
                              size: 16, color: Colors.grey),
                          Text(
                            widget.job.city ?? 'Không rõ địa điểm',
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? Colors.red : null,
                  ),
                  onPressed: _toggleFavorite,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Duration
            Row(
              children: [
                const Icon(Icons.timer_outlined, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Duration',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.job.startDay ?? 'N/A'} - ${widget.job.endDay ?? 'N/A'}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 24),

            // Job Description
            Row(
              children: [
                const Icon(Icons.description_outlined, color: Colors.green),
                const SizedBox(width: 8),
                const Text(
                  'Job Description',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.job.content ?? 'No description provided.',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 24),

            // Skills & Requirements
            Row(
              children: [
                const Icon(Icons.settings_outlined, color: Colors.orange),
                const SizedBox(width: 8),
                const Text(
                  'Skills & Requirements',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (widget.job.skills != null && widget.job.skills!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.job.skills!.split(',').map((skill) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text('- ${skill.trim()}',
                          style: const TextStyle(fontSize: 14)),
                    ))
                    .toList(),
              )
            else
              const Text('No specific skills or requirements mentioned.'),
            const SizedBox(height: 24),

            // Benefits
            Row(
              children: [
                const Icon(Icons.redeem_outlined, color: Colors.purple),
                const SizedBox(width: 8),
                const Text(
                  'Benefits',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.job.benefit ?? 'No benefits mentioned.',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 32),

            // Apply Now Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implement apply now functionality
                  print('Apply Now clicked for ${widget.job.position}');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF27AE60),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
                  'Apply Now',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}