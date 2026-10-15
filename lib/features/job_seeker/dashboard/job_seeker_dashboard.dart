
import 'package:flutter/material.dart';

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
              await Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) => const _LogoutScreen(),
                ),
                (route) => false,
              );
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
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Discover jobs that fit your skills and goals.',
                style: TextStyle(color: Color(0xFF9292A7)),
              ),
              const SizedBox(height: 26),
              _FeatureCard(
                icon: Icons.work_outline_rounded,
                title: 'Find Jobs',
                subtitle: 'Explore opportunities for your career.',
              ),
              _FeatureCard(
                icon: Icons.auto_awesome_rounded,
                title: 'Smart Matching',
                subtitle: 'Discover jobs aligned with your skills.',
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
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Icon(icon, color: const Color(0xFF9B6DFF), size: 30),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(subtitle),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}

class _LogoutScreen extends StatelessWidget {
  const _LogoutScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Please reopen JobNest to log in again.'),
      ),
    );
  }
}
