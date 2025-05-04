import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/job_model.dart';
import '../../services/job_service.dart';
import '../auth/Login.dart';
import 'AdminBusinessesPage.dart';
import 'AdminUsersPage.dart';
import 'job_detail_admin.dart';

class AdminJobsPage extends StatefulWidget {
  const AdminJobsPage({Key? key}) : super(key: key);

  @override
  State<AdminJobsPage> createState() => _AdminJobsPageState();
}

class _AdminJobsPageState extends State<AdminJobsPage> {
  List<Job> _jobs = [];
  bool _isLoading = true;
  String? _errorMessage;
  final _supabase = Supabase.instance.client;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchJobs();
  }

  Future<void> _fetchJobs() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final jobs = await JobService.fetchAllJobs();
      setState(() {
        _jobs = jobs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load jobs: $e';
      });
    }
  }

  Future<void> _deleteJob(String jobId, int index, Job removedJob) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this job post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _jobs.removeAt(index);
    });

    try {
      final success = await JobService.deleteJob(jobId);
      if (!success) {
        setState(() {
          _jobs.insert(index, removedJob);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete the job.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Job deleted successfully.')),
        );
      }
    } catch (e) {
      setState(() {
        _jobs.insert(index, removedJob);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting job: $e')),
      );
    }
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await _supabase.auth.signOut();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing out: $error')),
        );
      }
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'almost open':
        return Colors.amber.shade300;
      case 'censoring':
        return Colors.yellow.shade600;
      case 'expired':
        return Colors.red.shade400;
      default:
        return Colors.grey.shade400;
    }
  }

 Widget _buildJobItem(Job job, int index) {
  return Dismissible(
    key: Key(job.id!),
    direction: DismissDirection.endToStart,
 confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Xác nhận xoá'),
              content: const Text('Bạn có chắc muốn xoá bài đăng này không?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Huỷ'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Xoá'),
                ),
              ],
            ),
          );

          if (confirm == true) {
            try {
              final success = await JobService.deleteJob(job.id!);
              if (success) {
                setState(() {
                  _jobs.removeAt(index);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã xoá bài đăng.')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Không thể xoá bài đăng.')),
                );
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Lỗi xoá bài đăng: $e')),
              );
            }
          }
          return false;
        }
        return false;
      },    background: Container(
      color: Colors.red,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      child: const Icon(Icons.delete, color: Colors.white),
    ),
    child: InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdminJobDetail(jobId: job.id!, businessId: '', ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              ClipOval(
                child: job.business?.avatar != null
                    ? Image.network(
                        job.business!.avatar!,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 40,
                        height: 40,
                        color: Colors.green.shade100,
                        child: const Icon(Icons.person_outline, color: Colors.green),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(job.position ?? 'Unknown Position',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(job.business?.name ?? 'Unknown',
                        style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _getStatusColor(job.status),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  job.status ?? 'Not updated yet',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}


  Widget _buildJobManagementPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Job management',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
                  ? Center(child: Text(_errorMessage!))
                  : _jobs.isEmpty
                      ? const Center(child: Text('No jobs available.'))
                      : RefreshIndicator(
                          onRefresh: _fetchJobs,
                          child: ListView.builder(
                            itemCount: _jobs.length,
                            itemBuilder: (context, index) =>
                                _buildJobItem(_jobs[index], index),
                          ),
                        ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildJobManagementPage();
      case 1:
        return const AdminUsersPage();
      case 2:
        return const AdminBusinessesPage();
      default:
        return _buildJobManagementPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Admin',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
       backgroundColor: Colors.green.shade600,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
           ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              tooltip: 'Đăng xuất',
              onPressed: () => _logout(context),
            ),
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 38, 87, 39),
        unselectedItemColor: const Color.fromARGB(255, 99, 121, 109),
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Jobs'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Users'),
          BottomNavigationBarItem(icon: Icon(Icons.business), label: 'Businesses'),
        ],
      ),
    );
  }
}
