import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'job_details_screen.dart';
import 'saved_jobs_screen.dart';

class BrowseJobsScreen extends StatefulWidget {
  const BrowseJobsScreen({super.key});

  @override
  State<BrowseJobsScreen> createState() => _BrowseJobsScreenState();
}

class _BrowseJobsScreenState extends State<BrowseJobsScreen> {
  final searchController = TextEditingController();

  String selectedWorkplace = 'All';
  final Set<String> savedJobIds = {};
  late Future<List<Map<String, dynamic>>> jobsFuture;
  
  @override
  void initState() {
    super.initState();
    jobsFuture = _loadJobs();
    _loadSavedJobIds();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _loadJobs() async {
    final response = await Supabase.instance.client
        .from('jobs')
        .select()
        .eq('status', 'active')
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> _loadSavedJobIds() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final response = await Supabase.instance.client
          .from('saved_jobs')
          .select('job_id')
          .eq('user_id', user.id);

      if (!mounted) return;

      setState(() {
        savedJobIds
          ..clear()
          ..addAll(
            List<Map<String, dynamic>>.from(response)
                .map((item) => item['job_id'].toString()),
          );
      });
    } catch (e) {
      debugPrint('Could not load saved jobs: $e');
    }
  }

  Future<void> _toggleSavedJob(Map<String, dynamic> job) async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;

    if (user == null) return;

    final jobId = job['id'].toString();
    final wasSaved = savedJobIds.contains(jobId);

    try {
      if (wasSaved) {
        await client
            .from('saved_jobs')
            .delete()
            .eq('user_id', user.id)
            .eq('job_id', job['id']);

        if (!mounted) return;
        setState(() => savedJobIds.remove(jobId));
      } else {
        await client.from('saved_jobs').insert({
          'user_id': user.id,
          'job_id': job['id'],
        });

        if (!mounted) return;
        setState(() => savedJobIds.add(jobId));
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            wasSaved
                ? 'Job removed from Saved Jobs'
                : 'Job saved successfully!',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not update saved job: $e')));
    }
  }

  void _refreshJobs() {
    setState(() {
      jobsFuture = _loadJobs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore Jobs'),
        actions: [
          IconButton(
            tooltip: 'Saved Jobs',
            icon: const Icon(Icons.bookmarks_outlined),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SavedJobsScreen()),
              );

              _loadSavedJobIds();
            },
          ),
          IconButton(
            tooltip: 'Refresh jobs',
            onPressed: _refreshJobs,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
            child: TextField(
              controller: searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search jobs, companies, skills...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: searchController.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          searchController.clear();
                          setState(() {});
                        },
                        icon: const Icon(Icons.close_rounded),
                      ),
              ),
            ),
          ),
          SizedBox(
            height: 54,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              children: [
                _FilterChip(
                  label: 'All',
                  selected: selectedWorkplace == 'All',
                  onTap: () => setState(() => selectedWorkplace = 'All'),
                ),
                _FilterChip(
                  label: 'Remote',
                  selected: selectedWorkplace == 'Remote',
                  onTap: () => setState(() => selectedWorkplace = 'Remote'),
                ),
                _FilterChip(
                  label: 'Hybrid',
                  selected: selectedWorkplace == 'Hybrid',
                  onTap: () => setState(() => selectedWorkplace = 'Hybrid'),
                ),
                _FilterChip(
                  label: 'On-site',
                  selected: selectedWorkplace == 'On-site',
                  onTap: () => setState(() => selectedWorkplace = 'On-site'),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: jobsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return _MessageView(
                    icon: Icons.cloud_off_rounded,
                    title: 'Could not load jobs',
                    subtitle: 'Check your connection and try again.',
                    action: TextButton(
                      onPressed: _refreshJobs,
                      child: const Text('Try again'),
                    ),
                  );
                }

                final allJobs = snapshot.data ?? [];
                final query = searchController.text.trim().toLowerCase();

                final filteredJobs = allJobs.where((job) {
                  final workplace = job['workplace_type'] as String? ?? '';
                  final title = job['title'] as String? ?? '';
                  final company = job['company_name'] as String? ?? '';
                  final location = job['location'] as String? ?? '';
                  final skills = List<String>.from(job['required_skills'] ?? [])
                      .join(' ');

                  final matchesWorkplace =
                      selectedWorkplace == 'All' ||
                      workplace == selectedWorkplace;

                  final searchableText = '$title $company $location $skills'
                      .toLowerCase();

                  return matchesWorkplace && searchableText.contains(query);
                }).toList();

                if (filteredJobs.isEmpty) {
                  return _MessageView(
                    icon: Icons.work_outline_rounded,
                    title: query.isEmpty ? 'No jobs found' : 'No matching jobs',
                    subtitle: query.isEmpty
                        ? 'New opportunities will appear here when employers publish jobs.'
                        : 'Try another search or change the filter.',
                    action: query.isNotEmpty || selectedWorkplace != 'All'
                        ? TextButton(
                            onPressed: () {
                              searchController.clear();
                              setState(() => selectedWorkplace = 'All');
                            },
                            child: const Text('Clear filters'),
                          )
                        : null,
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => _refreshJobs(),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
                    itemCount: filteredJobs.length,
                    itemBuilder: (context, index) {
                      final job = filteredJobs[index];

                      final skills = List<String>.from(
                        job['required_skills'] ?? [],
                      );

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => JobDetailsScreen(job: job),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF9B6DFF)
                                            .withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: const Icon(
                                        Icons.work_outline_rounded,
                                        color: Color(0xFF9B6DFF),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            job['title'] ?? 'Untitled job',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            job['company_name'] ?? '',
                                            style: const TextStyle(
                                              color: Color(0xFFB6B2C7),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      tooltip:
                                          savedJobIds.contains(
                                            job['id'].toString(),
                                          )
                                          ? 'Remove saved job'
                                          : 'Save job',
                                      onPressed: () => _toggleSavedJob(job),
                                      icon: Icon(
                                        savedJobIds.contains(
                                              job['id'].toString(),
                                            )
                                            ? Icons.bookmark_rounded
                                            : Icons.bookmark_border_rounded,
                                        color: const Color(0xFFB49AFF),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 18),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _InfoChip(
                                      icon: Icons.location_on_outlined,
                                      label: job['location'] ?? 'Not specified',
                                    ),
                                    _InfoChip(
                                      icon: Icons.schedule_rounded,
                                      label: job['job_type'] ?? 'Full-time',
                                    ),
                                    _InfoChip(
                                      icon: Icons.laptop_outlined,
                                      label: job['workplace_type'] ?? 'On-site',
                                    ),
                                  ],
                                ),
                                if (skills.isNotEmpty) ...[
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Required skills',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: skills.take(5).map((skill) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 7,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF22202F),
                                          borderRadius: BorderRadius.circular(
                                            9,
                                          ),
                                        ),
                                        child: Text(
                                          skill,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                                const SizedBox(height: 16),
                                const Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    'View details →',
                                    style: TextStyle(
                                      color: Color(0xFFB49AFF),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: const Color(0xFF9B6DFF),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF22202F),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFFB49AFF)),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class _MessageView extends StatelessWidget {
  const _MessageView({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 90),
        Icon(icon, size: 54, color: const Color(0xFF9B6DFF)),
        const SizedBox(height: 16),
        Center(
          child: Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF9292A7)),
          ),
        ),
        if (action != null) Center(child: action!),
      ],
    );
  }
}
