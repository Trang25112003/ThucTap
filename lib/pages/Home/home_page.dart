
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'avatar_provider.dart';
import "home_page_content.dart";
import 'favorite_page.dart';
import 'profile/user_info_provider.dart';
import 'profile_page.dart';
import 'search_page.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String username = "User";
  String? avatar;
  int _selectedIndex = 0;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    final prefs = await SharedPreferences.getInstance();
    final avatarProvider = Provider.of<AvatarProvider>(context, listen: false);
    final userInfoProvider =
        Provider.of<UserInfoProvider>(context, listen: false);

    if (user == null) {
      debugPrint("Không tìm thấy user đã đăng nhập.");
      return;
    }

    // Nếu avatar đã có trong provider, không cần fetch lại
    if (avatarProvider.userAvatarUrl != null &&
        avatarProvider.userAvatarUrl!.isNotEmpty) {
      avatar = avatarProvider.userAvatarUrl;
      return;
    }

    try {
      debugPrint("📢 User ID hiện tại: ${user.id}");
      final response = await supabase
          .from('users')
          .select('name, avatar')
          .eq('id', user.id)
          .maybeSingle();

      debugPrint("Dữ liệu user từ Supabase: $response");

      if (response != null) {
        if (mounted) {
          setState(() {
            username = response['name'] ?? "User";
            avatar = response['avatar'] ?? "";
          });

          // Lưu vào shared preferences & provider
          if (response['avatar'] != null) {
            await prefs.setString('avatar', response['avatar']);
            avatarProvider.setUserAvatarUrl(response['avatar']);
          }
          if (response['name'] != null) {
            userInfoProvider.setUsername(response['name']);
          }
        }
      }
    } catch (error) {
      debugPrint("Lỗi khi lấy dữ liệu user: $error");
    }
  }

  void _onItemTapped(int index) async {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(),
          ),
          IndexedStack(
            index: _selectedIndex,
            children: [
              Consumer<AvatarProvider>(builder: (context, avatarProvider, _) {
                return HomeContent(
                  username: username,
                  avatar: avatarProvider.userAvatarUrl ?? avatar,
                );
              }),
              const SearchPage(),
              const FavoritePage(),
              const ProfilePage(),
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: "Favorite"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

