
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'apply_job_screen.dart';

class JobDetailsScreen extends StatefulWidget {
  const JobDetailsScreen({
    super.key,
    required this.job,
  });

  final Map<String, dynamic> job;

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  bool isLoading = false;
  bool hasApplied = false;
  bool checkingApplication = true;

  @override
  void initState() {
    super.initState();
    _checkApplication();
  }

  Future<void> _checkApplication() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;

      if (user == null) {
        if (mounted) {
          setState(() => checkingApplication = false);
        }
        return;
      }

      final existing = await Supabase.instance.client
          .from('applications')
          .select('id')
          .eq('job_id', widget.job['id'])
          .eq('applicant_id', user.id)
          .maybeSingle();

      if (!mounted) return;

      setState(() {
        hasApplied = existing != null;
        checkingApplication = false;
      });
    } catch (error) {
      debugPrint('Application check error: $error');

      if (mounted) {
        setState(() => checkingApplication = false);
      }
    }
  }

  Future<void> _applyForJob() async {
  final user = Supabase.instance.client.auth.currentUser;

  if (user == null) {
    _showMessage('Please log in before applying.');
    return;
  }

  setState(() => isLoading = true);

  try {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ApplyJobScreen(job: widget.job),
      ),
    );

    if (!mounted) return;

    if (result == true) {
      setState(() => hasApplied = true);
    }
  } catch (error) {
    if (!mounted) return;
    _showMessage('Could not open application form.');
    debugPrint('Open application form error: $error');
  } finally {
    if (mounted) {
      setState(() => isLoading = false);
    }
  }
}

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;
    final skills = List<String>.from(job['required_skills'] ?? []);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF9B6DFF)
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.work_outline_rounded,
                        color: Color(0xFF9B6DFF),
                        size: 38,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      job['title'] ?? 'Untitled job',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      job['company_name'] ?? '',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Color(0xFFB49AFF),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _DetailChip(
                          icon: Icons.location_on_outlined,
                          label: job['location'] ?? 'Not specified',
                        ),
                        _DetailChip(
                          icon: Icons.schedule_rounded,
                          label: job['job_type'] ?? 'Full-time',
                        ),
                        _DetailChip(
                          icon: Icons.laptop_outlined,
                          label: job['workplace_type'] ?? 'On-site',
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'About this role',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      job['description'] ?? 'No description provided.',
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.7,
                        color: Color(0xFFCBC7D7),
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Required skills',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (skills.isEmpty)
                      const Text('No specific skills listed.')
                    else
                      Wrap(
                        spacing: 9,
                        runSpacing: 9,
                        children: skills.map((skill) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 13,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF22202F),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFF353044),
                              ),
                            ),
                            child: Text(skill),
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 18),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ||
                          checkingApplication ||
                          hasApplied
                      ? null
                      : _applyForJob,
                  child: isLoading || checkingApplication
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          hasApplied ? 'Already Applied' : 'Apply Now',
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF22202F),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: const Color(0xFFB49AFF),
          ),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
    );
  }
}
