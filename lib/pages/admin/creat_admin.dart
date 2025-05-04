import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/local/spabase_service.dart';
import '../auth/Login.dart';

class CreateAdminPageWithKey extends StatefulWidget {
  @override
  _CreateAdminPageWithKeyState createState() => _CreateAdminPageWithKeyState();
}

class _CreateAdminPageWithKeyState extends State<CreateAdminPageWithKey> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final adminKeyController = TextEditingController();

final String expectedKey = dotenv.env['ADMIN_KEY'] ?? '';


  bool isLoading = false;

  void createAdmin() async {
  if (adminKeyController.text.trim() != expectedKey) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('🔑 Admin Key không đúng')),
    );
    return;
  }

  setState(() => isLoading = true);

  try {
    await SupabaseService().register(
      emailController.text.trim(),
      passwordController.text.trim(),
      nameController.text.trim(),
      phoneController.text.trim(),
      'admin',
    );

    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(content: Text('✅ Tạo tài khoản admin thành công')),
    // );
      Future.delayed(Duration(seconds: 1), () {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => Login()),
    );
  });
  } on AuthException catch (e) {
    if (e.message.contains('User already registered') ||
        e.message.contains('user_already_exists')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('⚠️ Email đã được đăng ký! Vui lòng dùng email khác.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(' Lỗi đăng ký: ${e.message}')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(' Lỗi không xác định: $e')),
    );
  } finally {
    setState(() => isLoading = false);
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tạo Tài Khoản Admin')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(controller: emailController, decoration: InputDecoration(labelText: 'Email')),
            TextField(controller: passwordController, decoration: InputDecoration(labelText: 'Password'), obscureText: true),
            TextField(controller: nameController, decoration: InputDecoration(labelText: 'Name')),
            TextField(controller: phoneController, decoration: InputDecoration(labelText: 'Phone Number')),
            TextField(controller: adminKeyController, decoration: InputDecoration(labelText: 'Admin Key'), obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : createAdmin,
              child: isLoading ? CircularProgressIndicator() : Text('Tạo tài khoản Admin'),
            ),
          ],
        ),
      ),
    );
  }
}
