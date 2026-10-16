import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../company_profile/company_profile_screen.dart';
import '../../auth/screens/welcome_screen.dart';
import '../jobs/post_job_screen.dart';
import '../jobs/my_jobs_screen.dart';

class EmployerDashboard extends StatefulWidget {
  const EmployerDashboard({super.key});

  @override
  State<EmployerDashboard> createState() => _EmployerDashboardState();
}

class _EmployerDashboardState extends State<EmployerDashboard> {
  late Future<Map<String, int>> statsFuture;
  bool isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    statsFuture = _loadStats();
  }

  Future<Map<String, int>> _loadStats() async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;

    if (user == null) {
      throw Exception('Please log in again.');
    }

    // Load jobs belonging to the logged-in employer.
    final response = await client
        .from('jobs')
        .select('id, status')
        .eq('employer_id', user.id);

    final jobs = List<Map<String, dynamic>>.from(response);

    final activeJobs = jobs.where((job) => job['status'] == 'active').length;

    // Count applications submitted for these jobs.
    var applicants = 0;

    for (final job in jobs) {
      final result = await client
          .from('applications')
          .select('id')
          .eq('job_id', job['id']);

      applicants += (result as List).length;
    }

    return {'activeJobs': activeJobs, 'applicants': applicants};
  }

  Future<void> _refreshStats() async {
    final future = _loadStats();

    setState(() {
      statsFuture = future;
    });

    try {
      await future;
    } catch (_) {
      // The FutureBuilder below displays the error.
    }
  }

  Future<void> _logout() async {
    if (isLoggingOut) return;

    setState(() => isLoggingOut = true);

    try {
      await Supabase.instance.client.auth.signOut();

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        (route) => false,
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Logout failed: $error')));

      setState(() => isLoggingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employer Portal'),
        actions: [
          IconButton(
            tooltip: 'Refresh dashboard',
            onPressed: _refreshStats,
            icon: const Icon(Icons.refresh_rounded),
          ),
          IconButton(
            tooltip: 'Log out',
            onPressed: isLoggingOut ? null : _logout,
            icon: isLoggingOut
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshStats,
          child: ListView(
            padding: const EdgeInsets.all(22),
            children: [
              const Text(
                'Hire the right talent.',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              const Text(
                'Manage jobs and discover promising candidates.',
                style: TextStyle(color: Color(0xFF9292A7)),
              ),
              const SizedBox(height: 26),

              // Live database statistics.
              FutureBuilder<Map<String, int>>(
                future: statsFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Could not load dashboard statistics.'),
                            const SizedBox(height: 8),
                            Text(
                              '${snapshot.error}',
                              style: const TextStyle(
                                color: Color(0xFF9292A7),
                                fontSize: 12,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: _refreshStats,
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('Try again'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final stats = snapshot.data;

                  return Column(
                    children: [
                      if (snapshot.connectionState == ConnectionState.waiting)
                        const LinearProgressIndicator(),
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              icon: Icons.work_outline_rounded,
                              title: 'Active Jobs',
                              value: stats?['activeJobs']?.toString() ?? '—',
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.people_outline_rounded,
                              title: 'Applicants',
                              value: stats?['applicants']?.toString() ?? '—',
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 22),

              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.add_circle_outline_rounded,
                    color: Color(0xFF9B6DFF),
                  ),
                  title: const Text('Post a Job'),
                  subtitle: const Text('Create a new job listing.'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () async {
                    final result = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(builder: (_) => const PostJobScreen()),
                    );

                    if (!mounted) return;

                    if (result == true) {
                      await _refreshStats();

                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Your job has been published.'),
                        ),
                      );
                    }
                  },
                ),
              ),

              Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(18),
                  leading: const Icon(
                    Icons.business_outlined,
                    color: Color(0xFF9B6DFF),
                    size: 30,
                  ),
                  title: const Text('Company Profile'),
                  subtitle: const Text(
                    'Manage your company details and public information.',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CompanyProfileScreen(),
                      ),
                    );
                  },
                ),
              ),

              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.person_search_rounded,
                    color: Color(0xFF36D6C3),
                  ),
                  title: const Text('Manage Applicants'),
                  subtitle: const Text('Review potential candidates.'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MyJobsScreen()),
                    );
                  },
                ),
              ),

              Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(18),
                  leading: const Icon(
                    Icons.list_alt_rounded,
                    color: Color(0xFF36D6C3),
                  ),
                  title: const Text('My Jobs'),
                  subtitle: const Text('View jobs published by your company.'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MyJobsScreen()),
                    );

                    if (!mounted) return;
                    await _refreshStats();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFF9B6DFF), size: 28),
            const SizedBox(height: 18),
            Text(
              value,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(color: Color(0xFF9292A7))),
          ],
        ),
      ),
    );
  }
}
