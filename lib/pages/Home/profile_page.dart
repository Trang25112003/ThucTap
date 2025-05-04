import 'package:flutter/material.dart';
import 'package:job_supabase/pages/Home/profile/change_password.dart';
import 'package:job_supabase/pages/Home/profile/my_account.dart';
import 'package:job_supabase/pages/Home/profile/change_language.dart';
import 'package:job_supabase/pages/Home/profile/help_suport.dart';
import 'package:job_supabase/pages/Home/profile/my_cv.dart';
import 'package:job_supabase/pages/Home/profile/log_out.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:job_supabase/pages/Home/profile/my_cv.dart';
import 'package:job_supabase/pages/Home/profile/change_password.dart';
import 'favorite_page.dart'; // import model

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? name;
  String? phone;
  String? email;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user != null) {
      final account_id = user.id;

      final response = await supabase
          .from('users')
          .select('name, email, avatar, accounts(numberPhone)')
          .eq('account_id', account_id)
          .maybeSingle();

      if (mounted) {
        setState(() {
          name = response?['name'] ?? '';
          phone = response?['accounts']?['numberPhone'] ?? '';
          email = response?['email'] ?? user.email ?? '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 231, 248, 238),
      body: SafeArea(
        child: Stack(
          children: [
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
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Profile",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  _buildProfileOptions(),
                  const SizedBox(height: 24),
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
                    child: Text(
                      "More",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                  ),
                  _buildMoreOptions(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOptions() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.person_outline, size: 26),
            title: const Text("My Account",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            subtitle: const Text("Make changes to your account"),
            trailing: const Icon(Icons.arrow_forward_ios,
                size: 16, color: Colors.grey),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyAccountPage(),
                ),
              );
            },
          ),
          const Divider(height: 1, thickness: 0.5, indent: 16, endIndent: 16),
          _buildProfileOption(
            icon: Icons.bookmark_border,
            title: "Favorite",
            subtitle: "Favorites List",
            onTap: () {
              // Điều hướng đến FavoritePage
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FavoritePage(),
                ),
              );
            },
          ),
          _buildProfileOption(
            icon: Icons.replay_outlined,
            title: "Change password",
            subtitle: "Further secure your account",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChangePasswordPage(),
                ),
              );
            },
          ),
          _buildProfileOption(
            icon: Icons.verified_user_outlined,
            title: "My CV",
            subtitle: "Manage your CV",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyCVPage(),
                ),
              );
            },
          ),
          _buildProfileOption(
            icon: Icons.translate_outlined,
            title: "Change language",
            subtitle: "Select your preferred language",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChangeLanguagePage(),
                ),
              );
            },
          ),
          _buildProfileOption(
            icon: Icons.logout,
            title: "Log out",
            subtitle: "",
            onTap: () {
              showLogoutDialog(context);
            },
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMoreOptions() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Column(
        children: [
          _buildProfileOption(
            icon: Icons.notifications_none,
            title: "Help & Support",
            subtitle: "",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HelpAndSupportPage(),
                ),
              );
            },
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, size: 26, color: Colors.black87),
          title: Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          subtitle: subtitle.isNotEmpty
              ? Text(subtitle,
                  style: const TextStyle(fontSize: 14, color: Colors.grey))
              : null,
          trailing:
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          onTap: onTap,
        ),
        if (!isLast)
          const Divider(height: 1, thickness: 0.5, indent: 16, endIndent: 16),
      ],
    );
  }
}
