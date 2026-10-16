import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../matching/smart_job_matching_screen.dart';
import '../applications/application_tracker_screen.dart';
import '../jobs/browse_jobs_screen.dart';

class JobSeekerDashboard extends StatelessWidget {
  const JobSeekerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JobNest'),
        actions: [
          IconButton(
            tooltip: 'Log out',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();

              if (!context.mounted) return;

              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/', (route) => false);
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
                'Your next opportunity.',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              const Text(
                'Discover jobs that fit your skills and goals.',
                style: TextStyle(color: Color(0xFF9292A7)),
              ),
              const SizedBox(height: 26),

              // Find Jobs: opens the Browse Jobs screen.
              _FeatureCard(
                icon: Icons.work_outline_rounded,
                title: 'Find Jobs',
                subtitle: 'Explore opportunities for your career.',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BrowseJobsScreen()),
                  );
                },
              ),

              _FeatureCard(
                icon: Icons.auto_awesome_rounded,
                title: 'Smart Matching',
                subtitle: 'Discover jobs aligned with your skills.',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SmartJobMatchingScreen(),
                    ),
                  );
                },
              ),

              _FeatureCard(
                icon: Icons.trending_up_rounded,
                title: 'Skill Gap Analysis',
                subtitle: 'Identify skills to improve.',
              ),

              _FeatureCard(
                icon: Icons.track_changes_rounded,
                title: 'Application Tracker',
                subtitle: 'Keep track of your applications.',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ApplicationTrackerScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(16),
        leading: Icon(icon, color: const Color(0xFF9B6DFF), size: 30),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(subtitle),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
