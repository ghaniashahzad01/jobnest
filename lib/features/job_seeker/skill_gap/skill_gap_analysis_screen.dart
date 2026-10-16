
import 'package:flutter/material.dart';

class SkillGapAnalysisScreen extends StatefulWidget {
  const SkillGapAnalysisScreen({super.key});

  @override
  State<SkillGapAnalysisScreen> createState() =>
      _SkillGapAnalysisScreenState();
}

class _SkillGapAnalysisScreenState
    extends State<SkillGapAnalysisScreen> {
  final currentSkillsController = TextEditingController();
  final requiredSkillsController = TextEditingController();

  List<String> currentSkills = [];
  List<String> requiredSkills = [];
  bool analyzed = false;

  List<String> parseSkills(String value) {
    return value
        .toLowerCase()
        .split(RegExp(r'[,;\n]+'))
        .map((skill) => skill.trim())
        .where((skill) => skill.isNotEmpty)
        .toSet()
        .toList();
  }

  void analyzeSkills() {
    final current = parseSkills(currentSkillsController.text);
    final required = parseSkills(requiredSkillsController.text);

    if (current.isEmpty || required.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter both your skills and target job skills.'),
        ),
      );
      return;
    }

    setState(() {
      currentSkills = current;
      requiredSkills = required;
      analyzed = true;
    });
  }

  @override
  void dispose() {
    currentSkillsController.dispose();
    requiredSkillsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final missingSkills = requiredSkills
        .where((skill) => !currentSkills.contains(skill))
        .toList();

    final matchedSkills = requiredSkills
        .where((skill) => currentSkills.contains(skill))
        .toList();

    final percentage = requiredSkills.isEmpty
        ? 0
        : (matchedSkills.length / requiredSkills.length * 100).round();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Skill Gap Analysis'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Build your career skills 📈',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Compare your current skills with the skills required '
              'for your target job.',
            ),
            const SizedBox(height: 22),
            TextField(
              controller: currentSkillsController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Your current skills',
                hintText: 'Flutter, Dart, Git',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.check_circle_outline),
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: requiredSkillsController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Target job required skills',
                hintText: 'Flutter, Dart, REST API, Firebase',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.flag_outlined),
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: analyzeSkills,
              icon: const Icon(Icons.analytics_outlined),
              label: const Text('Analyze Skills'),
            ),
            if (analyzed) ...[
              const SizedBox(height: 26),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your skill match',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '$percentage%',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF9B6DFF),
                        ),
                      ),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: percentage / 100,
                        minHeight: 9,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${matchedSkills.length} of '
                        '${requiredSkills.length} required skills matched.',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Skills you already have',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (matchedSkills.isEmpty)
                const Text('No matching skills yet.')
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: matchedSkills
                      .map(
                        (skill) => Chip(
                          avatar: const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 18,
                          ),
                          label: Text(skill),
                        ),
                      )
                      .toList(),
                ),
              const SizedBox(height: 20),
              const Text(
                'Skills to develop',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (missingSkills.isEmpty)
                const Text(
                  'Excellent! You have entered all the required skills. 🎉',
                )
              else
                ...missingSkills.map(
                  (skill) => Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.school_outlined,
                        color: Color(0xFF9B6DFF),
                      ),
                      title: Text(skill),
                      subtitle: Text('Add $skill to your learning plan.'),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
