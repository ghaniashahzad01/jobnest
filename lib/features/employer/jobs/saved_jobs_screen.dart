
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SavedJobsScreen extends StatefulWidget {
  const SavedJobsScreen({super.key});

  @override
  State<SavedJobsScreen> createState() => _SavedJobsScreenState();
}

class _SavedJobsScreenState extends State<SavedJobsScreen> {
  final supabase = Supabase.instance.client;
  bool loading = true;
  List<Map<String, dynamic>> savedJobs = [];

  @override
  void initState() {
    super.initState();
    loadSavedJobs();
  }

  Future<void> loadSavedJobs() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final response = await supabase
          .from('saved_jobs')
          .select('id, job_id, jobs(*)')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      if (!mounted) return;

      setState(() {
        savedJobs = List<Map<String, dynamic>>.from(response);
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load saved jobs: $e')),
      );
    }
  }

  Future<void> removeSavedJob(Map<String, dynamic> saved) async {
    try {
      await supabase
          .from('saved_jobs')
          .delete()
          .eq('id', saved['id'])
          .eq('user_id', supabase.auth.currentUser!.id);

      if (!mounted) return;

      setState(() {
        savedJobs.removeWhere((item) => item['id'] == saved['id']);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Job removed from saved jobs')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not remove job: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Jobs'),
        actions: [
          IconButton(
            onPressed: loadSavedJobs,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : savedJobs.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bookmark_border, size: 56),
                      SizedBox(height: 12),
                      Text('No saved jobs yet'),
                      SizedBox(height: 6),
                      Text('Bookmark jobs to find them here.'),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: loadSavedJobs,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: savedJobs.length,
                    itemBuilder: (context, index) {
                      final saved = savedJobs[index];
                      final job = saved['jobs'];

                      if (job == null) {
                        return const SizedBox.shrink();
                      }

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(
                            job['title']?.toString() ?? 'Untitled Job',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              [
                                job['company_name'],
                                job['location'],
                                job['job_type'],
                              ]
                                  .where((value) =>
                                      value != null &&
                                      value.toString().isNotEmpty)
                                  .join(' • '),
                            ),
                          ),
                          trailing: IconButton(
                            tooltip: 'Remove saved job',
                            icon: const Icon(
                              Icons.bookmark_remove_outlined,
                            ),
                            onPressed: () => removeSavedJob(saved),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
