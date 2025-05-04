import 'package:flutter/material.dart';
import '../../models/job_model.dart';
import '../../services/local/shared_pref.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({Key? key}) : super(key: key);

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> with WidgetsBindingObserver {
  List<Job> favoriteJobs = [];

  @override
  void initState() {
    super.initState();
    loadFavorites();
    WidgetsBinding.instance.addObserver(this); // Đăng ký observer
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Hủy đăng ký observer
    super.dispose();
  }

  void didPopNext() {
    // Khi quay lại trang này
    loadFavorites(); // Tải lại danh sách yêu thích
  }

  void loadFavorites() {
    setState(() {
      favoriteJobs = SharedPrefs.getFavoriteJobs(); // Lấy từ local
    });
  }

  void handleFavoriteChanged() {
    loadFavorites(); // Cập nhật lại danh sách khi job bị xoá khỏi yêu thích
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Công việc yêu thích"),
        backgroundColor: Colors.green.shade100,
        foregroundColor: Colors.black,
      ),
      body: favoriteJobs.isEmpty
          ? const Center(child: Text("Chưa có công việc nào được yêu thích."))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favoriteJobs.length,
              itemBuilder: (context, index) {
                final job = favoriteJobs[index];
                return CustomJobCard(
                  job: job,
                  onFavoriteChanged: handleFavoriteChanged,
                );
              },
            ),
    );
  }
}

class CustomJobCard extends StatefulWidget {
  final Job job;
  final VoidCallback onFavoriteChanged;

  const CustomJobCard({
    Key? key,
    required this.job,
    required this.onFavoriteChanged,
  }) : super(key: key);

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

  void toggleFavorite() async {
    if (isFavorite) {
      await SharedPrefs.removeFavorite(widget.job);
    } else {
      await SharedPrefs.addFavorite(widget.job);
    }

    setState(() {
      isFavorite = !isFavorite;
    });

    widget.onFavoriteChanged(); // Cập nhật lại danh sách yêu thích
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: widget.job.avatar != null
            ? CircleAvatar(
                backgroundImage: NetworkImage(widget.job.avatar!),
              )
            : const CircleAvatar(child: Icon(Icons.business)),
        title: Text(widget.job.position ?? "Vị trí chưa rõ",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        subtitle: Text(widget.job.name ?? "Công ty không rõ"),
        trailing: IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.red : Colors.grey,
          ),
          onPressed: toggleFavorite,
        ),
      ),
    );
  }
}
