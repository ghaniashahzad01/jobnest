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

  @override
  void initState() {
    super.initState();
    jobsFuture = _loadJobs();
  }

  Future<List<Map<String, dynamic>>> _loadJobs() async {
  final client = Supabase.instance.client;
  final session = client.auth.currentSession;
  final user = client.auth.currentUser;

  debugPrint('Current session exists: ${session != null}');
  debugPrint('Current user ID: ${user?.id}');

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Jobs')),
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
                  Center(child: Text('Error: ${snapshot.error}')),
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
                children: const [
                  SizedBox(height: 150),
                  Icon(
                    Icons.work_outline_rounded,
                    size: 52,
                    color: Color(0xFF9B6DFF),
                  ),
                  SizedBox(height: 16),
                  Center(child: Text('No jobs posted yet')),
                  SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Your published jobs will appear here.',
                      style: TextStyle(color: Color(0xFF9292A7)),
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
                final skills = List<String>.from(job['required_skills'] ?? []);

                return Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job['title'] ?? 'Untitled job',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(job['company_name'] ?? ''),
                        const SizedBox(height: 10),
                        Text(
                          '${job['location']} • ${job['workplace_type']}',
                          style: const TextStyle(color: Color(0xFF9292A7)),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          skills.isEmpty
                              ? 'No skills listed'
                              : skills.join(' • '),
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Chip(label: Text(job['status'] ?? 'active')),
                            const Spacer(),
                            TextButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        JobApplicantsScreen(job: job),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.people_outline_rounded),
                              label: const Text('View Applicants'),
                            ),
                          ],
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
