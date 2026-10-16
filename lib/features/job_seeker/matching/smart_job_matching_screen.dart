
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SmartJobMatchingScreen extends StatefulWidget {
  const SmartJobMatchingScreen({super.key});

  @override
  State<SmartJobMatchingScreen> createState() =>
      _SmartJobMatchingScreenState();
}

class _SmartJobMatchingScreenState
    extends State<SmartJobMatchingScreen> {
  final skillsController = TextEditingController();

  bool isLoading = true;
  String? errorMessage;
  List<Map<String, dynamic>> jobs = [];

  @override
  void initState() {
    super.initState();
    loadJobs();
  }

  @override
  void dispose() {
    skillsController.dispose();
    super.dispose();
  }

  Future<void> loadJobs() async {
    try {
      final result = await Supabase.instance.client
          .from('jobs')
          .select('*')
          .eq('status', 'active');

      if (!mounted) return;

      setState(() {
        jobs = List<Map<String, dynamic>>.from(result);
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  List<String> get userSkills => skillsController.text
      .toLowerCase()
      .split(RegExp(r'[,;\n]+'))
      .map((skill) => skill.trim())
      .where((skill) => skill.isNotEmpty)
      .toSet()
      .toList();

  int matchPercentage(Map<String, dynamic> job) {
    final skills = userSkills;
    if (skills.isEmpty) return 0;

    // Combine job information so matching also works if the
    // database uses different names for skills or descriptions.
    final jobText = job.entries
        .where((entry) => entry.value != null)
        .map((entry) => entry.value is List
            ? (entry.value as List).join(' ')
            : entry.value.toString())
        .join(' ')
        .toLowerCase();

    final matches = skills.where((skill) {
      return RegExp(
        r'(^|[^a-z0-9+#.])' +
            RegExp.escape(skill) +
            r'($|[^a-z0-9+#.])',
      ).hasMatch(jobText);
    }).length;

    return ((matches / skills.length) * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    final results = jobs.toList()
      ..sort((a, b) =>
          matchPercentage(b).compareTo(matchPercentage(a)));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Job Matching'),
        actions: [
          IconButton(
            onPressed: loadJobs,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh jobs',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Find your best match ✨',
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Enter your skills separated by commas. '
                    'We will compare them with active job listings.',
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: skillsController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText:
                          'e.g. Flutter, Dart, Supabase, REST API',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.psychology_outlined),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ],
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : errorMessage != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Could not load jobs:\n$errorMessage',
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton(
                                  onPressed: loadJobs,
                                  child: const Text('Try Again'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : jobs.isEmpty
                          ? const Center(
                              child: Text('No active jobs available yet.'),
                            )
                          : userSkills.isEmpty
                              ? const Center(
                                  child: Text(
                                    'Enter your skills to see job matches.',
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: results.length,
                                  itemBuilder: (context, index) {
                                    final job = results[index];
                                    final percentage =
                                        matchPercentage(job);

                                    final title =
                                        (job['title'] ??
                                                job['job_title'] ??
                                                'Job opportunity')
                                            .toString();
                                    final company =
                                        (job['company_name'] ??
                                                job['company'] ??
                                                'Company')
                                            .toString();
                                    final location =
                                        (job['location'] ?? 'Location not specified')
                                            .toString();

                                    return Card(
                                      margin: const EdgeInsets.only(
                                        bottom: 14,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              title,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(company),
                                            const SizedBox(height: 4),
                                            Text(location),
                                            const SizedBox(height: 16),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.auto_awesome,
                                                  color: Color(0xFF9B6DFF),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    '$percentage% skill keyword match',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: LinearProgressIndicator(
                                                value: percentage / 100,
                                                minHeight: 8,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
            ),
          ],
        ),
      ),
    );
  }
}
