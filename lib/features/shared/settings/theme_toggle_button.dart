import 'package:flutter/material.dart';

import '../../../core/theme/theme_controller.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ThemeController.instance;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final isDark =
            controller.themeMode == ThemeMode.dark ||
            (controller.themeMode == ThemeMode.system &&
                Theme.of(context).brightness == Brightness.dark);
        return IconButton(
          tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
          onPressed: () => controller.setThemeMode(
            isDark ? ThemeMode.light : ThemeMode.dark,
          ),
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              key: ValueKey(isDark),
            ),
          ),
        );
      },
    );
  }
}
