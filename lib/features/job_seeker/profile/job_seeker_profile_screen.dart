
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class JobSeekerProfileScreen extends StatefulWidget {
  const JobSeekerProfileScreen({super.key});

  @override
  State<JobSeekerProfileScreen> createState() =>
      _JobSeekerProfileScreenState();
}

class _JobSeekerProfileScreenState extends State<JobSeekerProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _headline = TextEditingController();
  final _phone = TextEditingController();
  final _city = TextEditingController();
  final _bio = TextEditingController();
  final _skills = TextEditingController();
  final _education = TextEditingController();
  final _experience = TextEditingController();
  final _portfolio = TextEditingController();
  final _linkedin = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  String? _error;

  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _name.dispose();
    _headline.dispose();
    _phone.dispose();
    _city.dispose();
    _bio.dispose();
    _skills.dispose();
    _education.dispose();
    _experience.dispose();
    _portfolio.dispose();
    _linkedin.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('Please log in first.');

      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (!mounted) return;

      if (data != null) {
        _name.text = (data['full_name'] ?? '').toString();
        _headline.text = (data['headline'] ?? '').toString();
        _phone.text = (data['phone'] ?? '').toString();
        _city.text = (data['city'] ?? '').toString();
        _bio.text = (data['bio'] ?? '').toString();
        _education.text = (data['education'] ?? '').toString();
        _experience.text = (data['experience'] ?? '').toString();
        _portfolio.text = (data['portfolio_url'] ?? '').toString();
        _linkedin.text = (data['linkedin_url'] ?? '').toString();

        final skills = data['skills'];
        if (skills is List) {
          _skills.text = skills.join(', ');
        }
      }

      setState(() => _loading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final user = _supabase.auth.currentUser;
    if (user == null) return;

    setState(() => _saving = true);

    try {
      final skills = _skills.text
          .split(RegExp(r'[,;\n]+'))
          .map((skill) => skill.trim())
          .where((skill) => skill.isNotEmpty)
          .toSet()
          .toList();

      await _supabase.from('profiles').update({
        'full_name': _name.text.trim(),
        'headline': _headline.text.trim(),
        'phone': _phone.text.trim(),
        'city': _city.text.trim(),
        'bio': _bio.text.trim(),
        'skills': skills,
        'education': _education.text.trim(),
        'experience': _experience.text.trim(),
        'portfolio_url': _portfolio.text.trim(),
        'linkedin_url': _linkedin.text.trim(),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', user.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved successfully!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save profile: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    int lines = 1,
    String? hint,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: lines,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          alignLabelWithHint: lines > 1,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            tooltip: 'Refresh profile',
            onPressed: _loading ? null : () {
              setState(() {
                _loading = true;
                _error = null;
              });
              _loadProfile();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _loading = true;
                              _error = null;
                            });
                            _loadProfile();
                          },
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  ),
                )
              : Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Center(
                        child: Column(
                          children: [
                            const CircleAvatar(
                              radius: 42,
                              child: Icon(Icons.person_outline, size: 42),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _name.text.isEmpty
                                  ? 'Your professional profile'
                                  : _name.text,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 5),
                            const Text('Make your next career move'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      const Text(
                        'Personal information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _field('Full name', _name),
                      _field('Professional headline', _headline,
                          hint: 'e.g. Flutter Developer'),
                      _field('Phone number', _phone,
                          keyboard: TextInputType.phone),
                      _field('City / Location', _city,
                          hint: 'e.g. Lahore, Pakistan'),
                      _field('Professional summary', _bio, lines: 4,
                          hint: 'Describe your experience and career goals'),
                      const SizedBox(height: 10),
                      const Text(
                        'Skills and qualifications',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _field('Skills', _skills, lines: 3,
                          hint: 'Flutter, Dart, Supabase'),
                      _field('Education', _education, lines: 2,
                          hint: 'Degree, university, graduation year'),
                      _field('Experience', _experience, lines: 3,
                          hint: 'Roles, projects and responsibilities'),
                      const SizedBox(height: 10),
                      const Text(
                        'Professional links',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _field('Portfolio URL', _portfolio,
                          keyboard: TextInputType.url),
                      _field('LinkedIn URL', _linkedin,
                          keyboard: TextInputType.url),
                      const SizedBox(height: 8),
                      FilledButton.icon(
                        onPressed: _saving ? null : _saveProfile,
                        icon: _saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.save_outlined),
                        label: Text(
                          _saving ? 'Saving...' : 'Save Profile',
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
