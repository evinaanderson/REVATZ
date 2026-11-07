import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'home_shell.dart';

class SermonApp extends StatelessWidget {
  const SermonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'REVATZ',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: const HomeShell(),
    );
  }
}
