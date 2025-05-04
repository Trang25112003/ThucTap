// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../../../components/app_elevated_button/td_elevated_button.dart';
// import '../../../components/snack_bar/td_snack_bar.dart';
// import '../../../components/snack_bar/top_snack_bar.dart';
// import '../../../components/text_field/td_text_field_password.dart';
// import '../../../resources/app_color.dart';
// import '../../../services/local/shared_pref.dart';
// import '../../../utils/validator.dart';

// class ChangePasswordPage extends StatefulWidget {
//   const ChangePasswordPage({super.key});

//   @override
//   State<ChangePasswordPage> createState() => _ChangePasswordPageState();
// }

// class _ChangePasswordPageState extends State<ChangePasswordPage> {
//   final currentPasswordController = TextEditingController();
//   final newPasswordController = TextEditingController();
//   final confirmPasswordController = TextEditingController();
//   final formKey = GlobalKey<FormState>();
//   bool isLoading = false;

//   final supabase = Supabase.instance.client;

//   Future<void> _changePassword(BuildContext context) async {
//     if (formKey.currentState?.validate() == false) return;
//     setState(() => isLoading = true);
//     try {
//       // Kiểm tra mật khẩu cũ
//       final email = SharedPrefs.user?.email ?? '';
//       final response = await supabase.auth.signInWithPassword(
//         email: email,
//         password: currentPasswordController.text,
//       );

//       // if (response.error != null) {
//       //   throw Exception('Current password is incorrect');
//       // }

//       // Đổi mật khẩu mới
//       final updateResponse = await supabase.auth.updateUser(
//         UserAttributes(password: newPasswordController.text),
//       );

//       // if (updateResponse.error != null) {
//       //   throw Exception(updateResponse.error!.message);
//       // }

//       if (!context.mounted) return;
//       showTopSnackBar(
//         context,
//         const TDSnackBar.success(
//             message: 'Password has been changed, please login 😍'),
//       );

//       // Điều hướng về trang đăng nhập
//       Navigator.of(context).pushAndRemoveUntil(
//         MaterialPageRoute(
//           builder: (context) => LoginPage(email: email),
//         ),
//         (Route<dynamic> route) => false,
//       );
//     } catch (e) {
//       setState(() => isLoading = false);
//       showTopSnackBar(
//         context,
//         TDSnackBar.error(message: e.toString()),
//       );
//     }
//   }

//   @override
// //   Widget build(BuildContext context) {
// //     return GestureDetector(
// //       onTap: () => FocusScope.of(context).unfocus(),
// //       child: Scaffold(
// //         body: Form(
// //           key: formKey,
// //           child: ListView(
// //             padding: const EdgeInsets.symmetric(horizontal: 20.0).copyWith(
// //                 top: MediaQuery.of(context).padding.top + 38.0, bottom: 16.0),
// //             children: [
// //               const Center(
// //                 child: Text('Change Password',
// //                     style: TextStyle(color: AppColor.red, fontSize: 24.0)),
// //               ),
// //               const SizedBox(height: 38.0),
// //               const SizedBox(height: 46.0),
// //               TdTextFieldPassword(
// //                 controller: currentPasswordController,
// //                 hintText: 'Current Password',
// //                 validator: Validator.required,
// //                 textInputAction: TextInputAction.next,
// //               ),
// //               const SizedBox(height: 18.0),
// //               TdTextFieldPassword(
// //                 controller: newPasswordController,
// //                 hintText: 'New Password',
// //                 validator: Validator.password,
// //                 textInputAction: TextInputAction.next,
// //               ),
// //               const SizedBox(height: 18.0),
// //               TdTextFieldPassword(
// //                 controller: confirmPasswordController,
// //                 onChanged: (_) => setState(() {}),
// //                 hintText: 'Confirm Password',
// //                 validator:
// //                     Validator.confirmPassword(newPasswordController.text),
// //                 onFieldSubmitted: (_) => _changePassword(context),
// //                 textInputAction: TextInputAction.done,
// //               ),
// //               const SizedBox(height: 92.0),
// //               TdElevatedButton.outline(
// //                 onPressed: () => _changePassword(context),
// //                 text: 'Done',
// //                 isDisable: isLoading,
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
