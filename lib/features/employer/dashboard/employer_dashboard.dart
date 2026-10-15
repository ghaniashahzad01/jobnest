import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EmployerDashboard extends StatelessWidget {
  const EmployerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employer Portal'),
        actions: [
          IconButton(
            tooltip: 'Log out',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();

              if (!context.mounted) return;

              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Hire the right talent.',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Manage jobs and discover promising candidates.',
                style: TextStyle(color: Color(0xFF9292A7)),
              ),
              const SizedBox(height: 26),
              const Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.work_outline_rounded,
                      title: 'Active Jobs',
                      value: '0',
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.people_outline_rounded,
                      title: 'Applicants',
                      value: '0',
                    ),
                  ),
                ],
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
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Job posting will be implemented next.'),
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
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Applicant management is coming next.'),
                      ),
                    );
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
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(color: Color(0xFF9292A7)),
            ),
          ],
        ),
      ),
    );
  }
}
