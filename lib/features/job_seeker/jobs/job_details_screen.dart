import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'apply_job_screen.dart';

class JobDetailsScreen extends StatefulWidget {
  const JobDetailsScreen({super.key, required this.job});

  final Map<String, dynamic> job;

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  bool isLoading = false;
  bool hasApplied = false;
  bool checkingApplication = true;

  @override
  void initState() {
    super.initState();
    _checkApplication();
  }

  Future<void> _checkApplication() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;

      if (user == null) {
        if (mounted) {
          setState(() => checkingApplication = false);
        }
        return;
      }

      final existing = await Supabase.instance.client
          .from('applications')
          .select('id')
          .eq('job_id', widget.job['id'])
          .eq('applicant_id', user.id)
          .maybeSingle();

      if (!mounted) return;

      setState(() {
        hasApplied = existing != null;
        checkingApplication = false;
      });
    } catch (error) {
      debugPrint('Application check error: $error');

      if (mounted) {
        setState(() => checkingApplication = false);
      }
    }
  }

  Future<void> _applyForJob() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      _showMessage('Please log in before applying.');
      return;
    }

    setState(() => isLoading = true);

    try {
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => ApplyJobScreen(job: widget.job)),
      );

      if (!mounted) return;

      if (result == true) {
        setState(() => hasApplied = true);
      }
    } catch (error) {
      if (!mounted) return;
      _showMessage('Could not open application form.');
      debugPrint('Open application form error: $error');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;
    final description = (job['description'] ?? '').toString().trim();
    final skills = List<String>.from(job['required_skills'] ?? [])
        .where((skill) => skill.trim().isNotEmpty)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Job Details')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 880;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: constraints.maxWidth < 600 ? 16 : 28,
                vertical: 24,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1160),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _JobHeader(job: job, compact: !isWide),
                      const SizedBox(height: 20),
                      if (isWide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 7,
                              child: _JobContent(
                                description: description,
                                skills: skills,
                              ),
                            ),
                            const SizedBox(width: 20),
                            SizedBox(
                              width: 320,
                              child: _ApplicationCard(
                                hasApplied: hasApplied,
                                isLoading: isLoading,
                                checkingApplication: checkingApplication,
                                onApply: _applyForJob,
                              ),
                            ),
                          ],
                        )
                      else ...[
                        _JobContent(description: description, skills: skills),
                        _ApplicationCard(
                          hasApplied: hasApplied,
                          isLoading: isLoading,
                          checkingApplication: checkingApplication,
                          onApply: _applyForJob,
                        ),
                      ],
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _JobHeader extends StatelessWidget {
  const _JobHeader({required this.job, required this.compact});

  final Map<String, dynamic> job;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final companyName = (job['company_name'] ?? '').toString().trim();

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(compact ? 20 : 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: compact ? 56 : 68,
                  height: compact ? 56 : 68,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.work_outline_rounded,
                    color: colors.primary,
                    size: compact ? 28 : 32,
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (job['title'] ?? 'Untitled job').toString(),
                          style:
                              (compact
                                      ? theme.textTheme.headlineSmall
                                      : theme.textTheme.headlineMedium)
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.5,
                                    height: 1.12,
                                  ),
                        ),
                        if (companyName.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            companyName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _DetailChip(
                  icon: Icons.location_on_outlined,
                  label: (job['location'] ?? 'Not specified').toString(),
                ),
                _DetailChip(
                  icon: Icons.schedule_rounded,
                  label: (job['job_type'] ?? 'Full-time').toString(),
                ),
                _DetailChip(
                  icon: Icons.laptop_outlined,
                  label: (job['workplace_type'] ?? 'On-site').toString(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _JobContent extends StatelessWidget {
  const _JobContent({required this.description, required this.skills});

  final String description;
  final List<String> skills;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (description.isNotEmpty) ...[
          _ContentCard(
            title: 'About this role',
            icon: Icons.subject_rounded,
            child: SelectableText(
              description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.7,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          if (skills.isNotEmpty) const SizedBox(height: 16),
        ],
        if (skills.isNotEmpty)
          _ContentCard(
            title: 'Required skills',
            icon: Icons.auto_awesome_outlined,
            child: Wrap(
              spacing: 9,
              runSpacing: 9,
              children: skills
                  .map((skill) => Chip(label: Text(skill)))
                  .toList(),
            ),
          ),
      ],
    );
  }
}

class _ContentCard extends StatelessWidget {
  const _ContentCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 21, color: colors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    softWrap: true,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            child,
          ],
        ),
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  const _ApplicationCard({
    required this.hasApplied,
    required this.isLoading,
    required this.checkingApplication,
    required this.onApply,
  });

  final bool hasApplied;
  final bool isLoading;
  final bool checkingApplication;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isBusy = isLoading || checkingApplication;
    final buttonLabel = hasApplied
        ? 'Already applied'
        : checkingApplication
        ? 'Checking status…'
        : isLoading
        ? 'Opening application…'
        : 'Apply now';
    final statusMessage = hasApplied
        ? 'You have already applied for this role.'
        : checkingApplication
        ? 'Checking your application status.'
        : isLoading
        ? 'Opening the application form.'
        : 'Continue to the application form when you’re ready.';

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                hasApplied ? Icons.check_circle_outline : Icons.send_outlined,
                color: colors.primary,
                size: 22,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              hasApplied ? 'Application submitted' : 'Interested in this role?',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Semantics(
              liveRegion: true,
              child: Text(
                statusMessage,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isBusy || hasApplied ? null : onApply,
                icon: isBusy
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colors.onPrimary,
                        ),
                      )
                    : Icon(
                        hasApplied ? Icons.check_rounded : Icons.arrow_forward,
                        size: 18,
                      ),
                label: Text(buttonLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: colors.primary),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              softWrap: true,
              style: theme.textTheme.labelLarge?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
