import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'dart:async';

import 'features/auth/screens/reset_password_screen.dart';
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

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class JobNestApp extends StatefulWidget {
  const JobNestApp({super.key});

  @override
  State<JobNestApp> createState() => _JobNestAppState();
}

class _JobNestAppState extends State<JobNestApp> {
  late final ThemeController themeController;

  late final StreamSubscription<AuthState> _authSubscription;

  @override
  void initState() {
    super.initState();

    themeController = ThemeController.instance;
    themeController.addListener(_onThemeChanged);

    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((
      data,
    ) {
      if (data.event == AuthChangeEvent.passwordRecovery && mounted) {
        Navigator.of(
          navigatorKey.currentContext!,
        ).push(MaterialPageRoute(builder: (_) => const ResetPasswordScreen()));
      }
    });
  }

  void _onThemeChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _authSubscription.cancel();
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
      navigatorKey: navigatorKey,
      themeMode: themeController.themeMode,
      home: const WelcomeScreen(),
    );
  }
}
