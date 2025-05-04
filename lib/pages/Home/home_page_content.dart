import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../gen/assets.gen.dart';
import '../../models/job_model.dart';
import '../../services/job_service.dart';
import '../chat/chatbot_page.dart';
import 'avatar_provider.dart';
import 'job_detail_page.dart';
import 'profile/user_info_provider.dart';
import 'viewall.dart';

class HomeContent extends StatefulWidget {
  final String username;
  final String? avatar;

  const HomeContent({Key? key, required this.username, this.avatar})
      : super(key: key);

  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  late Future<List<Job>> popularJobs;
  late Future<List<Job>> recentJobs;
  String searchQuery = '';
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _searchOverlayEntry;
  List<Job> _searchResults = [];
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _fetchInitialJobs();
    _searchFocusNode.addListener(_onSearchFocusChanged);
  }

  @override
  void dispose() {
    _searchFocusNode.removeListener(_onSearchFocusChanged);
    _searchFocusNode.dispose();
    _searchOverlayEntry?.dispose();
    super.dispose();
  }

  Future<void> _fetchInitialJobs() async {
    popularJobs = JobService.fetchPopularJobs();
    recentJobs = JobService.fetchRecentJobs();
  }

  void _onSearchChanged(String query) async {
    setState(() {
      searchQuery = query;
    });

    if (query.isNotEmpty) {
      _searchResults = await JobService.fetchJobsByKeyword(query);
      _showSearchOverlay();
    } else {
      _hideSearchOverlay();
      _searchResults = [];
    }
  }

  void _onSearchFocusChanged() {
    if (!_searchFocusNode.hasFocus) {
      _hideSearchOverlay();
    }
  }

  void _showSearchOverlay() {
    if (_searchOverlayEntry == null) {
      _searchOverlayEntry = _createSearchOverlay();
      Overlay.of(context)?.insert(_searchOverlayEntry!);
    } else {
      _searchOverlayEntry?.markNeedsBuild(); // Cập nhật overlay nếu đã tồn tại
    }
  }

  void _hideSearchOverlay() {
    _searchOverlayEntry?.remove();
    _searchOverlayEntry = null;
  }

  OverlayEntry _createSearchOverlay() {
    return OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: () {
          _searchFocusNode.unfocus();
          _hideSearchOverlay();
        },
        behavior: HitTestBehavior.opaque,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 56),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width - 32,
              ),
              child: _buildSearchResultList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResultList() {
    if (_searchResults.isEmpty && searchQuery.isNotEmpty) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text("Không tìm thấy công việc nào."),
      );
    }
    // 2. Giới hạn số lượng hiển thị và cho phép cuộn
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 3 * 60.0), // Giả sử mỗi item cao 60
      child: ListView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(), // Cho phép cuộn trong giới hạn
        itemCount: _searchResults.length > 3 ? 3 : _searchResults.length, // Hiển thị tối đa 3
        itemBuilder: (context, index) {
          final job = _searchResults[index];
          return InkWell( // Sử dụng InkWell để có hiệu ứng khi chạm
            onTap: () {
              setState(() {
                searchQuery = job.position ?? '';
              });
              _hideSearchOverlay();
              FocusScope.of(context).unfocus(); // 3. Ẩn bàn phím
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => JobDetailsPage(job: job)),
              );
            },
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: (job.business?.avatar == null || job.business!.avatar!.isEmpty)
                    ? AssetImage(Assets.images.defaultLogo.path) as ImageProvider
                    : NetworkImage(job.business!.avatar!),
              ),
              title: Text(job.position ?? ''),
              subtitle: Text(job.business?.name ?? ''),
            ),
          );
        },
      ),
    );
  }


  Widget _buildSearchBar() {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
        focusNode: _searchFocusNode,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: "Search jobs...",
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildChatbotButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Chatbot()));
      },
      child: const CircleAvatar(
        radius: 25,
        backgroundColor: Colors.green,
        child: Icon(Icons.support_agent, color: Colors.white),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ViewAllJobsPage(
                  title: "$title",
                  sortType: title.toLowerCase().contains("popular")
                      ? "popular"
                      : "recent",
                  jobFuture: JobService.fetchAllJobs(
                      // Bạn có thể muốn truyền searchQuery ở đây nếu muốn lọc trang ViewAll
                      ),
                ),
              ),
            );
          },
          child: const Text("View all",
              style: TextStyle(color: Color.fromARGB(255, 15, 17, 15))),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Consumer<UserInfoProvider>(
      builder: (context, userInfoProvider, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Welcome back",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(userInfoProvider.username,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
            _buildUserAvatar(),
          ],
        );
      },
    );
  }

  Widget _buildUserAvatar() {
    return Consumer<AvatarProvider>(
      builder: (context, avatarProvider, child) {
        final avatarUrl = avatarProvider.userAvatarUrl ?? 'default_avatar_url';

        if (avatarUrl.isNotEmpty) {
          return CircleAvatar(
            radius: 30,
            backgroundColor: const Color.fromARGB(255, 120, 173, 122),
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: avatarUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    const CircularProgressIndicator(),
                errorWidget: (context, url, error) => Image.asset(
                  'assets/images/logo_1.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        } else {
          return const CircleAvatar(
            radius: 30,
            backgroundColor: Color.fromARGB(255, 120, 173, 122),
            backgroundImage: AssetImage('assets/images/logo_1.jpg'),
          );
        }
      },
    );
  }

  Widget _buildSearchAndChatRow() {
    return Row(
      children: [
        Expanded(
          child: _buildSearchBar(),
        ),
        const SizedBox(width: 10),
        _buildChatbotButton(),
      ],
    );
  }

  Widget _buildPopularJobs() {
    return SizedBox(
      height: 180,
      child: FutureBuilder<List<Job>>(
        future: popularJobs,
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

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return _buildPopularJobCard(snapshot.data![index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildRecentJobs() {
    return FutureBuilder<List<Job>>(
      future: recentJobs,
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

        List<Job> jobs = snapshot.data!;
        for (final job in jobs) {
          if (job.endDay != null &&
              DateTime.tryParse(job.endDay!) != null &&
              DateTime.tryParse(job.endDay!)!.isBefore(DateTime.now()) &&
              job.status?.toLowerCase() == 'open') {
            JobService.updateJobStatus(
              job.id!,
              'Closed',
              isApproved: job.isApprove,
              isHidden: job.isHidden,
            );
          }
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: jobs.length,
          itemBuilder: (context, index) {
            return _buildRecentJobCard(jobs[index]);
          },
        );
      },
    );
  }

  Widget _buildPopularJobCard(Job job) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => JobDetailsPage(job: job)),
        );
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: (job.business?.avatar == null ||
                          job.business!.avatar!.isEmpty)
                      ? AssetImage(Assets.images.defaultLogo.path)
                      : NetworkImage(job.business!.avatar!) as ImageProvider,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    job.business?.name ??
                        "Unknown", // Sử dụng job.business?.name
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(job.position ?? '',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    job.levels ?? 'Unknown',
                    style: const TextStyle(fontSize: 12, color: Colors.green),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              (job.salary ?? 0) > 0 ? "\$${job.salary}" : "Negotiable",
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentJobCard(Job job) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => JobDetailsPage(job: job)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.transparent,
              backgroundImage: (job.business?.avatar == null ||
                      job.business!.avatar!.isEmpty)
                  ? AssetImage(Assets.images.defaultLogo.path)
                  : NetworkImage(job.business!.avatar!) as ImageProvider,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job.position ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    job.business?.name ??
                        "Unknown", // Sử dụng job.business?.name
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                job.status ?? 'Open',
                style: const TextStyle(
                    color: Colors.green, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 🔵 Nền chấm tròn màu xanh
        Positioned(
          top: -50,
          left: -50,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          top: 100,
          right: -30,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
          ),
        ),
        RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _fetchInitialJobs();
            });
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),
                _buildHeader(),
                const SizedBox(height: 15),
                _buildSearchAndChatRow(),
                const SizedBox(height: 20),
                _buildSectionHeader("Popular Jobs"),
                _buildPopularJobs(),
                const SizedBox(height: 20),
                _buildSectionHeader("Recent Jobs"),
                _buildRecentJobs(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
