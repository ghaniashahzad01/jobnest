
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  void openSignup(BuildContext context, String role) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SignupScreen(role: role),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose your path')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 18),
            const Text(
              'How will you use JobNest?',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            const Text(
              'Choose the account that fits your goals.',
              style: TextStyle(color: Color(0xFF9292A7)),
            ),
            const SizedBox(height: 30),
            _RoleCard(
              icon: Icons.person_search_rounded,
              title: 'I am looking for a job',
              description:
                  'Discover jobs, improve your skills, and track applications.',
              onTap: () => openSignup(context, 'job_seeker'),
            ),
            const SizedBox(height: 16),
            _RoleCard(
              icon: Icons.business_rounded,
              title: 'I am hiring',
              description:
                  'Post jobs, review applicants, and find the right candidates.',
              onTap: () => openSignup(context, 'employer'),
            ),
            const Spacer(),
            Center(
              child: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(role: 'job_seeker'),
                  ),
                ),
                child: const Text('Already registered? Log in'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF151520),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFF292938)),
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFF9B6DFF).withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: const Color(0xFFB69AFF), size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        )),
                    const SizedBox(height: 7),
                    Text(description,
                        style: const TextStyle(
                          color: Color(0xFF9292A7),
                          height: 1.4,
                        )),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
