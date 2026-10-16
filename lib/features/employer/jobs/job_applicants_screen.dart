
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class JobApplicantsScreen extends StatefulWidget {
  const JobApplicantsScreen({
    super.key,
    required this.job,
  });

  final Map<String, dynamic> job;

  @override
  State<JobApplicantsScreen> createState() =>
      _JobApplicantsScreenState();
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
                  applicant['full_name']?.toString() ??
                      'Applicant',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
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
                SelectableText(
                  applicant['resume_path']?.toString() ??
                      'No resume path available',
                ),
                const SizedBox(height: 8),
                const Text(
                  'The resume is stored privately. A secure employer '
                  'access link will be connected after storage '
                  'permissions are configured.',
                  style: TextStyle(
                    color: Color(0xFF9292A7),
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
            style: const TextStyle(
              color: Color(0xFF9292A7),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          SelectableText(
            text == null || text.isEmpty ? 'Not provided' : text,
          ),
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
            icon: const Icon(Icons.refresh_rounded),
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
                    const Icon(Icons.error_outline_rounded, size: 42),
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
                  const Icon(
                    Icons.people_outline_rounded,
                    size: 56,
                    color: Color(0xFF9B6DFF),
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
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text('${applicants.length} application(s)'),
                const SizedBox(height: 18),
                ...applicants.map((applicant) {
                  final name =
                      applicant['full_name']?.toString() ??
                      'Applicant';

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
                              const CircleAvatar(
                                backgroundColor: Color(0xFF302447),
                                child: Icon(
                                  Icons.person_outline_rounded,
                                  color: Color(0xFFB89AFF),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 17,
                                      ),
                                    ),
                                    Text(
                                      applicant['email']?.toString() ??
                                          'No email',
                                      style: const TextStyle(
                                        color: Color(0xFF9292A7),
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
                            icon: const Icon(Icons.person_search_rounded),
                            label: const Text('View Candidate Details'),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Application status',
                            style: TextStyle(
                              color: Color(0xFF9292A7),
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
                                  status[0].toUpperCase() +
                                      status.substring(1),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null &&
                                  value != currentStatus) {
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
