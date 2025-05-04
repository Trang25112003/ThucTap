import 'package:flutter/material.dart';
import 'package:job_supabase/pages/auth/Login.dart';
import '../../../components/app_elevated_button/td_elevated_button.dart';
import '../../../components/snack_bar/td_snack_bar.dart';
import '../../../components/snack_bar/top_snack_bar.dart';
import '../../../components/text_field/td_text_field.dart';
import '../../../resources/app_color.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
 
class ForgotPassWord extends StatefulWidget {
  const ForgotPassWord({super.key});

  @override
  State<ForgotPassWord> createState() => _ForgotPassWordState();
}

class _ForgotPassWordState extends State<ForgotPassWord> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController(); 
  bool isLoading = false;

  Future<void> _onSubmit(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final supabase = Supabase.instance.client;

      // Gửi email khôi phục mật khẩu
      await supabase.auth.resetPasswordForEmail(
        emailController.text.trim(),
        redirectTo: 'https://bhrlhlitofbsfoppqhsm.supabase.co/password-reset', 
      );

      if (!context.mounted) return;

      showTopSnackBar(
        context,
        const TDSnackBar.success(
            message: 'Please check your email to reset your password '),
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => Login()), 
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      if (!context.mounted) return;
      showTopSnackBar(
        context,
        TDSnackBar.error(message: 'Error: ${e.toString()}'),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Forgot Password',
          style: TextStyle( fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
       backgroundColor: Colors.green.shade600,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
           ),
        ),
    leading: IconButton(
      icon: const Icon(Icons.arrow_back, color: AppColor.white),
      onPressed: () {
        Navigator.pop(context);
      },
    ),
  ),
  body: SingleChildScrollView(
    padding: EdgeInsets.symmetric(
      horizontal: 20.0,
      vertical: 18.0, // điều chỉnh lại nếu cần
    ),
    child: Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // const Center(
          //   child: Text(
          //     'Forgot Password',
          //     style: TextStyle(color: AppColor.red, fontSize: 24.0),
          //   ),
          // ),
          // const SizedBox(height: 10),
          // Center(
          //   child: Text(
          //     'Enter Your Email',
          //     style: TextStyle(
          //       color: AppColor.brown.withOpacity(0.8),
          //       fontSize: 18.6,
          //     ),
          //   ),
          // ),
          const SizedBox(height: 40),
          TdTextField(
            controller: emailController,
            hintText: 'Email',
            prefixIcon: const Icon(Icons.email, color: AppColor.orange),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                  .hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 40),
          Center(
            child: TdElevatedButton.outline(
              onPressed: isLoading ? null : () => _onSubmit(context),
              text: isLoading ? 'Loading...' : 'Next',
              isDisable: isLoading,
            ),
          ),
        ],
      ),
    ),
  ),
),

    );
  }
}
