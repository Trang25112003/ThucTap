import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/job_model.dart';
import '../../models/recruiter_account_model.dart';
import '../Home/profile_page.dart';
import 'creat_job_recruiter.dart';
import 'plan_recruiter.dart';

class RecruiterPage extends StatefulWidget {
  const RecruiterPage({Key? key}) : super(key: key);

  @override
  State<RecruiterPage> createState() => _RecruiterPageState();
}

class _RecruiterPageState extends State<RecruiterPage> {
  int _selectedIndex = 0;
  List<Job> _pendingJobs = [];
  bool _isLoading = false;
  String? _errorMessage;
  RecruiterAccount? _recruiterAccount; // <-- Thêm recruiterAccount vào State

  @override
  void initState() {
    super.initState();
    _fetchRecruiterAndJobs(); // <-- Gọi hàm mới để lấy recruiter trước
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PlanPage()),
      );
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfilePage()),
      );
    }
  }

  Future<void> _fetchRecruiterAndJobs() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Không tìm thấy người dùng.';
        });
        return;
      }

      final response = await Supabase.instance.client
          .from('accounts')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (response == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Không tìm thấy thông tin nhà tuyển dụng.';
        });
        return;
      }

_recruiterAccount = RecruiterAccount.fromMap(response as Map<String, dynamic>);

      await _fetchPendingJobs();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Lỗi khi tải thông tin nhà tuyển dụng: $e';
      });
    }
  }

  Future<void> _fetchPendingJobs() async {
    try {
      if (_recruiterAccount == null || _recruiterAccount!.id == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Không tìm thấy thông tin nhà tuyển dụng.';
        });
        return;
      }

      final recruiterId = _recruiterAccount!.id!;

      final businessResponse = await Supabase.instance.client
          .from('business')
          .select('id')
          .eq('account_id', recruiterId);

      if (businessResponse.isEmpty) {
        setState(() {
          _isLoading = false;
          _pendingJobs = [];
          _errorMessage = 'Nhà tuyển dụng chưa có doanh nghiệp nào.';
        });
        return;
      }

      final businessIds = (businessResponse as List<dynamic>)
          .map((business) => business['id'] as String)
          .toList();

      final jobsResponse = await Supabase.instance.client
          .from('jobs')
          .select()
          .eq('status', 'pending')
          .inFilter('business_id', businessIds);

      final List<Job> jobs = (jobsResponse as List<dynamic>)
          .map((job) => Job.fromJson(job as Map<String, dynamic>))
          .toList();

      setState(() {
        _pendingJobs = jobs;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Lỗi khi tải danh sách công việc: $error';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tải danh sách công việc: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F8F3),
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.green[300],
        elevation: 4,
        title: Text(
          _recruiterAccount?.name?.isNotEmpty == true
              ? _recruiterAccount!.name!.toUpperCase()
              : "RECRUITER",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 20,
              backgroundImage: _recruiterAccount?.avatar != null
                  ? NetworkImage(_recruiterAccount!.avatar!)
                  : const AssetImage("assets/images/default_avatar.jpg")
                      as ImageProvider,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          const PositionedCircles(),
          Padding(
            padding: const EdgeInsets.only(bottom: 80),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(fontSize: 16, color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : _pendingJobs.isEmpty
                        ? const Center(
                            child: Text(
                              "Không tìm thấy công việc đang chờ duyệt.",
                              style: TextStyle(fontSize: 16, color: Colors.green),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : ListView.builder(
                            itemCount: _pendingJobs.length,
                            itemBuilder: (context, index) {
                              final job = _pendingJobs[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: ListTile(
                                  title: Text(job.safePosition),
                                  subtitle: Text('Ngày bắt đầu: ${job.startDay}'),
                                  trailing: const Icon(Icons.work_outline, color: Colors.green),
                                  onTap: () {
                                    // Thêm hành động khi nhấn vào job nếu cần
                                  },
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green[400],
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateJobPage()),
          ).then((_) {
            _fetchPendingJobs();
          });
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.view_list_outlined),
            label: 'Plan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class PositionedCircles extends StatelessWidget {
  const PositionedCircles();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned(
          top: 50,
          left: 30,
          child: CircleAvatar(radius: 60, backgroundColor: Color(0xFFD5EED5)),
        ),
        const Positioned(
          top: 0,
          right: 0,
          child: CircleAvatar(radius: 40, backgroundColor: Color(0xFFE2F6E2)),
        ),
        const Positioned(
          bottom: 80,
          left: 10,
          child: CircleAvatar(radius: 50, backgroundColor: Color(0xFFD5EED5)),
        ),
        const Positioned(
          bottom: 200,
          right: 30,
          child: CircleAvatar(radius: 20, backgroundColor: Color(0xFFE2F6E2)),
        ),
      ],
    );
  }
}
