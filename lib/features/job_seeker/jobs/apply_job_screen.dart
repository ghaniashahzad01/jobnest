
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class ApplyJobScreen extends StatefulWidget {
  const ApplyJobScreen({
    super.key,
    required this.job,
  });

  final Map<String, dynamic> job;

  @override
  State<ApplyJobScreen> createState() => _ApplyJobScreenState();
}

class _ApplyJobScreenState extends State<ApplyJobScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final cityController = TextEditingController();
  final educationController = TextEditingController();
  final experienceController = TextEditingController();
  final skillsController = TextEditingController();
  final coverLetterController = TextEditingController();

  Uint8List? resumeBytes;
  String? resumeName;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();

    final user = Supabase.instance.client.auth.currentUser;

    emailController.text = user?.email ?? '';
    nameController.text =
        user?.userMetadata?['full_name']?.toString() ?? '';
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    cityController.dispose();
    educationController.dispose();
    experienceController.dispose();
    skillsController.dispose();
    coverLetterController.dispose();
    super.dispose();
  }

  
Future<void> _pickResume() async {
  try {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.single;
    final bytes = file.bytes;

    if (bytes == null) {
      _showMessage('Could not read the selected file.');
      return;
    }

    if (file.size > 5 * 1024 * 1024) {
      _showMessage('Resume must be 5 MB or smaller.');
      return;
    }

    if (!mounted) return;

    setState(() {
      resumeBytes = bytes;
      resumeName = file.name;
    });
  } catch (error) {
    _showMessage('Could not select the resume.');
    debugPrint('File picker error: $error');
  }
}

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  InputDecoration _decoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
    );
  }

  String? _required(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required';
    }
    return null;
  }

  
Future<void> _submitApplication() async {
  if (!_formKey.currentState!.validate()) return;

  if (resumeBytes == null || resumeName == null) {
    _showMessage('Please upload your resume in PDF format.');
    return;
  }

  final client = Supabase.instance.client;
  final user = client.auth.currentUser;

  if (user == null) {
    _showMessage('Please log in before applying.');
    return;
  }

  setState(() => isSubmitting = true);

  String? uploadedPath;

  try {
    final jobId = widget.job['id'].toString();
    final safeName =
        resumeName!.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');

    uploadedPath =
        '${user.id}/$jobId/${DateTime.now().millisecondsSinceEpoch}_$safeName';

    await client.storage.from('resumes').uploadBinary(
      uploadedPath,
      resumeBytes!,
      fileOptions: const FileOptions(
        contentType: 'application/pdf',
        upsert: false,
      ),
    );

    await client.from('applications').insert({
      'job_id': jobId,
      'applicant_id': user.id,
      'status': 'applied',
      'full_name': nameController.text.trim(),
      'email': emailController.text.trim(),
      'phone': phoneController.text.trim(),
      'city': cityController.text.trim(),
      'education': educationController.text.trim(),
      'experience': experienceController.text.trim(),
      'skills': skillsController.text
          .split(',')
          .map((skill) => skill.trim())
          .where((skill) => skill.isNotEmpty)
          .toSet()
          .toList(),
      'resume_path': uploadedPath,
      'cover_letter': coverLetterController.text.trim().isEmpty
          ? null
          : coverLetterController.text.trim(),
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Application submitted successfully!')),
    );

    Navigator.pop(context, true);
  } on PostgrestException catch (error) {
    if (!mounted) return;
    _showMessage('Application failed: ${error.message}');
    debugPrint('Database error: ${error.message}');
  } on StorageException catch (error) {
    if (!mounted) return;
    _showMessage('Resume upload failed: ${error.message}');
    debugPrint('Storage error: ${error.message}');
  } catch (error) {
    if (!mounted) return;
    _showMessage('Something went wrong. Please try again.');
    debugPrint('Application error: $error');
  } finally {
    if (mounted) {
      setState(() => isSubmitting = false);
    }
  }
}


  @override
  Widget build(BuildContext context) {
    final job = widget.job;

    return Scaffold(
      appBar: AppBar(title: const Text('Job Application')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(22),
            children: [
              const Text(
                'Let’s get you noticed.',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Applying for ${job['title'] ?? 'this position'} at '
                '${job['company_name'] ?? 'the company'}.',
                style: const TextStyle(
                  color: Color(0xFF9292A7),
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 28),
              const Text(
                'Personal details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: nameController,
                textCapitalization: TextCapitalization.words,
                decoration: _decoration(
                  'Full name',
                  Icons.person_outline_rounded,
                ),
                validator: (value) => _required(value, 'Full name'),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _decoration(
                  'Email address',
                  Icons.email_outlined,
                ),
                validator: (value) {
                  if (value == null ||
                      !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                          .hasMatch(value.trim())) {
                    return 'Enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: _decoration(
                  'Phone number',
                  Icons.phone_outlined,
                ),
                validator: (value) => _required(value, 'Phone number'),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: cityController,
                decoration: _decoration(
                  'City',
                  Icons.location_on_outlined,
                ),
                validator: (value) => _required(value, 'City'),
              ),

              const SizedBox(height: 28),
              const Text(
                'Professional details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: educationController,
                decoration: _decoration(
                  'Education',
                  Icons.school_outlined,
                ),
                validator: (value) => _required(value, 'Education'),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: experienceController,
                maxLines: 3,
                decoration: _decoration(
                  'Experience',
                  Icons.work_history_outlined,
                ).copyWith(
                  hintText: 'Describe your experience or write Fresher',
                ),
                validator: (value) => _required(value, 'Experience'),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: skillsController,
                maxLines: 2,
                decoration: _decoration(
                  'Skills',
                  Icons.psychology_outlined,
                ).copyWith(
                  hintText: 'Flutter, Dart, SQL',
                ),
                validator: (value) => _required(value, 'Skills'),
              ),
              const SizedBox(height: 28),

              const Text(
                'Resume / CV',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'PDF only · Maximum 5 MB · Required',
                style: TextStyle(color: Color(0xFF9292A7)),
              ),
              const SizedBox(height: 12),

              OutlinedButton.icon(
                onPressed: isSubmitting ? null : _pickResume,
                icon: const Icon(Icons.upload_file_rounded),
                label: Text(
                  resumeName ?? 'Choose your resume (PDF)',
                ),
              ),

              const SizedBox(height: 28),
              const Text(
                'Cover letter (optional)',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),

              TextFormField(
                controller: coverLetterController,
                minLines: 4,
                maxLines: 7,
                maxLength: 3000,
                decoration: const InputDecoration(
                  hintText:
                      'Tell the employer why you are a good fit...',
                  alignLabelWithHint: true,
                ),
              ),

              const SizedBox(height: 24),
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed:
                      isSubmitting ? null : _submitApplication,
                  child: isSubmitting
                      ? const SizedBox(
                          height: 23,
                          width: 23,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Submit Application'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
