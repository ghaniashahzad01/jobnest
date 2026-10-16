import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class JobApplicantsScreen extends StatefulWidget {
  const JobApplicantsScreen({super.key, required this.job});

  final Map<String, dynamic> job;

  @override
  State<JobApplicantsScreen> createState() => _JobApplicantsScreenState();
}

class _JobApplicantsScreenState extends State<JobApplicantsScreen> {
  late Future<List<Map<String, dynamic>>> applicantsFuture;

  final statuses = const [
    'applied',
    'reviewing',
    'shortlisted',
    'rejected',
    'hired',
  ];

  @override
  void initState() {
    super.initState();
    applicantsFuture = _loadApplicants();
  }

  Future<List<Map<String, dynamic>>> _loadApplicants() async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;

    if (user == null) {
      throw Exception('Please log in again.');
    }

    // Verify that this job belongs to the logged-in employer.
    final job = await client
        .from('jobs')
        .select('id')
        .eq('id', widget.job['id'])
        .eq('employer_id', user.id)
        .maybeSingle();

    if (job == null) {
      throw Exception('You do not have access to this job.');
    }

    final result = await client
        .from('applications')
        .select()
        .eq('job_id', widget.job['id'])
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(result);
  }

  Future<void> _refresh() async {
    final future = _loadApplicants();
    setState(() => applicantsFuture = future);
    await future;
  }

  Future<void> _updateStatus(
    Map<String, dynamic> applicant,
    String newStatus,
  ) async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;

    if (user == null) return;

    try {
      // Verify ownership again before updating.
      final job = await client
          .from('jobs')
          .select('id')
          .eq('id', widget.job['id'])
          .eq('employer_id', user.id)
          .maybeSingle();

      if (job == null) {
        throw Exception('You cannot update this application.');
      }

      await client
          .from('applications')
          .update({'status': newStatus})
          .eq('id', applicant['id'])
          .eq('job_id', widget.job['id']);

      if (!mounted) return;

      setState(() {
        applicant['status'] = newStatus;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Application status updated.')),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update status: $error')),
      );
    }
  }

  Future<void> _openResume(Map<String, dynamic> applicant) async {
    final resumePath = applicant['resume_path']?.toString().trim();

    if (resumePath == null || resumePath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No resume uploaded by this applicant.')),
      );
      return;
    }

    try {
      final client = Supabase.instance.client;

      // Generate a temporary link for the private resume.
      final signedUrl = await client.storage
          .from('resumes')
          .createSignedUrl(resumePath, 300);

      final uri = Uri.parse(signedUrl);
      final opened = await launchUrl(uri, webOnlyWindowName: '_blank');

      if (!opened && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the resume.')),
        );
      }
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Resume error: $error')));
    }
  }

  void _showDetails(Map<String, dynamic> applicant) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        final skills = applicant['skills'];
        final skillsText = skills is List
            ? skills.join(', ')
            : skills?.toString() ?? 'Not provided';

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 8, 22, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  applicant['full_name']?.toString() ?? 'Applicant',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 20),
                _detail('Email', applicant['email']),
                _detail('Phone', applicant['phone']),
                _detail('City', applicant['city']),
                _detail('Education', applicant['education']),
                _detail('Experience', applicant['experience']),
                _detail('Skills', skillsText),
                _detail(
                  'Cover letter',
                  applicant['cover_letter'] ?? 'Not provided',
                ),
                const SizedBox(height: 18),
                const Text(
                  'Resume',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                if (applicant['resume_path'] != null &&
                    applicant['resume_path'].toString().trim().isNotEmpty)
                  OutlinedButton.icon(
                    onPressed: () => _openResume(applicant),
                    icon: Icon(Icons.picture_as_pdf_rounded),
                    label: const Text('Open Resume / CV'),
                  )
                else
                  const Text('No resume uploaded'),
                const SizedBox(height: 8),
                Text(
                  'The resume is stored privately. A secure employer '
                  'access link will be connected after storage '
                  'permissions are configured.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detail(String label, dynamic value) {
    final text = value?.toString().trim();

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          SelectableText(text == null || text.isEmpty ? 'Not provided' : text),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.job['title'] ?? 'Job Applicants';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Applicants'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _refresh,
            icon: Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: applicantsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline_rounded, size: 42),
                    const SizedBox(height: 12),
                    Text(
                      'Could not load applicants.\n${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    TextButton(
                      onPressed: _refresh,
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              ),
            );
          }

          final applicants = snapshot.data ?? [];

          if (applicants.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                children: [
                  const SizedBox(height: 150),
                  Icon(
                    Icons.people_outline_rounded,
                    size: 56,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      'No applicants yet',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Applications for $title will appear here.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                Text(
                  '$title',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text('${applicants.length} application(s)'),
                const SizedBox(height: 18),
                ...applicants.map((applicant) {
                  final name =
                      applicant['full_name']?.toString() ?? 'Applicant';

                  final currentStatus =
                      applicant['status']?.toString() ?? 'applied';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 14),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.14),
                                child: Icon(
                                  Icons.person_outline_rounded,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 17,
                                      ),
                                    ),
                                    Text(
                                      applicant['email']?.toString() ??
                                          'No email',
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${applicant['city'] ?? 'City not provided'}'
                            ' • ${applicant['education'] ?? 'Education not provided'}',
                          ),
                          const SizedBox(height: 14),
                          OutlinedButton.icon(
                            onPressed: () => _showDetails(applicant),
                            icon: Icon(Icons.person_search_rounded),
                            label: const Text('View Candidate Details'),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Application status',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            initialValue: statuses.contains(currentStatus)
                                ? currentStatus
                                : null,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            hint: const Text('Select status'),
                            items: statuses.map((status) {
                              return DropdownMenuItem(
                                value: status,
                                child: Text(
                                  status[0].toUpperCase() + status.substring(1),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null && value != currentStatus) {
                                _updateStatus(applicant, value);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}
