import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostJobScreen extends StatefulWidget {
  const PostJobScreen({super.key});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final _formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final companyController = TextEditingController();
  final descriptionController = TextEditingController();
  final locationController = TextEditingController();
  final skillsController = TextEditingController();

  String jobType = 'Full-time';
  String workplaceType = 'On-site';
  bool isLoading = false;

  @override
  void dispose() {
    titleController.dispose();
    companyController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    skillsController.dispose();
    super.dispose();
  }

  Future<void> _submitJob() async {
    if (!_formKey.currentState!.validate()) return;

    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      _showMessage('Please log in again to post a job.');
      return;
    }

    setState(() => isLoading = true);

    try {
      final skills = skillsController.text
          .split(',')
          .map((skill) => skill.trim())
          .where((skill) => skill.isNotEmpty)
          .toSet()
          .toList();

      await Supabase.instance.client.from('jobs').insert({
        'employer_id': user.id,
        'title': titleController.text.trim(),
        'company_name': companyController.text.trim(),
        'description': descriptionController.text.trim(),
        'location': locationController.text.trim(),
        'job_type': jobType,
        'workplace_type': workplaceType,
        'required_skills': skills,
        'status': 'active',
      });

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Job posted successfully!')));

      Navigator.pop(context, true);
    } on PostgrestException catch (error) {
      if (!mounted) return;
      _showMessage('Could not post job: ${error.message}');
    } catch (error) {
      if (!mounted) return;
      _showMessage('Something went wrong. Please try again.');
      debugPrint('Post job error: $error');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  InputDecoration _decoration(String hint, IconData icon) {
    return InputDecoration(hintText: hint, prefixIcon: Icon(icon));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post a Job')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Find your next great hire.',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  'Share the role details so candidates know what you need.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 28),

                const Text('Job title'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: titleController,
                  decoration: _decoration(
                    'e.g. Flutter Developer',
                    Icons.work_outline_rounded,
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter a job title'
                      : null,
                ),

                const SizedBox(height: 20),
                const Text('Company name'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: companyController,
                  decoration: _decoration(
                    'e.g. NexAppra',
                    Icons.business_outlined,
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter the company name'
                      : null,
                ),

                const SizedBox(height: 20),
                const Text('Job description'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: descriptionController,
                  minLines: 4,
                  maxLines: 7,
                  decoration: _decoration(
                    'Responsibilities, requirements and benefits...',
                    Icons.description_outlined,
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter the job description'
                      : null,
                ),

                const SizedBox(height: 20),
                const Text('Location'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: locationController,
                  decoration: _decoration(
                    'e.g. Lahore, Pakistan',
                    Icons.location_on_outlined,
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter a location'
                      : null,
                ),

                const SizedBox(height: 20),
                const Text('Employment type'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: jobType,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.schedule_rounded),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Full-time',
                      child: Text('Full-time'),
                    ),
                    DropdownMenuItem(
                      value: 'Part-time',
                      child: Text('Part-time'),
                    ),
                    DropdownMenuItem(
                      value: 'Internship',
                      child: Text('Internship'),
                    ),
                    DropdownMenuItem(
                      value: 'Contract',
                      child: Text('Contract'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => jobType = value);
                  },
                ),

                const SizedBox(height: 20),
                const Text('Workplace type'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: workplaceType,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.laptop_outlined),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'On-site', child: Text('On-site')),
                    DropdownMenuItem(value: 'Remote', child: Text('Remote')),
                    DropdownMenuItem(value: 'Hybrid', child: Text('Hybrid')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => workplaceType = value);
                    }
                  },
                ),

                const SizedBox(height: 20),
                const Text('Required skills'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: skillsController,
                  decoration: _decoration(
                    'Flutter, Dart, REST APIs',
                    Icons.psychology_outlined,
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter at least one skill'
                      : null,
                ),
                const SizedBox(height: 6),
                Text(
                  'Separate skills with commas.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _submitJob,
                    child: isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Publish Job'),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
