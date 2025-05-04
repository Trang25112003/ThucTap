import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../routes/app_route.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;
  bool _isChangingPassword = false;

  Future<bool> _verifyCurrentPassword(String password) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        setState(() {
          _errorMessage = 'No user logged in';
        });
        return false;
      }

      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: user.email!,
        password: password,
      );

      if (response.user != null) {
        return true;
      } else {
        setState(() {
          _errorMessage = 'Current password is incorrect';
        });
        return false;
      }
    } on AuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
      return false;
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred. Please try again later.';
      });
      return false;
    }
  }

  Future<bool> _updatePassword(String newPassword) async {
    try {
      final response = await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      return response.user != null;
    } on AuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
      return false;
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred while updating password.';
      });
      return false;
    }
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Password Changed Successfully'),
          content: const Text('Do you want to log in again?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, AppRoutes.signin);
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, AppRoutes.profilePage);
              },
              child: const Text('No'),
            ),
          ],
        );
      },
    );
  }

  void _changePassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isChangingPassword = true;
      });

      bool isVerified =
          await _verifyCurrentPassword(_currentPasswordController.text);
      if (isVerified) {
        bool isUpdated = await _updatePassword(_newPasswordController.text);
        if (isUpdated) {
          _showConfirmationDialog();
        } else {
          setState(() {
            _errorMessage = 'Failed to update password';
            _isChangingPassword = false;
          });
        }
      } else {
        setState(() {
          _isChangingPassword = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9F5EC),
      appBar: AppBar(
    backgroundColor: Colors.green.shade600,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
           ),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 10.0, bottom: 10.0),
          child: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 187, 228, 196),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(8),
              child: const Icon(Icons.arrow_back, size: 24, color: Colors.black87),
            ),
          ),
        ),
        title: const Text(
          'Change password',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          // Vòng tròn trang trí
          Positioned(
            top: -60,
            left: -60,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.greenAccent.withOpacity(0.3),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            right: -40,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.lightGreen.withOpacity(0.3),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green.shade100.withOpacity(0.3),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: <Widget>[
                  const SizedBox(height: 16),
                  _buildPasswordField(
                    controller: _currentPasswordController,
                    label: 'Current password',
                    obscureText: _obscureCurrentPassword,
                    toggleVisibility: () {
                      setState(() {
                        _obscureCurrentPassword = !_obscureCurrentPassword;
                      });
                    },
                  ),
                  const SizedBox(height: 12.0),
                  _buildPasswordField(
                    controller: _newPasswordController,
                    label: 'New password',
                    obscureText: _obscureNewPassword,
                    toggleVisibility: () {
                      setState(() {
                        _obscureNewPassword = !_obscureNewPassword;
                      });
                    },
                  ),
                  const SizedBox(height: 12.0),
                  _buildPasswordField(
                    controller: _confirmPasswordController,
                    label: 'Confirm password',
                    obscureText: _obscureConfirmPassword,
                    toggleVisibility: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your new password';
                      }
                      if (value != _newPasswordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24.0),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Container(
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.white),
                            const SizedBox(width: 8.0),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ElevatedButton(
                    onPressed: _isChangingPassword ? null : _changePassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 113, 182, 116),
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: Text(
                      _isChangingPassword ? 'Changing...' : 'Change password',
                      style: const TextStyle(fontSize: 18.0, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isChangingPassword)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback toggleVisibility,
    FormFieldValidator<String>? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(16.0),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey.shade600,
          ),
          onPressed: toggleVisibility,
        ),
      ),
      validator: validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter $label'.toLowerCase();
            }
            if (label.toLowerCase().contains('new') && value.length < 6) {
              return 'New password must be at least 6 characters long';
            }
            return null;
          },
    );
  }
}
