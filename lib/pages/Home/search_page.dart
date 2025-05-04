import 'package:flutter/material.dart';
import '../../models/job_model.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  late Future<List<Job>> _jobs;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    // _loadJobs();
  }

  // void _loadJobs() {
  //   setState(() {
  //     _jobs = JobService.fetchAllJobs();
  //   });
  // }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  Future<List<Job>> _getFilteredJobs() async {
    List<Job> jobs = await _jobs;
    if (_searchQuery.isEmpty) return jobs;

    return jobs.where((job) {
      String query = _searchQuery.toLowerCase();
        return (job.position ?? '').toLowerCase().contains(query) ||
           (job.skills ?? '').toLowerCase().contains(query) ||
           (job.types ?? '').toLowerCase().contains(query) ||
           (job.levels ?? '').toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tìm Kiếm Công Việc"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSearchBar(),
            const SizedBox(height: 10),
            Expanded(child: _buildJobList()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: "Nhập vị trí, kỹ năng...",
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onChanged: _onSearchChanged,
    );
  }

  Widget _buildJobList() {
    return FutureBuilder<List<Job>>(
      future: _getFilteredJobs(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data!.isEmpty) {
          return const Center(child: Text("Không tìm thấy công việc nào"));
        }

        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final job = snapshot.data![index];
            return _buildJobItem(job);
          },
        );
      },
    );
  }

  Widget _buildJobItem(Job job) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(job.position ?? '', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text("Cấp độ: ${job.levels}", style: TextStyle(color: Colors.grey[700])),
            Text("Loại: ${job.types}", style: TextStyle(color: Colors.blue)),
            Text(  "Lương: ${job.salary != null && job.salary! > 0 ? '\$${job.salary}' : 'Thoả thuận'}",
 style: TextStyle(color: Colors.green)),
            Text("Kỹ năng: ${job.skills}", style: TextStyle(color: Colors.orange)),
            Text("Ngày bắt đầu: ${job.startDay}"),
            Text("Ngày kết thúc: ${job.endDay}"),
          ],
        ),
      ),
    );
  }
}
