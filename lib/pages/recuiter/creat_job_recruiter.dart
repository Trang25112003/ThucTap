import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

import '../../models/business_model.dart';
import '../../models/job_model.dart';
import '../../services/business_service.dart';
import '../../services/local/spabase_service.dart';

class CreateJobPage extends StatefulWidget {
  @override
  _CreateJobPageState createState() => _CreateJobPageState();
}

class _CreateJobPageState extends State<CreateJobPage> {
  final _formKey = GlobalKey<FormState>();
  final _positionController = TextEditingController();
  final _salaryController = TextEditingController();
  final _contentController = TextEditingController();
  final _otherBusinessNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _websiteController = TextEditingController();
  final _startDateController = TextEditingController();
  final _dueDateController = TextEditingController();
  final _typesController = TextEditingController();

  Business? _selectedBusiness;
  bool _isOtherBusinessSelected = false;
  List<Business> _businesses = [];
  XFile? _pickedLogoFile;
  String? _uploadedLogoUrl;
  List<String> _selectedLevels = [];
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _fetchBusinesses();
  }

  Future<void> _fetchBusinesses() async {
    final allBusinesses = await BusinessService.fetchAllBusinesses();
    final uniqueBusinessesMap = <String, Business>{};
    for (final business in allBusinesses) {
      if (business.name != null &&
          !uniqueBusinessesMap.containsKey(business.name)) {
        uniqueBusinessesMap[business.name!] = business;
      }
    }
    setState(() {
      _businesses = uniqueBusinessesMap.values.toList();
      _businesses.add(Business(id: '-1', name: 'Other'));
    });
  }

  Future<void> _pickLogoImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _pickedLogoFile = image;
        _uploadedLogoUrl = null;
      });
    }
  }

  Future<String?> _uploadLogoImage() async {
    if (_pickedLogoFile == null) {
      return null;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final fileName = path.basename(_pickedLogoFile!.path);
      final bytes = await _pickedLogoFile!.readAsBytes();
      final fileExt = path.extension(_pickedLogoFile!.path).toLowerCase();
      final storage = Supabase.instance.client.storage;
      final String bucketId = 'avatars';
      final String filePath =
          'logos/$fileName${DateTime.now().millisecondsSinceEpoch}$fileExt';

      String? contentType;
      if (fileExt.isNotEmpty && fileExt.startsWith('.')) {
        contentType = 'image/${fileExt.substring(1)}';
      }

      if (contentType != null) {
        await storage.from(bucketId).uploadBinary(
              filePath,
              bytes,
              fileOptions: FileOptions(contentType: contentType),
            );

        final publicUrl = storage.from(bucketId).getPublicUrl(filePath);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logo uploaded successfully!')),
        );
        return publicUrl;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid file format')),
        );
        return null;
      }
    } catch (error) {
      print('Lỗi tải lên logo: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading logo: $error')),
      );
      return null;
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Widget _buildLogoSelection() {
    Widget imageDisplay;
    if (_pickedLogoFile != null) {
      imageDisplay = CircleAvatar(
        radius: 60,
        backgroundImage: FileImage(File(_pickedLogoFile!.path)),
      );
    } else if (_uploadedLogoUrl != null) {
      imageDisplay = CircleAvatar(
        radius: 60,
        backgroundImage: NetworkImage(_uploadedLogoUrl!),
      );
    } else {
      imageDisplay = const CircleAvatar(
        radius: 60,
        child: Icon(Icons.image, size: 40),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: Align(
        alignment: Alignment.center,
        child: Column(
          children: [
            imageDisplay,
            const SizedBox(height: 16),
            ElevatedButton(
                onPressed: _pickLogoImage,
                child: const Text('Pick Logo Image')),
            if (_uploadedLogoUrl != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text('Uploaded URL: $_uploadedLogoUrl',
                    style: const TextStyle(fontSize: 12)),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Widget _buildLevelsCheckbox() {
    final levels = [
      'Intern',
      'Fresher',
      'Junior',
      'Mid-level',
      'Senior',
      'Leader',
      'All levels'
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Levels*', style: TextStyle(fontWeight: FontWeight.bold)),
        Wrap(
          spacing: 8.0,
          children: levels.map((level) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: _selectedLevels.contains(level),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        if (level == 'All levels') {
                          _selectedLevels.clear();
                          _selectedLevels.add(level);
                        } else {
                          _selectedLevels.remove('All levels');
                          _selectedLevels.add(level);
                        }
                      } else {
                        _selectedLevels.remove(level);
                      }
                    });
                  },
                ),
                Text(level),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Job Post",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.white,
            )),
        backgroundColor: Colors.green[300],
        elevation: 4,
         leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_isOtherBusinessSelected) ...[
                  const SizedBox(height: 16),
                  _buildLogoSelection(),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _otherBusinessNameController,
                    decoration:
                        const InputDecoration(labelText: 'Company Name*'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the company name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                DropdownButtonFormField<Business>(
                  value: _selectedBusiness,
                  items: _businesses
                      .map((business) => DropdownMenuItem<Business>(
                            value: business,
                            child: Text(business.name == 'Other'
                                ? 'Other'
                                : (business.name ?? 'Unknown')),
                          ))
                      .toList(),
                  onChanged: (Business? newBusiness) {
                    setState(() {
                      _selectedBusiness = newBusiness;
                      _isOtherBusinessSelected = newBusiness?.id == '-1';
                      if (_isOtherBusinessSelected) {
                        _selectedBusiness = null;
                        _pickedLogoFile = null;
                        _uploadedLogoUrl = null;
                      }
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Select Business*',
                  ),
                  validator: (value) {
                    if (value == null && !_isOtherBusinessSelected) {
                      return 'Please select a business or choose "Other"';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: 'Address*'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _websiteController,
                  decoration: const InputDecoration(labelText: 'Website'),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _startDateController,
                        decoration: InputDecoration(
                          labelText: 'Start date*',
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () =>
                                _selectDate(context, _startDateController),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select the start date';
                          }
                          return null;
                        },
                        readOnly: true,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _dueDateController,
                        decoration: InputDecoration(
                          labelText: 'Due date*',
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () =>
                                _selectDate(context, _dueDateController),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select the due date';
                          }
                          return null;
                        },
                        readOnly: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _positionController,
                  decoration: const InputDecoration(labelText: 'Position*'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a position';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildLevelsCheckbox(),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _typesController,
                  decoration: const InputDecoration(labelText: 'Types*'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter job types';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: _isUploading
                        ? null
                        : () async {
                            if (_formKey.currentState?.validate() ?? false) {
                              String? businessIdToUse = _selectedBusiness?.id;
                              String? businessNameToUse =
                                  _selectedBusiness?.name;
                              String? businessLogoToUse =
                                  _selectedBusiness?.avatar;

                              if (_isOtherBusinessSelected) {
                                if (_otherBusinessNameController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Please enter the company name')),
                                  );
                                  return;
                                }
                                if (_pickedLogoFile != null) {
                                  final uploadedUrl = await _uploadLogoImage();
                                  if (uploadedUrl == null) {
                                    return;
                                  }
                                  businessLogoToUse = uploadedUrl;
                                }
                                businessIdToUse = null;
                                businessNameToUse =
                                    _otherBusinessNameController.text;

                                final newBusiness = Business(
                                    name: businessNameToUse,
                                    avatar: businessLogoToUse);
                                final job = Job(
                                  position: _positionController.text,
                                  salary: int.tryParse(_salaryController.text),
                                  content: _contentController.text,
                                  business_id: businessIdToUse,
                                  business: newBusiness,
                                  startDay: _startDateController.text,
                                  endDay: _dueDateController.text,
                                  levels: _selectedLevels.join(', '),
                                  types: _typesController.text,
                                );

                                SupabaseService.createJobPost(job).then((_) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Job post created (new business)')),
                                  );
                                  Navigator.pop(context);
                                }).catchError((error) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $error')),
                                  );
                                });
                              } else {
                                final job = Job(
                                  position: _positionController.text,
                                  salary: int.tryParse(_salaryController.text),
                                  content: _contentController.text,
                                  business_id: businessIdToUse,
                                  startDay: _startDateController.text,
                                  endDay: _dueDateController.text,
                                  levels: _selectedLevels.join(', '),
                                  types: _typesController.text,
                                );

                                SupabaseService.createJobPost(job).then((_) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Job post created')),
                                  );
                                  Navigator.pop(context);
                                }).catchError((error) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $error')),
                                  );
                                });
                              }
                            }
                          },
                    child: _isUploading
                        ? const CircularProgressIndicator()
                        : const Text('Create Post'),
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
