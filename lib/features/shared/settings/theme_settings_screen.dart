
import 'package:flutter/material.dart';

import '../../../core/theme/theme_controller.dart';

class ThemeSettingsScreen extends StatelessWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ThemeController.instance;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final selectedMode = controller.themeMode;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Appearance'),
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF9B6DFF),
                      Color(0xFF6265F1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.palette_outlined,
                      color: Colors.white,
                      size: 36,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Make JobNest yours',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Choose the appearance that feels right for you.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'THEME PREFERENCE',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              _ThemeOption(
                title: 'Light Mode',
                subtitle: 'Bright and clear appearance',
                icon: Icons.light_mode_outlined,
                selected: selectedMode == ThemeMode.light,
                onTap: () => controller.setThemeMode(ThemeMode.light),
              ),
              const SizedBox(height: 10),
              _ThemeOption(
                title: 'Dark Mode',
                subtitle: 'Easy on the eyes in low light',
                icon: Icons.dark_mode_outlined,
                selected: selectedMode == ThemeMode.dark,
                onTap: () => controller.setThemeMode(ThemeMode.dark),
              ),
              const SizedBox(height: 10),
              _ThemeOption(
                title: 'System Default',
                subtitle: 'Follow your device appearance',
                icon: Icons.settings_suggest_outlined,
                selected: selectedMode == ThemeMode.system,
                onTap: () => controller.setThemeMode(ThemeMode.system),
              ),
              const SizedBox(height: 24),
              Text(
                'Your preference is saved automatically.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: theme.colorScheme.primary,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(subtitle),
        ),
        trailing: Icon(
          selected ? Icons.radio_button_checked : Icons.radio_button_off,
          color: selected ? theme.colorScheme.primary : null,
        ),
        onTap: onTap,
      ),
    );
  }
}
