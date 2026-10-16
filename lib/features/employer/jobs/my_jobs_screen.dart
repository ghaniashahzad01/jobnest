import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'job_applicants_screen.dart';

class MyJobsScreen extends StatefulWidget {
  const MyJobsScreen({super.key});

  @override
  State<MyJobsScreen> createState() => _MyJobsScreenState();
}

class _MyJobsScreenState extends State<MyJobsScreen> {
  late Future<List<Map<String, dynamic>>> jobsFuture;
  final client = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    jobsFuture = _loadJobs();
  }

  Future<List<Map<String, dynamic>>> _loadJobs() async {
    final user = client.auth.currentUser;

    if (user == null) {
      throw Exception('Please log in again.');
    }

    final response = await client
        .from('jobs')
        .select()
        .eq('employer_id', user.id)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> _refresh() async {
    final future = _loadJobs();
    setState(() => jobsFuture = future);
    await future;
  }

  Future<void> _updateJobStatus(
    Map<String, dynamic> job,
    String newStatus,
  ) async {
    try {
      final user = client.auth.currentUser;
      if (user == null) {
        throw Exception('Please log in again.');
      }

      await client
          .from('jobs')
          .update({'status': newStatus})
          .eq('id', job['id'])
          .eq('employer_id', user.id);

      if (!mounted) return;

      setState(() {
        jobsFuture = _loadJobs();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newStatus == 'active'
                ? 'Job activated successfully'
                : 'Job paused successfully',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not update job: $e')));
    }
  }

  Future<void> _deleteJob(Map<String, dynamic> job) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this job?'),
        content: Text(
          'Are you sure you want to delete '
          '"${job['title'] ?? 'this job'}"? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      final user = client.auth.currentUser;
      if (user == null) {
        throw Exception('Please log in again.');
      }

      await client
          .from('jobs')
          .delete()
          .eq('id', job['id'])
          .eq('employer_id', user.id);

      if (!mounted) return;

      setState(() {
        jobsFuture = _loadJobs();
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Job deleted successfully')));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not delete job. It may have linked applications, '
            'or database permissions may prevent deletion. Details: $e',
          ),
        ),
      );
    }
  }

  Color _statusColor(BuildContext context, String status) {
    final colors = Theme.of(context).colorScheme;

    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'paused':
        return colors.tertiary;
      case 'closed':
        return colors.error;
      default:
        return colors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Jobs'),
        actions: [
          IconButton(
            tooltip: 'Refresh jobs',
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: jobsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return ListView(
                children: [
                  const SizedBox(height: 140),
                  const Icon(Icons.cloud_off_outlined, size: 48),
                  const SizedBox(height: 12),
                  const Center(child: Text('Could not load jobs')),
                  Center(
                    child: TextButton(
                      onPressed: _refresh,
                      child: const Text('Try again'),
                    ),
                  ),
                ],
              );
            }

            final jobs = snapshot.data ?? [];

            if (jobs.isEmpty) {
              return ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const SizedBox(height: 120),
                  Icon(
                    Icons.work_outline_rounded,
                    size: 56,
                    color: colors.primary,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'No jobs posted yet',
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Your jobs will appear here after you post them.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(18),
              itemCount: jobs.length,
              itemBuilder: (context, index) {
                final job = jobs[index];

                final status = (job['status'] ?? 'active')
                    .toString()
                    .toLowerCase();

                final isActive = status == 'active';

                final skills = List<String>.from(job['required_skills'] ?? []);

                final statusColor = _statusColor(context, status);

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                job['title'] ?? 'Untitled job',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            PopupMenuButton<String>(
                              tooltip: 'Manage job',
                              onSelected: (value) {
                                if (value == 'delete') {
                                  _deleteJob(job);
                                }
                              },
                              itemBuilder: (_) => const [
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete_outline),
                                      SizedBox(width: 10),
                                      Text('Delete job'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          job['company_name'] ?? '',
                          style: theme.textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${job['location'] ?? 'Location not specified'}'
                          ' • ${job['workplace_type'] ?? 'Workplace not specified'}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          skills.isEmpty
                              ? 'No skills listed'
                              : skills.join(' • '),
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Chip(
                              avatar: Icon(
                                isActive
                                    ? Icons.check_circle_outline
                                    : Icons.pause_circle_outline,
                                size: 18,
                                color: statusColor,
                              ),
                              label: Text(status.toUpperCase()),
                              side: BorderSide(
                                color: statusColor.withValues(alpha: 0.4),
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => _updateJobStatus(
                                job,
                                isActive ? 'paused' : 'active',
                              ),
                              icon: Icon(
                                isActive
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                              ),
                              label: Text(isActive ? 'Deactivate' : 'Activate'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => JobApplicantsScreen(job: job),
                                ),
                              );

                              if (mounted) {
                                _refresh();
                              }
                            },
                            icon: const Icon(Icons.people_outline_rounded),
                            label: const Text('View Applicants'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
