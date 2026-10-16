
import 'package:flutter/material.dart';

import 'role_selection_screen.dart';
import 'login_screen.dart';
import '../widgets/auth_header.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              const AuthHeader(
                title: 'Your next chapter\nstarts here.',
                subtitle:
                    'Discover opportunities, match your skills, and build your career with JobNest.',
              ),
              const SizedBox(height: 38),

              // Theme-aware feature card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: theme.cardTheme.color ?? colors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: theme.dividerColor,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.auto_awesome_rounded,
                      color: Color(0xFF9B6DFF),
                      size: 28,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'A smarter way to find your fit.',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Personalized jobs. Skill insights. Applications in one place.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? const Color(0xFF9292A7)
                            : const Color(0xFF77758A),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RoleSelectionScreen(),
                    ),
                  ),
                  child: const Text('Get Started'),
                ),
              ),
              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginScreen(
                        role: 'job_seeker',
                      ),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 54),
                    foregroundColor: colors.primary,
                    side: BorderSide(
                      color: theme.dividerColor,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('I already have an account'),
                ),
              ),

              const SizedBox(height: 16),
              Center(
                child: Text(
                  'FIND. MATCH. IMPROVE. TRACK.',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isDark
                        ? const Color(0xFF9292A7)
                        : const Color(0xFF77758A),
                    fontSize: 10,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
