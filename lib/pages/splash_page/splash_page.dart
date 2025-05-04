import 'dart:async';
import 'package:flutter/material.dart';

import '../../services/local/shared_pref.dart'; // 👈 import SharedPrefs
import '../onboarding/onboarding_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    initialiseApp(); // 👈 gọi hàm khởi tạo
  }

  Future<void> initialiseApp() async {
    await SharedPrefs.initialise(); // 👈 KHỞI TẠO SharedPrefs trước
    await Future.delayed(const Duration(seconds: 2)); // delay splash

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const OnboardingPage()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/logo_1.jpg',
                  width: size.width * 0.8,
                  height: size.height * 0.5,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
