import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class MyCVPage extends StatefulWidget {
  @override
  _MyCVPageState createState() => _MyCVPageState();
}

class _MyCVPageState extends State<MyCVPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();

  File? _cvFile;
  String? _cvFileName;

  @override
  void initState() {
    super.initState();
    _loadCV();
  }

  Future<void> _loadCV() async {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) return;

  try {
    final cvData = await Supabase.instance.client
        .from('users')
        .select()
        .eq('account_id', userId) // ✅ sửa chỗ này
        .single();

    if (cvData != null) {
      setState(() {
        _nameController.text = cvData['name'] ?? '';
        _phoneController.text = cvData['phone'] ?? '';
        _emailController.text = cvData['email'] ?? '';
        _skillsController.text = cvData['skills'] ?? '';
        _experienceController.text = cvData['experience'] ?? '';
        _cvFileName = 'cv_$userId.pdf';
      });
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error loading CV: $e')),
    );
  }
}

Future<void> _saveCV() async {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("User not logged in")),
    );
    return;
  }

  final cvInfo = {
    'account_id': userId, // ✅ sửa từ 'id' thành 'account_id'
    'name': _nameController.text,
    'phone': _phoneController.text,
    'email': _emailController.text,
    'skills': _skillsController.text,
    'experience': _experienceController.text,
  };

  try {
    await Supabase.instance.client.from('users').upsert(cvInfo);

    if (_cvFile != null) {
      final fileBytes = await _cvFile!.readAsBytes();
      await Supabase.instance.client.storage.from('cvfiles').uploadBinary(
        'cv_$userId.pdf',
        fileBytes,
        fileOptions: const FileOptions(upsert: true, contentType: 'application/pdf'),
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("CV saved successfully!")),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error saving CV: $e")),
    );
  }
}


  Future<void> _uploadCV() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _cvFile = File(result.files.single.path!);
        _cvFileName = result.files.single.name;
      });
    }
  }

  void _viewCV() {
    if (_cvFile != null) {
      OpenFile.open(_cvFile!.path);
    }
  }

  void _deleteCV() {
    setState(() {
      _cvFile = null;
      _cvFileName = null;
    });
  }

  Future<void> _generatePdfFromForm() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Container(
          padding: const pw.EdgeInsets.all(20),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("Full Name: ${_nameController.text}", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.Text("Phone: ${_phoneController.text}", style: pw.TextStyle(fontSize: 14)),
              pw.SizedBox(height: 10),
              pw.Text("Email:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(_emailController.text),
              pw.SizedBox(height: 10),
              pw.Text("Skills:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(_skillsController.text),
              pw.SizedBox(height: 10),
              pw.Text("Experience:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(_experienceController.text),
            ],
          ),
        ),
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/my_cv.pdf");
    await file.writeAsBytes(await pdf.save());

    setState(() {
      _cvFile = file;
      _cvFileName = "my_cv.pdf";
    });

    await OpenFile.open(file.path);
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    TextInputAction inputAction = TextInputAction.next,
    void Function(String)? onSubmitted,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        textInputAction: inputAction,
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  // Hàm tạo chấm xanh
 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Cho phép cuộn khi bàn phím hiển thị
      backgroundColor: Colors.lightGreen.shade50, // Đặt nền màu xanh nhạt
      appBar: AppBar(
        title: const Text(
          "My CV",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.green.shade600,
        elevation: 4,
        iconTheme: IconThemeData(color: Colors.white),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      body: Stack( 
        children: [
          // Các chấm xanh sẽ được hiển thị dưới đây
  
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildTextField('Full Name', _nameController),
                  _buildTextField('Phone', _phoneController),
                  _buildTextField('Email', _emailController),
                  _buildTextField('Skills', _skillsController),
                  _buildTextField(
                    'Experience',
                    _experienceController,
                    inputAction: TextInputAction.done,
                    onSubmitted: (_) => FocusScope.of(context).unfocus(),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _generatePdfFromForm,
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('Generate CV as PDF'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: _uploadCV,
                    icon: const Icon(Icons.upload_file),
                    label: Text(_cvFileName ?? 'Upload CV (PDF)'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  if (_cvFile != null) ...[
                    TextButton(
                      onPressed: _viewCV,
                      child: const Text("View Current CV"),
                    ),
                    TextButton(
                      onPressed: _deleteCV,
                      child: const Text("Delete Uploaded CV", style: TextStyle(color: Colors.red)),
                    ),
                  ],
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saveCV,
                    child: const Text("Save CV"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
