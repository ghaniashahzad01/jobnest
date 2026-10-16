
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'features/auth/screens/welcome_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://wghneejfiujhahgfoanw.supabase.co',
    publishableKey: 'sb_publishable_lTnRLkRxKikcYAoqAZHwww_ViQHlEm4',
  );

  runApp(const JobNestApp());
}

class JobNestApp extends StatefulWidget {
  const JobNestApp({super.key});

  @override
  State<JobNestApp> createState() => _JobNestAppState();
}

class _JobNestAppState extends State<JobNestApp> {
  late final ThemeController themeController;

  @override
  void initState() {
    super.initState();

    themeController = ThemeController.instance;
    themeController.addListener(_onThemeChanged);
  }

  void _onThemeChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    themeController.removeListener(_onThemeChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JobNest',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeController.themeMode,
      home: const WelcomeScreen(),
    );
  }
}
