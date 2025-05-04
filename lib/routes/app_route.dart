import 'package:flutter/material.dart';
import '../pages/Home/home_page.dart';
import '../pages/Home/profile/my_account.dart';
import '../pages/Home/profile_page.dart';
import '../pages/admin/admin_page.dart';
import '../pages/auth/forgot_password_page.dart';
import '../pages/auth/Register.dart';
import '../pages/auth/Login.dart';
import '../pages/onboarding/onboarding_page.dart';
import '../pages/recuiter/recruiter_homePage.dart';
import '../pages/splash_page/splash_page.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String signin = '/signin';
  static const String register = '/register';
  static const String forgotPassword = '/forgot_password';
  static const String homepage = '/homepage';
  static const String profilePage = '/profilepage';  
  static const String myAccount = '/myAccount';  
static const String adminJobsPage = '/adminJobsPage';
  static const String recruiterPage = '/recruiterPage';  
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => SplashPage());
      case onboarding:
        return MaterialPageRoute(builder: (_) => OnboardingPage());
      case signin:
        return MaterialPageRoute(builder: (_) => Login());
      case register:
        return MaterialPageRoute(builder: (_) => Register());
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => ForgotPassWord());
      case homepage:
        return MaterialPageRoute(builder: (_) => HomePage());
      case profilePage:
        return MaterialPageRoute(builder: (_) => ProfilePage());
      case myAccount:
        return MaterialPageRoute(builder: (_) => const MyAccountPage());
      case adminJobsPage:
        return MaterialPageRoute(builder: (_) => const AdminJobsPage());
      case recruiterPage:
        return MaterialPageRoute(builder: (_) =>  RecruiterPage());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
