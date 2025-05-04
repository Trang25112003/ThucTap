import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PlanPage extends StatefulWidget {
  @override
  _PlanPageState createState() => _PlanPageState();
}

class _PlanPageState extends State<PlanPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<dynamic> jobs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchApprovedJobs();
  }

  Future<void> _fetchApprovedJobs() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await supabase.from('jobs')
          .select()
          .eq('isApproved', true) // chỉ lấy các job đã được duyệt
          .order('created_at', ascending: false); // lấy job mới nhất lên đầu

      setState(() {
        jobs = response;
      });
    } catch (e) {
      print('Error fetching jobs: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Approved Jobs'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : jobs.isEmpty
              ? Center(child: Text('No approved jobs yet.'))
              : ListView.builder(
                  itemCount: jobs.length,
                  itemBuilder: (context, index) {
                    final job = jobs[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(job['title'] ?? 'No title'),
                        subtitle: Text(job['description'] ?? 'No description'),
                      ),
                    );
                  },
                ),
    );
  }
}
