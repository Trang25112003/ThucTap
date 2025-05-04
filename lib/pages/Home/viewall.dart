import 'package:flutter/material.dart';
import '../../models/job_model.dart';
import '../../services/local/shared_pref.dart';
import 'job_detail_page.dart';

class ViewAllJobsPage extends StatelessWidget {
  final String title;
  final String sortType;
  final Future<List<Job>> jobFuture;
  final VoidCallback? onFavoriteChanged; // Cho phép null để kiểm tra

  const ViewAllJobsPage({
    Key? key,
    required this.title,
    required this.sortType,
    required this.jobFuture,
    this.onFavoriteChanged, // Cho phép null
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 231, 247, 237),
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 231, 247, 237),
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
      body: FutureBuilder<List<Job>>(
        future: jobFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Lỗi: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Không có công việc nào."));
          }

          final jobs = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final job = jobs[index];
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => JobDetailsPage(job: job),
                    ),
                  );
                },
                child: CustomJobCard(
                  job: job,
                  onFavoriteChanged: onFavoriteChanged, // Truyền callback
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class CustomJobCard extends StatefulWidget {
  final Job job;
  final VoidCallback? onFavoriteChanged; // Cho phép null để kiểm tra

  const CustomJobCard({Key? key, required this.job, this.onFavoriteChanged})
      : super(key: key);

  @override
  State<CustomJobCard> createState() => _CustomJobCardState();
}

class _CustomJobCardState extends State<CustomJobCard> {
  late bool isFavorite;

  @override
  void initState() {
    super.initState();
    isFavorite = SharedPrefs.isFavorite(widget.job);
  }

  void toggleFavorite() {
    setState(() {
      if (isFavorite) {
        SharedPrefs.removeFavorite(widget.job);
      } else {
        SharedPrefs.addFavorite(widget.job);
        widget.onFavoriteChanged?.call(); // Gọi callback an toàn
      }
      isFavorite = !isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;
    final List<Color> gradientColors = [Colors.blueAccent, Colors.tealAccent];
    final defaultAvatar =
        'https://cdn-icons-png.flaticon.com/512/3135/3135715.png';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        margin: const EdgeInsets.all(2),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(job.avatar ?? defaultAvatar),
                  radius: 24,
                  backgroundColor: const Color.fromARGB(255, 238, 238, 238),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.name ?? 'Tên công ty',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 4,
                        children: [
                          const Icon(Icons.location_on,
                              size: 14, color: Colors.grey),
                          Text(
                            job.city ?? 'Không rõ địa điểm',
                            style: const TextStyle(
                                fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: toggleFavorite,
                  child: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    size: 20,
                    color: isFavorite ? Colors.red : Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Salary & tags
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                Chip(
                  label: Text("\$ ${job.salary?.toStringAsFixed(0) ?? '---'}"),
                  backgroundColor: Colors.green.withOpacity(0.1),
                  labelStyle: const TextStyle(color: Colors.green),
                ),
                if (job.levels != null)
                  Chip(
                    label: Text(job.levels!),
                    backgroundColor: Colors.grey.shade200,
                  ),
                if (job.types != null)
                  Chip(
                    label: Text(job.types!),
                    backgroundColor: Colors.grey.shade200,
                  ),
                if (job.skills != null)
                  ...job.skills!.split(',').map((skill) => Chip(
                        label: Text(skill.trim()),
                        backgroundColor: Colors.grey.shade100,
                      )),
              ],
            ),

            const SizedBox(height: 10),
            // Description
            Text(
              job.content ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14),
            ),

            const SizedBox(height: 10),
            // Requirements
            if (job.requirement != null && job.requirement!.isNotEmpty)
              Wrap(
                spacing: 8,
                children: job.requirement!
                    .split(',')
                    .map((req) => Chip(
                          label: Text(req.trim()),
                          backgroundColor: const Color(0xFFD2F6DE),
                        ))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}
