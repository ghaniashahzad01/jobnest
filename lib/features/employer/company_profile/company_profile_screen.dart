
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CompanyProfileScreen extends StatefulWidget {
  const CompanyProfileScreen({super.key});

  @override
  State<CompanyProfileScreen> createState() =>
      _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends State<CompanyProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _companyName = TextEditingController();
  final _website = TextEditingController();
  final _industry = TextEditingController();
  final _size = TextEditingController();
  final _description = TextEditingController();
  final _city = TextEditingController();

  final _supabase = Supabase.instance.client;

  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCompany();
  }

  @override
  void dispose() {
    _companyName.dispose();
    _website.dispose();
    _industry.dispose();
    _size.dispose();
    _description.dispose();
    _city.dispose();
    super.dispose();
  }

  Future<void> _loadCompany() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('Please log in first.');

      final profile = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (!mounted) return;

      if (profile != null) {
        _companyName.text = (profile['company_name'] ?? '').toString();
        _website.text = (profile['company_website'] ?? '').toString();
        _industry.text = (profile['industry'] ?? '').toString();
        _size.text = (profile['company_size'] ?? '').toString();
        _description.text =
            (profile['company_description'] ?? '').toString();
        _city.text = (profile['city'] ?? '').toString();
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

  Future<void> _saveCompany() async {
    if (!_formKey.currentState!.validate()) return;

    final user = _supabase.auth.currentUser;
    if (user == null) return;

    setState(() => _saving = true);

    try {
      await _supabase.from('profiles').update({
        'company_name': _companyName.text.trim(),
        'company_website': _website.text.trim(),
        'industry': _industry.text.trim(),
        'company_size': _size.text.trim(),
        'company_description': _description.text.trim(),
        'city': _city.text.trim(),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', user.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Company profile saved!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save company profile: $e')),
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
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: lines,
        validator: validator,
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
      appBar: AppBar(title: const Text('Company Profile')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'Could not load company profile:\n$_error',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      const CircleAvatar(
                        radius: 34,
                        child: Icon(Icons.business_outlined, size: 34),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Build your company presence',
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Help candidates understand your company '
                        'and the opportunities you offer.',
                      ),
                      const SizedBox(height: 24),
                      _field(
                        'Company name *',
                        _companyName,
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? 'Enter your company name'
                                : null,
                      ),
                      _field(
                        'Company website',
                        _website,
                        hint: 'https://example.com',
                      ),
                      _field(
                        'Industry',
                        _industry,
                        hint: 'e.g. Software, Healthcare, Finance',
                      ),
                      _field(
                        'Company size',
                        _size,
                        hint: 'e.g. 11–50 employees',
                      ),
                      _field(
                        'City / Location',
                        _city,
                        hint: 'e.g. Lahore, Pakistan',
                      ),
                      _field(
                        'About the company',
                        _description,
                        lines: 5,
                        hint: 'Describe your mission, team and culture',
                      ),
                      const SizedBox(height: 8),
                      FilledButton.icon(
                        onPressed: _saving ? null : _saveCompany,
                        icon: _saving
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.save_outlined),
                        label: Text(
                          _saving ? 'Saving...' : 'Save Company Profile',
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
