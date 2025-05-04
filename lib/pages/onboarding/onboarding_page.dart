import 'package:flutter/material.dart';
import '../../components/app_elevated_button/td_elevated_button.dart';
import '../../models/onboarding_model.dart';
import '../../services/local/shared_pref.dart';
import '../auth/Login.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    SharedPrefs.isAccessed = true;
  print(onboardings[0].imagePath);
  }

  void _changePage(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image with Overlay
          PageView.builder(
            controller: _pageController,
            onPageChanged: _changePage,
            itemCount: onboardings.length,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  Expanded(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          onboardings[index].imagePath,
                          fit: BoxFit.fitHeight, errorBuilder: (BuildContext, Object, StackTrace? stackTrace) {
                                                  return Image.asset(
                                                    "C:\trang-flutter\job_supabase\assets\images\onboarding_1.png",
                                                    height: 100,
                                                    width: 100,
                                                  );
                                                },// Ensure the image fits properly
                        ),
                        Container(
                          color: Colors.black.withOpacity(0.2), // Light overlay for better visibility
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),

          // Content
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
                child: Column(
                  children: [
                    // Pagination Dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        onboardings.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: index == _currentIndex ? 24.0 : 10.0,
                          height: 10.0,
                          decoration: BoxDecoration(
                            color: index == _currentIndex ? Colors.white : Colors.grey,
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40.0),
                    // Navigation Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: TdElevatedButton.outline(
                            onPressed: _currentIndex > 0
                                ? () {
                                    _pageController.animateToPage(
                                      _currentIndex - 1,
                                      duration: const Duration(milliseconds: 600),
                                      curve: Curves.easeInOut,
                                    );
                                  }
                                : null,
                            text: 'Back',
                          ),
                        ),
                        const SizedBox(width: 20.0),
                        Expanded(
                          child: TdElevatedButton(
                            onPressed: () {
                              if (_currentIndex < onboardings.length - 1) {
                                _pageController.animateToPage(
                                  _currentIndex + 1,
                                  duration: const Duration(milliseconds: 600),
                                  curve: Curves.easeInOut,
                                );
                              } else {
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(builder: (context) => Login()),
                                  (Route<dynamic> route) => false,
                                );
                              }
                            },
                            text: _currentIndex == onboardings.length - 1 ? 'Start' : 'Next',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
