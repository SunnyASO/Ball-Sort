import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'services/progression_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ProgressionService.instance.initialize();
  runApp(const BallSortApp());
}

/// Root application widget for Ball Sort / Orb Lab.
class BallSortApp extends StatelessWidget {
  const BallSortApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Orb Lab',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const HomeScreen(),
    );
  }
}
