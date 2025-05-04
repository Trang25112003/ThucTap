import 'package:flutter/material.dart';
import 'package:job_supabase/services/local/spabase_service.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController companyAddressController = TextEditingController();

  String selectedRole = 'job_seeker';
  bool _isLoading = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final supabaseService = SupabaseService();
      await supabaseService.register(
        emailController.text.trim(),
        passwordController.text.trim(),
        nameController.text.trim(),
        phoneController.text.trim(),
        selectedRole,
        companyName: selectedRole == 'recruiter' ? companyNameController.text.trim() : null,
        companyAddress: selectedRole == 'recruiter' ? companyAddressController.text.trim() : null,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(selectedRole == 'recruiter'
              ? 'Your account has been created. Please wait for admin approval.'
              : 'Registration successful!'),
        ),
      );

      Navigator.pushNamed(context, '/signin');
    } catch (e) {
  String errorMessage = e.toString();
  if (errorMessage.contains("User already registered")) {
    errorMessage = "This email is already registered. Try another email!";
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(errorMessage)),
  );
}
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon,
      {bool isPassword = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.black54),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
      validator: (value) => value!.isEmpty ? 'Please enter $label' : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDDEFE1), // Màu nền xanh lá nhạt
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 40),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20,),
                // Tiêu đề
                 Text(
                  "Register",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 20),

                // Form nhập dữ liệu
                _buildTextField(nameController, 'Full Name', Icons.person),
                const SizedBox(height: 12),
                _buildTextField(phoneController, 'Phone Number', Icons.phone),
                const SizedBox(height: 12),
                _buildTextField(emailController, 'Email', Icons.email),
                const SizedBox(height: 12),
                _buildTextField(passwordController, 'Password', Icons.lock, isPassword: true),
                const SizedBox(height: 15),

                // Chọn vai trò
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: InputDecoration(
                    labelText: 'Choose Role',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'job_seeker', child: Text('Job Seeker')),
                    DropdownMenuItem(value: 'recruiter', child: Text('Recruiter')),
                  ],
                  onChanged: (value) => setState(() => selectedRole = value!),
                ),
                const SizedBox(height: 12),

                // Chỉ hiển thị nếu chọn "Nhà tuyển dụng"
                if (selectedRole == 'recruiter') ...[
                  _buildTextField(companyNameController, 'Company Name', Icons.business),
                  const SizedBox(height: 12),
                  _buildTextField(companyAddressController, 'Company Address', Icons.location_on),
                  const SizedBox(height: 12),
                ],

                const SizedBox(height: 20),
                // Nút đăng ký
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      backgroundColor: const Color(0xFF3C6E47), // Màu xanh đậm của nút
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Register',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                  ),
                ),


                const SizedBox(height: 20),
                // Chuyển sang trang đăng nhập
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account? ", style: TextStyle(color: Colors.black54)),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/signin'),
                      child: const Text("Login now",
                          style: TextStyle(color: Color(0xFF3C6E47), fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
