import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../avatar_provider.dart';
import 'user_info_provider.dart';

class MyAccountPage extends StatefulWidget {
  const MyAccountPage({Key? key}) : super(key: key);

  @override
  State<MyAccountPage> createState() => _MyAccountPageState();
}

class _MyAccountPageState extends State<MyAccountPage> {
  final supabase = Supabase.instance.client;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  String? avatarUrl;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userId = supabase.auth.currentUser!.id;
    final response = await supabase
        .from('accounts')
        .select()
        .eq('id', userId)
        .single();

    setState(() {
      emailController.text = response['email'] ?? '';
      nameController.text = response['name'] ?? '';
      phoneController.text = response['numberPhone'] ?? '';
      avatarUrl = response['avatar'];
      isLoading = false;
    });
  }

Future<void> _pickImage(ImageSource source) async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: source);

  if (pickedFile != null) {
    final file = File(pickedFile.path);
    final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';

    try {
      // Upload lên storage
      await supabase.storage.from('avatars').upload(fileName, file);

      // Lấy public URL
      final imageUrl =
          supabase.storage.from('avatars').getPublicUrl(fileName);

      final userId = supabase.auth.currentUser!.id;

      // Cập nhật vào DB
      await supabase
          .from('accounts')
          .update({'avatar': imageUrl})
          .eq('id', userId);

      // Cập nhật AvatarProvider tại đây 👇
      if (!mounted) return;
      context.read<AvatarProvider>().setUserAvatarUrl(imageUrl);

      // Load lại dữ liệu người dùng (nếu muốn cập nhật UI)
      await _loadUserData();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật ảnh đại diện thành công')),
      );
    } catch (e) {
      debugPrint('Lỗi khi upload ảnh: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi khi cập nhật ảnh đại diện')),
      );
    }
  }
}


Future<void> _removeAvatar() async {
  if (avatarUrl == null || avatarUrl!.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bạn chưa có ảnh để xoá')),
    );
    return;
  }

  final userId = supabase.auth.currentUser!.id;

  await supabase
      .from('accounts')
      .update({'avatar': null})
      .eq('id', userId);

  // ✅ Xoá avatar khỏi Provider
  context.read<AvatarProvider>().setUserAvatarUrl('');

  await _loadUserData();

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Đã xoá ảnh đại diện')),
  );
}



  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Chụp ảnh'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Chọn từ thư viện'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Xoá ảnh đại diện'),
                onTap: () {
                  Navigator.of(context).pop();
                  _removeAvatar();
                },
              ),
            ],
          ),
        );
      },
    );
  }

Future<void> _updateProfile() async {
  final userId = supabase.auth.currentUser!.id;
  
  // Hiển thị loading indicator
  showDialog(
    context: context,
    barrierDismissible: false,  // Không cho phép đóng dialog khi nhấn ngoài
    builder: (BuildContext context) {
      return const Center(
        child: CircularProgressIndicator(),  // Hiển thị vòng xoay
      );
    },
  );

  try {
    // Cập nhật thông tin người dùng
    await supabase.from('accounts').update({
      'name': nameController.text,
      'numberPhone': phoneController.text,
    }).eq('id', userId);

    // Cập nhật AvatarProvider nếu có
    final userInfoProvider = context.read<UserInfoProvider>();
    userInfoProvider.setUsername(nameController.text.trim());

    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      context.read<AvatarProvider>().setUserAvatarUrl(avatarUrl!);
    }

    await _loadUserData();

    // Quay lại trang Profile sau khi cập nhật thành công
    Navigator.of(context).pop(); // Đóng loading indicator
    Navigator.of(context).pop(); // Quay lại trang Profile
  } catch (e) {
    debugPrint('Lỗi khi cập nhật hồ sơ: $e');
    Navigator.of(context).pop(); // Đóng loading indicator
  }
}





  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          )
        : Scaffold(
            backgroundColor: const Color(0xFFE9F5EC),
            body: SizedBox.expand(
              child: Stack(
                children: [
                  Positioned(
                      top: -50,
                      left: -50,
                      child: _circle(150, Colors.green.shade100)),
                  Positioned(
                      bottom: -40,
                      right: -40,
                      child: _circle(120, Colors.green.shade200)),
                  Positioned(
                      top: 100,
                      right: -30,
                      child: _circle(80, Colors.green.shade100)),
                  SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 187, 228, 196),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.all(6),
                                child: const Icon(Icons.arrow_back, size: 24),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Profile',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        Center(
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Container(
                                width: 104,
                                height: 104,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color.fromARGB(255, 238, 241, 238),
                                      Color.fromARGB(255, 64, 141, 67)
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.greenAccent.withOpacity(0.4),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: ClipOval(
                                  child: SizedBox(
                                    width: 100,
                                    height: 100,
                                    child: Image(
                                      image: avatarUrl != null &&
                                              avatarUrl!.isNotEmpty
                                          ? NetworkImage(avatarUrl!)
                                          : const AssetImage('assets/images/logo_1.jpg')
                                              as ImageProvider,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 4,
                                child: InkWell(
                                  onTap: _showImageSourceActionSheet,
                                  child: const CircleAvatar(
                                    radius: 15,
                                    backgroundColor:
                                        Color.fromARGB(255, 104, 159, 98),
                                    child: Icon(Icons.add,
                                        size: 18, color: Colors.white),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        TextField(
                          controller: emailController,
                          enabled: false,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: const TextStyle(color: Colors.grey),
                            disabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Color.fromARGB(255, 113, 182, 116),
                                  width: 2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: 'Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Color.fromARGB(255, 113, 182, 116),
                                  width: 2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: phoneController,
                          decoration: InputDecoration(
                            labelText: 'Phone number',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Color.fromARGB(255, 113, 182, 116),
                                  width: 2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 30),
                        Center(
                          child: ElevatedButton(
                            onPressed: _updateProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 113, 182, 116),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text(
                              'Update Profile',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
  }

  Widget _circle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
