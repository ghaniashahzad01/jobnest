
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const JobNestApp());
}

class JobNestApp extends StatelessWidget {
  const JobNestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JobNest',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const JobNestHome(),
    );
  }
}

class JobNestHome extends StatelessWidget {
  const JobNestHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF9B6DFF),
                        Color(0xFF5D5FEF),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: const Icon(
                    Icons.work_outline_rounded,
                    color: Colors.white,
                    size: 42,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'JobNest',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Find. Match. Improve. Track.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 36),
                const CircularProgressIndicator(
                  color: Color(0xFF9B6DFF),
                  strokeWidth: 2.5,
                ),
                const SizedBox(height: 14),
                Text(
                  'Your career journey starts here',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
